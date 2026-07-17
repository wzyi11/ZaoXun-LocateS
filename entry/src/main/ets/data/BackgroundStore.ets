import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import {
  BACKGROUND_TYPE_NONE,
  BACKGROUND_TYPE_GRADIENT,
  BACKGROUND_TYPE_IMAGE_PRESET,
  BACKGROUND_TYPE_CUSTOM
} from '../model/BackgroundConfig';

const DOMAIN: number = 0x0000;
const TAG: string = 'BackgroundStore';
const STORE_NAME: string = 'app_settings';
const KEY_BG_TYPE: string = 'bg_type';
const KEY_BG_VALUE: string = 'bg_value';
const APP_STORAGE_BG_TYPE: string = 'bgType';
const APP_STORAGE_BG_VALUE: string = 'bgValue';

export class BackgroundStore {
  private static store: preferences.Preferences | undefined = undefined;

  static init(context: common.UIAbilityContext): void {
    BackgroundStore.store = preferences.getPreferencesSync(context, { name: STORE_NAME });
    const bgType: string = BackgroundStore.store.getSync(KEY_BG_TYPE, BACKGROUND_TYPE_NONE) as string;
    const bgValue: string = BackgroundStore.store.getSync(KEY_BG_VALUE, '') as string;
    hilog.info(DOMAIN, TAG, 'init bgType=%{public}s bgValue=%{public}s', bgType, bgValue);
    AppStorage.setOrCreate(APP_STORAGE_BG_TYPE, bgType);
    AppStorage.setOrCreate(APP_STORAGE_BG_VALUE, bgValue);
  }

  static async save(type: string, value: string): Promise<void> {
    const s: preferences.Preferences | undefined = BackgroundStore.store;
    hilog.info(DOMAIN, TAG, 'save requested type=%{public}s value=%{public}s storeReady=%{public}s',
      type, value, s === undefined ? 'false' : 'true');
    if (s === undefined) {
      return;
    }
    s.putSync(KEY_BG_TYPE, type);
    s.putSync(KEY_BG_VALUE, value);
    AppStorage.setOrCreate(APP_STORAGE_BG_VALUE, value);
    AppStorage.setOrCreate(APP_STORAGE_BG_TYPE, type);
    await s.flush();
    hilog.info(DOMAIN, TAG, 'save applied appStorage bgType=%{public}s bgValue=%{public}s',
      AppStorage.get<string>(APP_STORAGE_BG_TYPE) ?? '', AppStorage.get<string>(APP_STORAGE_BG_VALUE) ?? '');
  }

  static async reset(): Promise<void> {
    await BackgroundStore.save(BACKGROUND_TYPE_NONE, '');
  }

  static getCurrentType(): string {
    return AppStorage.get<string>(APP_STORAGE_BG_TYPE) ?? BACKGROUND_TYPE_NONE;
  }

  static getCurrentValue(): string {
    return AppStorage.get<string>(APP_STORAGE_BG_VALUE) ?? '';
  }
}
