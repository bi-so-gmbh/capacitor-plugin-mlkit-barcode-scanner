import MLKitBarcodeScanning

class DetectedBarcode: Hashable, Equatable, CustomDebugStringConvertible {

    var debugDescription: String {
        var des: String = "\(type(of: self)) {"
        for child in Mirror(reflecting: self).children {
            if let propName = child.label {
                des += "\n\t\(propName): \(child.value)"
            }
        }

        return des + "\n}"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        hasher.combine(barcodeType)
        hasher.combine(format)
        _ = hasher.finalize()
    }

    static func == (lhs: DetectedBarcode, rhs: DetectedBarcode) -> Bool {
        return lhs.value.elementsEqual(rhs.value) && lhs.barcodeType == rhs.barcodeType && lhs.format == rhs.format
    }

    private(set) var bounds: CGRect
    private(set) var value: String
    private(set) var format: Int
    private(set) var barcodeType: Int
    private(set) var distanceToCenter: CGFloat
    private(set) var isPortrait: Bool

    init(barcode: Barcode, bounds: CGRect, centerX: CGFloat, centerY: CGFloat) {
        format = barcode.format.rawValue
        barcodeType = barcode.valueType.rawValue
        self.bounds = bounds
        if let rawValue = barcode.rawValue {
            value = rawValue
        } else {
            value = String(data: barcode.rawData!, encoding: .ascii)!
        }
        self.isPortrait = bounds.height > bounds.width
        distanceToCenter = hypot((centerX - bounds.midX), (centerY - bounds.midY))
    }

    func isInScanArea(scanArea: CGRect, ignoreRotated: Bool) -> Bool {
        if ignoreRotated && isPortrait {
            return false
        }

        return scanArea.contains(getCenterLine(forceScreenOrientation: ignoreRotated))
    }

    func getCenterLine(forceScreenOrientation: Bool = false) -> CGRect {
        if !forceScreenOrientation && isPortrait {
            return CGRect(x: bounds.midX, y: bounds.minY, width: 1, height: bounds.height)
        }
        return CGRect(x: bounds.minX, y: bounds.midY, width: bounds.width, height: 1)
    }

    func outputAsDictionary() -> [String: Any] {
        return [
            "value": value,
            "type": BarcodeType.getFromInt(intValue: barcodeType)!.rawValue,
            "format": BarcodeFormat.getFromInt(intValue: format)!.rawValue,
            "distanceToCenter": round(distanceToCenter*100)/100.0
        ]
    }
}
