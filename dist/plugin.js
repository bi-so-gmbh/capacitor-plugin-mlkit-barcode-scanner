var BisoGmbhCapacitorPluginMlKitBarcodeScanner = (function (exports, core) {
    'use strict';

    const MlKitBarcodeScanner = core.registerPlugin('MlKitBarcodeScanner', {
        web: () => Promise.resolve().then(function () { return web; }).then((m) => new m.MlKitBarcodeScannerWeb()),
    });

    class MlKitBarcodeScannerWeb extends core.WebPlugin {
        // eslint-disable-next-line @typescript-eslint/no-unused-vars
        async scan(_settings) {
            return Promise.reject(new Error('PLATFORM_NOT_SUPPORTED'));
        }
    }

    var web = /*#__PURE__*/Object.freeze({
        __proto__: null,
        MlKitBarcodeScannerWeb: MlKitBarcodeScannerWeb
    });

    exports.MlKitBarcodeScanner = MlKitBarcodeScanner;

    return exports;

})({}, capacitorExports);
//# sourceMappingURL=plugin.js.map
