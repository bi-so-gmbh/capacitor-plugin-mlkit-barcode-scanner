import { WebPlugin } from '@capacitor/core';
export class MLKitBarcodeScannerWeb extends WebPlugin {
    async scan(_settings) {
        return Promise.reject(new Error("PLATFORM_NOT_SUPPORTED"));
    }
}
//# sourceMappingURL=web.js.map