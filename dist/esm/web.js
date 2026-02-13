import { WebPlugin } from '@capacitor/core';
export class MlKitBarcodeScannerWeb extends WebPlugin {
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    async scan(_settings) {
        return Promise.reject(new Error('PLATFORM_NOT_SUPPORTED'));
    }
}
//# sourceMappingURL=web.js.map