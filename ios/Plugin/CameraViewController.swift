import UIKit
import SwiftUI
import AVFoundation
import MLImage
import MLKitVision

protocol CameraViewControllerDelegate: NSObjectProtocol {
    func onComplete(_ result: [DetectedBarcode])
    func onError(_ error: String)
}

class CameraViewController: UIViewController, BarcodesListener {
    weak var delegate: CameraViewControllerDelegate?
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private var previewLayer = AVCaptureVideoPreviewLayer()
    private var settings: ScannerSettings
    private var cameraOverlay: CameraOverlay!
    private var barcodeAnalyzer: BarcodeAnalyzer!
    private var torchButton: UIButton?
    private var finishedAlready: Bool = false // ensure we only actually finish once

    func onBarcodesFound(_ barcodes: [DetectedBarcode]) {
        finishWithResult(barcodes)
    }

    init(settings: ScannerSettings) {
        self.settings = settings
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.settings = ScannerSettings()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        cameraOverlay = CameraOverlay(settings: settings, parentView: view)
        barcodeAnalyzer = BarcodeAnalyzer(settings: settings, barcodesListener: self, cameraOverlay: cameraOverlay)

        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            setupCaptureSession()
            setupUI()
            setOrientation()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (authorized) in
                DispatchQueue.main.async {
                    if authorized {
                        self.setupCaptureSession()
                        self.setupUI()
                        self.setOrientation()
                    } else {
                        self.finishWithError("NO_CAMERA_PERMISSION")
                    }
                }
            })
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        startSession()
        // slight delay so the camera has time to load before we show the modal
        while !captureSession.isRunning {
            usleep(100)
        }
        usleep(150000)
    }

    override func viewDidDisappear(_ animated: Bool) {
        stopSession()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setOrientation()
    }

    private func setOrientation() {
        previewLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

        if #available(iOS 17.0, *) {
            switch UIDevice.current.orientation {
            case UIDeviceOrientation.portraitUpsideDown:
                previewLayer.connection?.videoRotationAngle = 270
            case UIDeviceOrientation.landscapeLeft:
                previewLayer.connection?.videoRotationAngle = 0
            case UIDeviceOrientation.landscapeRight:
                previewLayer.connection?.videoRotationAngle = 180
            case UIDeviceOrientation.portrait:
                previewLayer.connection?.videoRotationAngle = 90
            default:
                break
            }
        } else {
            switch UIDevice.current.orientation {
            case UIDeviceOrientation.portraitUpsideDown:
                previewLayer.connection?.videoOrientation = .portraitUpsideDown
            case UIDeviceOrientation.landscapeLeft:
                previewLayer.connection?.videoOrientation = .landscapeRight
            case UIDeviceOrientation.landscapeRight:
                previewLayer.connection?.videoOrientation = .landscapeLeft
            case UIDeviceOrientation.portrait:
                previewLayer.connection?.videoOrientation = .portrait
            default:
                break
            }
        }
    }

    private func setupCaptureSession() {
        guard let videoDevice = captureDevice() else {
            finishWithError("NO_CAMERA")
            return

        }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            finishWithError("NO_CAMERA")
            return

        }
        guard captureSession.canAddInput(videoDeviceInput) else { return }

        captureSession.addInput(videoDeviceInput)

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.backgroundColor = UIColor.black.cgColor
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

        if #available(iOS 17.0, *) {
            previewLayer.connection?.videoRotationAngle = 90
        } else {
            previewLayer.connection?.videoOrientation = .portrait
        }

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleQueue"))

        captureSession.addOutput(output)
    }

    private func setupUI() {
        view.layer.addSublayer(previewLayer)
        cameraOverlay.setPreviewLayer(previewLayer)
        view.bringSubviewToFront(cameraOverlay)

        torchButton = createTorchButton()
    }

    private func createTorchButton() -> UIButton? {
        if let device = AVCaptureDevice.default(for: AVMediaType.video) {
            if device.hasTorch {
                var conf = UIButton.Configuration.filled()
                conf.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                conf.background.cornerRadius = 25
                conf.baseForegroundColor = UIColor.black
                conf.baseBackgroundColor = UIColor.white

                if let image = UIImage(named: "flashlight") {
                    conf.image = image.scalePreservingAspectRatio(targetSize: CGSize(width: 30, height: 30))
                }
                let torchButton = UIButton(configuration: conf)
                torchButton.alpha = 0.5
                torchButton.addTarget(self, action: #selector(toggleFlash), for: UIControl.Event.touchUpInside)

                view.addSubview(torchButton)
                torchButton.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    torchButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                    torchButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
                    torchButton.widthAnchor.constraint(equalToConstant: 50),
                    torchButton.heightAnchor.constraint(equalToConstant: 50)
                ])
                return torchButton
            }
        }
        return nil
    }

    @objc
    private func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { print("Torch isn't available"); return }

        do {
            try device.lockForConfiguration()

            if device.torchMode == AVCaptureDevice.TorchMode.on {
                device.torchMode = AVCaptureDevice.TorchMode.off
                torchButton?.alpha = 0.5
            } else {
                do {
                    try device.setTorchModeOn(level: 1.0)
                    torchButton?.alpha = 1
                } catch {
                    print(error)
                }
            }

            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }

    private func captureDevice() -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        return discoverySession.devices.first { $0.position == .back }
    }

    private func startSession() {
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {return}
            strongSelf.captureSession.startRunning()
        }
    }

    private func stopSession() {
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {return}
            strongSelf.captureSession.stopRunning()
        }
    }

    private func finishWithError(_ error: String) {
        if !finishedAlready {
            finishedAlready = true
            delegate?.onError(error)
        }
    }

    private func finishWithResult(_ result: [DetectedBarcode]) {
        if !finishedAlready {
            finishedAlready = true
            delegate?.onComplete(result)
        }
    }
}

extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        let scaleFactor = min(widthRatio, heightRatio)

        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        return scaledImage
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get image buffer from sample buffer.")
            return
        }

        let visionImage = VisionImage(buffer: sampleBuffer)
        let orientation = Utils.imageOrientation(fromDevicePosition: .back)

        visionImage.orientation = orientation

        guard let inputImage = MLImage(sampleBuffer: sampleBuffer) else {
            print("Failed to create MLImage from sample buffer.")
            return
        }
        inputImage.orientation = orientation

        let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
        let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))

        barcodeAnalyzer.analyze(in: visionImage, width: imageWidth, height: imageHeight)
    }
}
