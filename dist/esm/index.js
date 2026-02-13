import { registerPlugin } from '@capacitor/core';
const MlKitBarcodeScanner = registerPlugin('MlKitBarcodeScanner', {
    web: () => import('./web').then((m) => new m.MlKitBarcodeScannerWeb()),
});
export * from './definitions';
export { MlKitBarcodeScanner };
//# sourceMappingURL=index.js.map