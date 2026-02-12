import { WebPlugin } from '@capacitor/core'

import type { MlKitBarcodeScannerPlugin, ISettings, IResult } from './definitions'

export class MlKitBarcodeScannerWeb extends WebPlugin implements MlKitBarcodeScannerPlugin {
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  async scan(_settings: ISettings): Promise<IResult> {
    return Promise.reject(new Error('PLATFORM_NOT_SUPPORTED'))
  }
}
