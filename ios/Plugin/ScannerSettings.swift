import UIKit
import MLKitBarcodeScanning

class ScannerSettings: CustomDebugStringConvertible {
    var debugDescription: String {
        var des: String = "\(type(of: self)) {"
        for child in Mirror(reflecting: self).children {
            if let propName = child.label {
                des += "\n\t\(propName): \(child.value)"
            }
        }

        return des + "\n}"
    }

    // swiftlint:disable identifier_name
    // on android lines are much thinner, this evens out the look and feel
    private static let LINE_THICKNESS_ADJUSTMENT = -3
    // same with corner radius, way less pronounced on android
    private static var CORNER_RADIUS_ADJUSTMENT = -5
    // swiftlint:enable identifier_name

    private(set) var barcodeFormats: Int = 0
    private(set) var aspectRatio: String = "1:1"
    private(set) var aspectRatioF: Float
    private(set) var detectorSize: Double = 0.5
    private(set) var drawFocusRect: Bool = true
    private(set) var focusRectColor: String = "#FFFFFF"
    private(set) var focusRectUIColor: UIColor
    private(set) var focusRectBorderRadius: Int = 100
    private(set) var focusRectBorderThickness: Int = 2
    private(set) var drawFocusLine: Bool = true
    private(set) var focusLineColor: String = "#FFFFFF"
    private(set) var focusLineUIColor: UIColor
    private(set) var focusLineThickness: Int = 1
    private(set) var drawFocusBackground: Bool = true
    private(set) var focusBackgroundColor: String = "#CCFFFFFF"
    private(set) var focusBackgroundUIColor: UIColor
    private(set) var beepOnSuccess: Bool = false
    private(set) var vibrateOnSuccess: Bool = false
    private(set) var stableThreshold: Int = 5
    private(set) var debugOverlay: Bool = false
    private(set) var ignoreRotatedBarcodes: Bool = false

    // swiftlint:disable:next cyclomatic_complexity
    init(options: [String: Any]) {
        var bFormats: [String: Any]
        if let unwrapped: [String: Any] = options[Settings.BARCODE_FORMATS] as? [String: Any] {
            bFormats = unwrapped
        } else {
            bFormats = [String: Any]()
        }
        let formats: BarcodeFormats = BarcodeFormats(barcodeFormats: bFormats)
        barcodeFormats = formats.getFormatFlags()

        for (key, value) in options {
            switch key {
            case Settings.BARCODE_FORMATS:
                break
            case Settings.DETECTOR_ASPECT_RATIO:
                if let temp = value as? String {
                    aspectRatio = temp
                }
            case Settings.DETECTOR_SIZE:
                if let temp = Utils.getDouble(input: value) {
                    detectorSize = temp
                }
            case Settings.DRAW_FOCUS_RECT:
                if let temp = value as? Bool {
                    drawFocusRect = temp
                }
            case Settings.FOCUS_RECT_COLOR:
                if let temp = value as? String {
                    focusRectColor = temp
                }
            case Settings.FOCUS_RECT_BORDER_RADIUS:
                if let temp = Utils.getInt(input: value) {
                    focusRectBorderRadius = max(1, temp + Self.CORNER_RADIUS_ADJUSTMENT)
                }
            case Settings.FOCUS_RECT_BORDER_THICKNESS:
                if let temp = Utils.getInt(input: value) {
                    focusRectBorderThickness = max(1, temp + Self.LINE_THICKNESS_ADJUSTMENT)
                }
            case Settings.DRAW_FOCUS_LINE:
                if let temp = value as? Bool {
                    drawFocusLine = temp
                }
            case Settings.FOCUS_LINE_COLOR:
                if let temp = value as? String {
                    focusLineColor = temp
                }
            case Settings.FOCUS_LINE_THICKNESS:
                if let temp = Utils.getInt(input: value) {
                    focusLineThickness = max(1, temp + Self.LINE_THICKNESS_ADJUSTMENT)
                }
            case Settings.DRAW_FOCUS_BACKGROUND:
                if let temp = value as? Bool {
                    drawFocusBackground = temp
                }
            case Settings.FOCUS_BACKGROUND_COLOR:
                if let temp = value as? String {
                    focusBackgroundColor = temp
                }
            case Settings.BEEP_ON_SUCCESS:
                if let temp = value as? Bool {
                    beepOnSuccess = temp
                }
            case Settings.VIBRATE_ON_SUCCESS:
                if let temp = value as? Bool {
                    vibrateOnSuccess = temp
                }
            case Settings.STABLE_THRESHOLD:
                if let temp = Utils.getInt(input: value) {
                    stableThreshold = temp
                }
            case Settings.DEBUG_OVERLAY:
                if let temp = value as? Bool {
                    debugOverlay = temp
                }
            case Settings.IGNORE_ROTATED_BARCODES:
                if let temp = value as? Bool {
                    ignoreRotatedBarcodes = temp
                }
            default:
                print("Unknown option: \(key)")
            }
        }

        focusRectUIColor = Utils.hexStringToUIColor(hex: focusRectColor)
        focusLineUIColor = Utils.hexStringToUIColor(hex: focusLineColor)
        focusBackgroundUIColor = Utils.hexStringToUIColor(hex: focusBackgroundColor)
        aspectRatioF = Utils.getAspectRatioFromString(aspectRatioString: aspectRatio)
    }

    convenience init() {
        self.init(options: [:])
    }
}

// swiftlint:disable identifier_name
private enum Settings {
    static let BARCODE_FORMATS: String = "barcodeFormats"
    static let DETECTOR_ASPECT_RATIO: String = "detectorAspectRatio"
    static let DETECTOR_SIZE: String = "detectorSize"
    static let DRAW_FOCUS_RECT: String = "drawFocusRect"
    static let FOCUS_RECT_COLOR: String = "focusRectColor"
    static let FOCUS_RECT_BORDER_RADIUS: String = "focusRectBorderRadius"
    static let FOCUS_RECT_BORDER_THICKNESS: String = "focusRectBorderThickness"
    static let DRAW_FOCUS_LINE: String = "drawFocusLine"
    static let FOCUS_LINE_COLOR: String = "focusLineColor"
    static let FOCUS_LINE_THICKNESS: String = "focusLineThickness"
    static let DRAW_FOCUS_BACKGROUND: String = "drawFocusBackground"
    static let FOCUS_BACKGROUND_COLOR: String = "focusBackgroundColor"
    static let BEEP_ON_SUCCESS: String = "beepOnSuccess"
    static let VIBRATE_ON_SUCCESS: String = "vibrateOnSuccess"
    static let STABLE_THRESHOLD: String = "stableThreshold"
    static let DEBUG_OVERLAY: String = "debugOverlay"
    static let IGNORE_ROTATED_BARCODES: String = "ignoreRotatedBarcodes"
}
// swiftlint:enable identifier_name
