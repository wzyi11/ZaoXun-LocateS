import { hilog } from '@kit.PerformanceAnalysisKit';
import {
  BACKGROUND_TYPE_NONE,
  BACKGROUND_TYPE_GRADIENT,
  BACKGROUND_TYPE_IMAGE_PRESET,
  BACKGROUND_TYPE_CUSTOM
} from '../model/BackgroundConfig';

const DOMAIN: number = 0x0000;
const TAG: string = 'PageBackground';

@Component
export struct PageBackground {
  @StorageLink('bgType') @Watch('onBackgroundChanged') bgType: string = BACKGROUND_TYPE_NONE;
  @StorageLink('bgValue') @Watch('onBackgroundChanged') bgValue: string = '';

  aboutToAppear(): void {
    this.logBackgroundState('appear');
  }

  onBackgroundChanged(): void {
    this.logBackgroundState('changed');
  }

  private logBackgroundState(stage: string): void {
    hilog.info(DOMAIN, TAG, '%{public}s bgType=%{public}s bgValue=%{public}s customSource=%{public}s',
      stage, this.bgType, this.bgValue, this.bgType === BACKGROUND_TYPE_CUSTOM ? this.getCustomImageSource() : '');
  }

  build() {
    Stack() {
      if (this.bgType === BACKGROUND_TYPE_GRADIENT) {
        if (this.bgValue === 'sunrise') {
          Column()
            .width('100%').height('100%')
            .linearGradient({
              direction: GradientDirection.LeftTop,
              colors: [['#FF9A9E', 0.0], ['#FAD0C4', 1.0]]
            })
        } else if (this.bgValue === 'ocean') {
          Column()
            .width('100%').height('100%')
            .linearGradient({
              direction: GradientDirection.Top,
              colors: [['#4FACFE', 0.0], ['#00F2FE', 1.0]]
            })
        } else if (this.bgValue === 'forest') {
          Column()
            .width('100%').height('100%')
            .linearGradient({
              direction: GradientDirection.LeftTop,
              colors: [['#11998E', 0.0], ['#38EF7D', 1.0]]
            })
        } else if (this.bgValue === 'sakura') {
          Column()
            .width('100%').height('100%')
            .linearGradient({
              direction: GradientDirection.Top,
              colors: [['#F093FB', 0.0], ['#F5576C', 1.0]]
            })
        } else if (this.bgValue === 'twilight') {
          Column()
            .width('100%').height('100%')
            .linearGradient({
              direction: GradientDirection.LeftTop,
              colors: [['#A18CD1', 0.0], ['#FBC2EB', 1.0]]
            })
        } else if (this.bgValue === 'aurora') {
          Column()
            .width('100%').height('100%')
            .linearGradient({
              direction: GradientDirection.Top,
              colors: [['#0BA360', 0.0], ['#3CBA92', 1.0]]
            })
        } else {
          Column()
            .width('100%').height('100%')
            .backgroundColor('#F5F5F5')
        }
      } else if (this.bgType === BACKGROUND_TYPE_IMAGE_PRESET) {
        if (this.bgValue === 'bg_default') {
          Image($r('app.media.bg_default'))
            .width('100%').height('100%')
            .objectFit(ImageFit.Cover)
        } else if (this.bgValue === 'bg_preset_1') {
          Image($r('app.media.bg_preset_1'))
            .width('100%').height('100%')
            .objectFit(ImageFit.Cover)
        } else if (this.bgValue === 'bg_preset_2') {
          Image($r('app.media.bg_preset_2'))
            .width('100%').height('100%')
            .objectFit(ImageFit.Cover)
        } else if (this.bgValue === 'bg_preset_3') {
          Image($r('app.media.bg_preset_3'))
            .width('100%').height('100%')
            .objectFit(ImageFit.Cover)
        } else if (this.bgValue === 'bg_preset_4') {
          Image($r('app.media.bg_preset_4'))
            .width('100%').height('100%')
            .objectFit(ImageFit.Cover)
        } else {
          Column()
            .width('100%').height('100%')
            .backgroundColor('#F5F5F5')
        }
      } else if (this.bgType === BACKGROUND_TYPE_CUSTOM) {
        Image(this.getCustomImageSource())
          .width('100%').height('100%')
          .objectFit(ImageFit.Cover)
      }

      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.bgType === BACKGROUND_TYPE_NONE ? '#F5F5F5' : 'rgba(245, 245, 245, 0.8)')
    }
    .width('100%')
    .height('100%')
  }

  private getCustomImageSource(): string {
    if (this.bgValue.length === 0) {
      return '';
    }
    if (this.bgValue.startsWith('file://') || this.bgValue.startsWith('dataability://') ||
      this.bgValue.startsWith('http://') || this.bgValue.startsWith('https://')) {
      return this.bgValue;
    }
    if (this.bgValue.startsWith('/')) {
      return `file://${this.bgValue}`;
    }
    return this.bgValue;
  }
}
