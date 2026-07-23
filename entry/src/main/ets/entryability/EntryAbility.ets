import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { Database } from '../data/Database';
import { CalendarService } from '../data/CalendarService';
import { BackgroundStore } from '../data/BackgroundStore';
import { seedDataIfEmpty } from '../data/SeedData';
import {
  BACKGROUND_TYPE_GRADIENT,
  BACKGROUND_TYPE_NONE,
} from '../model/BackgroundConfig';
import { ENABLE_DEV_MODE } from '../model/DevMode';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 初始化数据库（await确保表创建完成后再加载页面）
    try {
      await Database.getInstance().init(this.context);
      if (ENABLE_DEV_MODE) {
        await seedDataIfEmpty();
      }
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to init database. Cause: %{public}s', JSON.stringify(err));
    }

    // 初始化日历服务
    try {
      await CalendarService.getInstance().init(this.context);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to init calendar service. Cause: %{public}s', JSON.stringify(err));
    }

    // 初始化背景配置
    BackgroundStore.init(this.context);
    if (AppStorage.get<string>('bgType') === BACKGROUND_TYPE_NONE) {
      AppStorage.setOrCreate('bgType', BACKGROUND_TYPE_GRADIENT);
      AppStorage.setOrCreate('bgValue', 'twilight');
    }

    // Configure immersive window for blur effects
    windowStage.getMainWindow().then((mainWindow) => {
      mainWindow.setWindowLayoutFullScreen(true);
      try {
        const naviArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        AppStorage.setOrCreate('naviIndicatorHeight', naviArea.bottomRect.height);
      } catch (err) { /* ignore */ }
      try {
        const sysArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        AppStorage.setOrCreate('statusBarHeight', sysArea.topRect.height);
      } catch (err) { /* ignore */ }
    }).catch((err: Error) => {
      hilog.error(DOMAIN, 'testTag', 'Failed to set immersive window. Cause: %{public}s', JSON.stringify(err));
    });

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
