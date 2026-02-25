import MLKitBarcodeScanning

public enum BarcodeFormat: String, CaseIterable {
    // swiftlint:disable identifier_name
    case Code128
    case Code39
    case Code93
    case CodaBar
    case DataMatrix
    case EAN13
    case EAN8
    case ITF
    case QRCode
    case UPCA
    case UPCE
    case PDF417
    case Aztec
    // swiftlint:enable identifier_name

    var asInt: Int {
        switch self {
        case BarcodeFormat.Code128: return MLKitBarcodeScanning.BarcodeFormat.code128.rawValue
        case BarcodeFormat.Code39: return MLKitBarcodeScanning.BarcodeFormat.code39.rawValue
        case BarcodeFormat.Code93: return MLKitBarcodeScanning.BarcodeFormat.code93.rawValue
        case BarcodeFormat.CodaBar: return MLKitBarcodeScanning.BarcodeFormat.codaBar.rawValue
        case BarcodeFormat.DataMatrix: return MLKitBarcodeScanning.BarcodeFormat.dataMatrix.rawValue
        case BarcodeFormat.EAN13: return MLKitBarcodeScanning.BarcodeFormat.EAN13.rawValue
        case BarcodeFormat.EAN8: return MLKitBarcodeScanning.BarcodeFormat.EAN8.rawValue
        case BarcodeFormat.ITF: return MLKitBarcodeScanning.BarcodeFormat.ITF.rawValue
        case BarcodeFormat.QRCode: return MLKitBarcodeScanning.BarcodeFormat.qrCode.rawValue
        case BarcodeFormat.UPCA: return MLKitBarcodeScanning.BarcodeFormat.UPCA.rawValue
        case BarcodeFormat.UPCE: return MLKitBarcodeScanning.BarcodeFormat.UPCE.rawValue
        case BarcodeFormat.PDF417: return MLKitBarcodeScanning.BarcodeFormat.PDF417.rawValue
        case BarcodeFormat.Aztec: return MLKitBarcodeScanning.BarcodeFormat.aztec.rawValue
        }
    }

    static func getFromInt(intValue: Int) -> BarcodeFormat? {
        for barcodeFormat in BarcodeFormat.allCases {
            if barcodeFormat.asInt == intValue {
                return barcodeFormat
            }
        }
        print("no BarcodeFormat found for value ", intValue)
        return nil
    }
}
