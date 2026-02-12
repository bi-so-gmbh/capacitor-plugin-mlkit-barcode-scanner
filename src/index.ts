import { registerPlugin } from '@capacitor/core'

import type { MlKitBarcodeScannerPlugin } from './definitions'

const MlKitBarcodeScanner = registerPlugin<MlKitBarcodeScannerPlugin>('MlKitBarcodeScanner', {
  web: () => import('./web').then((m) => new m.MlKitBarcodeScannerWeb()),
})

export * from './definitions'
export { MlKitBarcodeScanner }
