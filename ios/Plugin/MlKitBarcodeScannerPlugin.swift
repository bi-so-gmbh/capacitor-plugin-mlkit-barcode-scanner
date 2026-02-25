import Foundation
import Capacitor
import AVFoundation

@objc(MlKitBarcodeScannerPlugin)
public class MlKitBarcodeScannerPlugin: CAPPlugin, CameraViewControllerDelegate {
    // call and settings are set when starting a scan
    // swiftlint:disable implicitly_unwrapped_optional
    private var call: CAPPluginCall!
    private var settings: ScannerSettings!
    // swiftlint:enable implicitly_unwrapped_optional
    private var player: AVAudioPlayer?

    @objc func scan(_ call: CAPPluginCall) {
        let options = call.jsObjectRepresentation
        self.call = call
        settings = ScannerSettings(options: options)

        DispatchQueue.main.async {
            let cameraViewController = CameraViewController(settings: self.settings)
            cameraViewController.delegate = self
            // we want to crash if we got here without either the capacitor bridge or the view controller being there
            // swiftlint:disable:next force_unwrapping
            self.bridge!.viewController!.present(cameraViewController, animated: true)
        }
    }

    func onComplete(_ result: [DetectedBarcode]) {
        weak var weakSelf = self
        DispatchQueue.main.sync {
            guard weakSelf != nil else {
                return
            }
            // we want to crash if we got here without either the capacitor bridge or the view controller being there
            // swiftlint:disable:next force_unwrapping
            self.bridge!.viewController!.dismiss(animated: true)
        }
        if result.isEmpty {
            self.call.reject("NO_BARCODE")
            return
        }
        if settings.vibrateOnSuccess {
            AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
        }
        if settings.beepOnSuccess {
            if let audioData = NSDataAsset(name: "beep")?.data {
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                    try AVAudioSession.sharedInstance().setActive(true)

                    player = try AVAudioPlayer(data: audioData)

                    if let unwrappedPlayer = player {
                        unwrappedPlayer.play()
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
        var resultBarcodes: [[String: Any]] = []
        for detectedBarcode in result {
            resultBarcodes.append(detectedBarcode.outputAsDictionary())
        }
        var output = JSObject()
        output.updateValue(resultBarcodes, forKey: "barcodes")
        self.call.resolve(output)
    }

    func onError(_ error: String) {
        print("error occurred")
        // we want to crash if we got here without either the capacitor bridge or the view controller being there
        // swiftlint:disable:next force_unwrapping
        self.bridge!.viewController!.dismiss(animated: false)
        print("controller dismissed")
        self.call.reject(error)
    }
}
