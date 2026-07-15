import { router } from '@kit.ArkUI';
import { picker, fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BackgroundStore } from '../data/BackgroundStore';
import {
  GRADIENT_PRESETS,
  IMAGE_PRESETS,
  IMAGE_PRESET_NAMES,
  GradientPreset,
  BACKGROUND_TYPE_NONE,
  BACKGROUND_TYPE_GRADIENT,
  BACKGROUND_TYPE_IMAGE_PRESET,
  BACKGROUND_TYPE_CUSTOM
} from '../model/BackgroundConfig';

const DOMAIN: number = 0x0000;
const TAG: string = 'BackgroundSettingsPage';

@Entry
@Component
struct BackgroundSettingsPage {
  @StorageLink('bgType') bgType: string = BACKGROUND_TYPE_NONE;
  @StorageLink('bgValue') bgValue: string = '';

  build() {
    Column() {
      Row() {
        Button('返回')
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .fontColor('#007AFF')
          .onClick(() => {
            router.back();
          })
        Blank()
        Text('背景设置')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('返回')
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .fontColor(Color.Transparent)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(Color.White)

      Scroll() {
        Column({ space: 16 }) {
          this.buildGradientSection();
          this.buildImagePresetSection();
          this.buildCustomSection();
          this.buildResetButton();
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 32 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .padding({ top: 36 })
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildGradientSection() {
    Column({ space: 10 }) {
      Row() {
        Text('🎨')
          .fontSize(16)
        Text('渐变色预设')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')
          .margin({ left: 6 })
      }
      .width('100%')

      Grid() {
        ForEach(GRADIENT_PRESETS, (preset: GradientPreset, index: number) => {
          GridItem() {
            Column({ space: 4 }) {
              Column()
                .width('100%')
                .height(70)
                .borderRadius(10)
                .linearGradient({
                  direction: preset.direction,
                  colors: preset.colors
                })
                .border({
                  width: this.bgType === BACKGROUND_TYPE_GRADIENT &&
                    this.bgValue === preset.id ? 2 : 0,
                  color: '#007AFF',
                  radius: 10
                })

              Text(preset.name)
                .fontSize(11)
                .fontColor('#666')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              hilog.info(DOMAIN, TAG, 'select gradient id=%{public}s current bgType=%{public}s bgValue=%{public}s',
                preset.id, this.bgType, this.bgValue);
              BackgroundStore.save(BACKGROUND_TYPE_GRADIENT, preset.id);
            })
          }
        }, (preset: GradientPreset, index: number) => preset.id)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(10)
      .rowsGap(12)
      .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Color.White)
    .borderRadius(10)
  }

  @Builder
  buildImagePresetSection() {
    Column({ space: 10 }) {
      Row() {
        Text('🖼️')
          .fontSize(16)
        Text('预设图片')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')
          .margin({ left: 6 })
      }
      .width('100%')

      Grid() {
        ForEach(IMAGE_PRESETS, (presetId: string, index: number) => {
          GridItem() {
            Column({ space: 4 }) {
              this.renderPresetThumbnail(presetId, index);
              Text(IMAGE_PRESET_NAMES[index])
                .fontSize(11)
                .fontColor('#666')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              hilog.info(DOMAIN, TAG, 'select imagePreset id=%{public}s current bgType=%{public}s bgValue=%{public}s',
                presetId, this.bgType, this.bgValue);
              BackgroundStore.save(BACKGROUND_TYPE_IMAGE_PRESET, presetId);
            })
          }
        }, (presetId: string, index: number) => presetId)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(10)
      .rowsGap(12)
      .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Color.White)
    .borderRadius(10)
  }

  @Builder
  renderPresetThumbnail(presetId: string, index: number) {
    Stack({ alignContent: Alignment.BottomEnd }) {
      if (presetId === 'bg_preset_1') {
        Image($r('app.media.bg_preset_1'))
          .width('100%').height(90)
          .objectFit(ImageFit.Cover)
          .borderRadius(10)
      } else if (presetId === 'bg_preset_2') {
        Image($r('app.media.bg_preset_2'))
          .width('100%').height(90)
          .objectFit(ImageFit.Cover)
          .borderRadius(10)
      } else if (presetId === 'bg_preset_3') {
        Image($r('app.media.bg_preset_3'))
          .width('100%').height(90)
          .objectFit(ImageFit.Cover)
          .borderRadius(10)
      } else {
        Image($r('app.media.bg_preset_4'))
          .width('100%').height(90)
          .objectFit(ImageFit.Cover)
          .borderRadius(10)
      }

      if (this.bgType === BACKGROUND_TYPE_IMAGE_PRESET &&
        this.bgValue === presetId) {
        Text('✓')
          .fontSize(14)
          .fontColor(Color.White)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .backgroundColor('#007AFF')
          .borderRadius(4)
          .margin({ right: 6, bottom: 6 })
      }
    }
    .width('100%')
    .height(90)
  }

  @Builder
  buildCustomSection() {
    Column({ space: 10 }) {
      Row() {
        Text('📷')
          .fontSize(16)
        Text('自定义背景')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')
          .margin({ left: 6 })
      }
      .width('100%')

      Button() {
        Row({ space: 8 }) {
          Text('📷')
            .fontSize(18)
          Text('从相册选择')
            .fontSize(14)
            .fontColor('#007AFF')
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
      }
      .type(ButtonType.Normal)
      .width('100%')
      .height(48)
      .backgroundColor('#F0F6FF')
      .borderRadius(10)
      .border({
        width: this.bgType === BACKGROUND_TYPE_CUSTOM ? 2 : 0,
        color: '#007AFF',
        radius: 10
      })
      .onClick(() => {
        this.pickCustomImage();
      })

      if (this.bgType === BACKGROUND_TYPE_CUSTOM && this.bgValue !== '') {
        Text('已设置自定义背景')
          .fontSize(12)
          .fontColor('#34C759')
          .width('100%')
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Color.White)
    .borderRadius(10)
  }

  @Builder
  buildResetButton() {
    Button('恢复默认背景')
      .type(ButtonType.Normal)
      .width('100%')
      .height(44)
      .fontSize(14)
      .fontColor('#FF3B30')
      .backgroundColor('#FFF0EF')
      .borderRadius(10)
      .onClick(() => {
        hilog.info(DOMAIN, TAG, 'reset background current bgType=%{public}s bgValue=%{public}s',
          this.bgType, this.bgValue);
        BackgroundStore.reset();
      })
  }

  async pickCustomImage(): Promise<void> {
    try {
      const options = new picker.PhotoSelectOptions();
      options.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      options.maxSelectNumber = 1;
      const photoPicker = new picker.PhotoViewPicker();
      const result: picker.PhotoSelectResult = await photoPicker.select(options);
      if (result.photoUris.length === 0) {
        return;
      }
      const uri: string = result.photoUris[0];
      const context = getContext(this) as common.UIAbilityContext;
      const destPath: string = `${context.filesDir}/bg_custom.jpg`;

      const srcFile: fs.File = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      const stat: fs.Stat = fs.statSync(srcFile.fd);
      const buf = new ArrayBuffer(stat.size);
      fs.readSync(srcFile.fd, buf);
      fs.closeSync(srcFile);

      const destFile: fs.File = fs.openSync(
        destPath,
        fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC
      );
      fs.writeSync(destFile.fd, buf);
      fs.closeSync(destFile);

      const imageUri: string = `file://${destPath}`;
      hilog.info(DOMAIN, TAG, 'custom image copied uri=%{public}s size=%{public}d', imageUri, stat.size);
      await BackgroundStore.save(BACKGROUND_TYPE_CUSTOM, imageUri);
    } catch (err) {
      console.error('[BackgroundSettingsPage] pickCustomImage failed',
        (err as BusinessError).message);
    }
  }
}
