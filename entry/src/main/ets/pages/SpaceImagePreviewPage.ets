import { router } from '@kit.ArkUI';
import { Space } from '../model/SpaceModel';
import { SpaceRepository } from '../data/SpaceRepository';

@Entry
@Component
struct SpaceImagePreviewPage {
  @State rootSpace: Space | null = null;
  @State sections: Space[] = [];
  @State loading: boolean = true;
  private spaceRepo: SpaceRepository = new SpaceRepository();

  aboutToAppear(): void {
    this.loadPreview();
  }

  async loadPreview(): Promise<void> {
    this.loading = true;
    const spaceId: number = AppStorage.get<number>('currentPreviewSpaceId') ?? 0;
    if (spaceId <= 0) {
      this.rootSpace = null;
      this.sections = [];
      this.loading = false;
      return;
    }
    const space: Space | null = await this.spaceRepo.getById(spaceId);
    this.rootSpace = space;
    this.sections = space ? await this.spaceRepo.getByParent(space.id) : [];
    this.loading = false;
  }

  getPreviewImage(): ResourceStr {
    if (this.rootSpace && this.rootSpace.image) {
      return this.rootSpace.image;
    }
    return $r('app.media.bg_preset_1');
  }

  openSection(section: Space): void {
    AppStorage.setOrCreate('spacePreviewTargetSectionId', section.id);
    router.back();
  }

  build() {
    Stack() {
      Image(this.getPreviewImage())
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Column() {
        Row() {
          Button() {
            Text('✕')
              .fontSize(20)
              .fontColor(Color.White)
          }
          .width(40)
          .height(40)
          .type(ButtonType.Circle)
          .backgroundColor('#66000000')
          .onClick(() => {
            router.back();
          })

          Blank()
        }
        .width('100%')
        .height(60)
        .padding({ left: 16, right: 16, top: 10 })

        Stack() {
          Image(this.getPreviewImage())
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)

          if (this.loading) {
            LoadingProgress()
              .width(36)
              .height(36)
              .color(Color.White)
          } else {
            ForEach(this.sections, (section: Space, index: number) => {
              Column({ space: 4 }) {
                Circle()
                  .width(28)
                  .height(28)
                  .fill(section.markerColor)
                  .strokeWidth(4)
                  .stroke('#66000000')
                Text(section.name)
                  .fontSize(12)
                  .fontColor(Color.White)
                  .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                  .backgroundColor('#99000000')
                  .borderRadius(6)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .position({ x: `${section.markerX * 100}%`, y: `${section.markerY * 100}%` })
              .markAnchor({ x: '50%', y: '50%' })
              .onClick(() => {
                this.openSection(section);
              })
            }, (section: Space, index: number) => section.id.toString())
          }
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#33000000')
    }
    .width('100%')
    .height('100%')
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
  }
}
