import MLKitBarcodeScanning

public enum BarcodeType: String, CaseIterable {
    // swiftlint:disable identifier_name
    case UNKNOWN
    case CONTACT_INFO
    case EMAIL
    case ISBN
    case PHONE
    case PRODUCT
    case SMS
    case TEXT
    case URL
    case WIFI
    case GEO
    case CALENDAR_EVENT
    case DRIVER_LICENSE
    // swiftlint:enable identifier_name

    var asInt: Int {
        switch self {
        case BarcodeType.UNKNOWN: return MLKitBarcodeScanning.BarcodeValueType.unknown.rawValue
        case BarcodeType.CONTACT_INFO: return MLKitBarcodeScanning.BarcodeValueType.contactInfo.rawValue
        case BarcodeType.EMAIL: return MLKitBarcodeScanning.BarcodeValueType.email.rawValue
        case BarcodeType.ISBN: return MLKitBarcodeScanning.BarcodeValueType.ISBN.rawValue
        case BarcodeType.PHONE: return MLKitBarcodeScanning.BarcodeValueType.phone.rawValue
        case BarcodeType.PRODUCT: return MLKitBarcodeScanning.BarcodeValueType.product.rawValue
        case BarcodeType.SMS: return MLKitBarcodeScanning.BarcodeValueType.SMS.rawValue
        case BarcodeType.TEXT: return MLKitBarcodeScanning.BarcodeValueType.text.rawValue
        case BarcodeType.URL: return MLKitBarcodeScanning.BarcodeValueType.URL.rawValue
        case BarcodeType.WIFI: return MLKitBarcodeScanning.BarcodeValueType.wiFi.rawValue
        case BarcodeType.GEO: return MLKitBarcodeScanning.BarcodeValueType.geographicCoordinates.rawValue
        case BarcodeType.CALENDAR_EVENT: return MLKitBarcodeScanning.BarcodeValueType.calendarEvent.rawValue
        case BarcodeType.DRIVER_LICENSE: return MLKitBarcodeScanning.BarcodeValueType.driversLicense.rawValue
        }
    }

    static func getFromInt(intValue: Int) -> BarcodeType? {
        for barcodeType in BarcodeType.allCases where barcodeType.asInt == intValue {
            return barcodeType
        }
        print("no BarcodeType found for value ", intValue)
        return nil
    }
}
