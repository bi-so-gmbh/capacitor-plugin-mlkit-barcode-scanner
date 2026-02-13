export interface MlKitBarcodeScannerPlugin {
  /**
   * Opens a camera preview for barcode scanning and automatically detects barcodes in the scan area.
   * In case of unsuccessful scan the reason is thrown as an error.
   *
   * __Possible errors:__
   *   * CANCELED
   *   * NO_CAMERA
   *   * NO_CAMERA_PERMISSION
   *   * JSON_EXCEPTION
   *   * PLATFORM_NOT_SUPPORTED
   * @param settings{ISettings} settings to be used for the scan
   */
  scan(settings: ISettings): Promise<IResult>
}

/**
 * Options to make it possible to narrow down the barcode types scanned.
 */
export interface IBarcodeFormats {
  Aztec: boolean
  CodaBar: boolean
  Code39: boolean
  Code93: boolean
  Code128: boolean
  DataMatrix: boolean
  EAN8: boolean
  EAN13: boolean
  ITF: boolean
  PDF417: boolean
  QRCode: boolean
  UPCA: boolean
  UPCE: boolean
}

/**
 * All settings that can be passed to the plugin. The `detectorSize` value must be between
 * `0` and `1`, because it determines how many percent of the screen should be covered by
 * the detector.
 * If the value is greater than 1 the detector will not be visible on the screen.
 */
export interface ISettings {
  barcodeFormats?: IBarcodeFormats
  beepOnSuccess?: boolean
  vibrateOnSuccess?: boolean
  detectorSize?: number
  detectorAspectRatio?: string
  drawFocusRect?: boolean
  focusRectColor?: string
  focusRectBorderRadius?: number
  focusRectBorderThickness?: number
  drawFocusLine?: boolean
  focusLineColor?: string
  focusLineThickness?: number
  drawFocusBackground?: boolean
  focusBackgroundColor?: string
  stableThreshold?: number
  debugOverlay?: boolean
}

/**
 * The result of the plugin is an object with a list of detected barcodes, sorted by
 * distanceToCenter with the lowest value being first. DistanceToCenter is calculated by how
 * far away the center of the barcode is from the center of the scan area.
 */
export interface IResult {
  barcodes: [
    {
      value: string
      format: string
      type: string
      distanceToCenter: number
    }
  ]
}
