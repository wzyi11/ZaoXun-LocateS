import { router } from '@kit.ArkUI';
import { Space } from '../model/SpaceModel';
import { SpaceRepository } from '../data/SpaceRepository';
import { centerImageOffset, clampImageOffset, normalizeImagePoint } from '../model/ImageDragModel';

@Entry
@Component
struct SpaceImagePreviewPage {
  @State rootSpace: Space | null = null;
  @State sections: Space[] = [];
  @State loading: boolean = true;
  @State pendingMarkerX: number = -1;
  @State pendingMarkerY: number = -1;
  @State showAddDialog: boolean = false;
  @State newSectionName: string = '';
  @State imageNatW: number = 1;
  @State imageNatH: number = 1;
  @State availableW: number = 360;
  @State availableH: number = 600;
  @State displayW: number = 360;
  @State displayH: number = 600;
  @State imageOffsetX: number = 0;
  @State imageOffsetY: number = 0;
  @State dragStartOffsetX: number = 0;
  @State dragStartOffsetY: number = 0;
  @State touchStartWindowX: number = 0;
  @State touchStartWindowY: number = 0;
  @State isImageDragging: boolean = false;
  @State hasCenteredImage: boolean = false;
  private spaceRepo: SpaceRepository = new SpaceRepository();
  private imageLongPressTimer: number = -1;

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

  hasPendingMarker(): boolean {
    return this.pendingMarkerX >= 0 && this.pendingMarkerY >= 0;
  }

  setPendingMarkerFullscreen(event: ClickEvent): void {
    const rawX: number = Number(event.x);
    const rawY: number = Number(event.y);
    const x: number = normalizeImagePoint(rawX, 0, this.displayW, 0.06, 0.94);
    const y: number = normalizeImagePoint(rawY, 0, this.displayH, 0.08, 0.92);
    this.pendingMarkerX = x;
    this.pendingMarkerY = y;
  }

  setPendingMarkerFromGesture(event: GestureEvent): void {
    if (event.fingerList.length <= 0) {
      return;
    }
    const rawX: number = event.fingerList[0].localX;
    const rawY: number = event.fingerList[0].localY;
    const x: number = normalizeImagePoint(rawX, 0, this.displayW, 0.06, 0.94);
    const y: number = normalizeImagePoint(rawY, 0, this.displayH, 0.08, 0.92);
    this.pendingMarkerX = x;
    this.pendingMarkerY = y;
  }

  clearPendingMarker(): void {
    this.pendingMarkerX = -1;
    this.pendingMarkerY = -1;
  }

  async addSection(): Promise<void> {
    const name: string = this.newSectionName.trim();
    if (name === '' || this.rootSpace === null) {
      return;
    }
    const SECTION_COLORS: string[] = ['#5B8DEF', '#7ED957', '#F59A2A', '#B06CFF', '#F45B69'];
    await this.spaceRepo.insert({
      name: name,
      parentId: this.rootSpace.id,
      level: 2,
      icon: '📍',
      image: '',
      markerX: this.pendingMarkerX,
      markerY: this.pendingMarkerY,
      markerColor: SECTION_COLORS[this.sections.length % SECTION_COLORS.length],
    });
    this.newSectionName = '';
    this.showAddDialog = false;
    this.clearPendingMarker();
    await this.loadPreview();
    AppStorage.setOrCreate('spaceRefreshToken', Date.now());
  }

  recalcDisplay(): void {
    if (this.imageNatW <= 0 || this.imageNatH <= 0 || this.availableW <= 0 || this.availableH <= 0) {
      return;
    }
    const imageRatio: number = this.imageNatW / this.imageNatH;
    const screenRatio: number = this.availableW / this.availableH;
    if (imageRatio > screenRatio) {
      this.displayH = this.availableH;
      this.displayW = this.availableH * imageRatio;
    } else {
      this.displayW = this.availableW;
      this.displayH = this.availableW / imageRatio;
    }
    if (!this.hasCenteredImage) {
      this.centerImage();
    } else {
      this.clampImageOffsets();
    }
  }

  centerImage(): void {
    this.imageOffsetX = centerImageOffset(this.availableW, this.displayW);
    this.imageOffsetY = centerImageOffset(this.availableH, this.displayH);
    this.hasCenteredImage = true;
  }

  clampImageOffsets(): void {
    this.imageOffsetX = clampImageOffset(this.imageOffsetX, this.availableW, this.displayW);
    this.imageOffsetY = clampImageOffset(this.imageOffsetY, this.availableH, this.displayH);
  }

  startImageDrag(): void {
    this.dragStartOffsetX = this.imageOffsetX;
    this.dragStartOffsetY = this.imageOffsetY;
  }

  updateImageDrag(event: GestureEvent): void {
    this.imageOffsetX = clampImageOffset(
      this.dragStartOffsetX + Number(event.offsetX),
      this.availableW,
      this.displayW
    );
    this.imageOffsetY = clampImageOffset(
      this.dragStartOffsetY + Number(event.offsetY),
      this.availableH,
      this.displayH
    );
  }

  clearImageLongPressTimer(): void {
    if (this.imageLongPressTimer >= 0) {
      clearTimeout(this.imageLongPressTimer);
      this.imageLongPressTimer = -1;
    }
  }

  onPreviewImageTouch(event: TouchEvent): void {
    if (event.type === TouchType.Down && event.touches.length > 0) {
      const touch: TouchObject = event.touches[0];
      this.touchStartWindowX = touch.windowX;
      this.touchStartWindowY = touch.windowY;
      this.startImageDrag();
      this.isImageDragging = false;
      this.clearImageLongPressTimer();
      this.imageLongPressTimer = setTimeout(() => {
        this.isImageDragging = true;
      }, 450);
      return;
    }

    if (event.type === TouchType.Move && event.touches.length > 0 && this.isImageDragging) {
      const touch: TouchObject = event.touches[0];
      this.imageOffsetX = clampImageOffset(
        this.dragStartOffsetX + touch.windowX - this.touchStartWindowX,
        this.availableW,
        this.displayW
      );
      this.imageOffsetY = clampImageOffset(
        this.dragStartOffsetY + touch.windowY - this.touchStartWindowY,
        this.availableH,
        this.displayH
      );
      return;
    }

    if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      this.clearImageLongPressTimer();
      this.isImageDragging = false;
    }
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

        Stack({ alignContent: Alignment.TopStart }) {
          Stack({ alignContent: Alignment.TopStart }) {
            Image(this.getPreviewImage())
              .width(this.displayW)
              .height(this.displayH)
              .objectFit(ImageFit.Contain)
              .onComplete((event) => {
                if (event && event.width > 0 && event.height > 0) {
                  if (Math.abs(event.width - this.imageNatW) > 1 || Math.abs(event.height - this.imageNatH) > 1) {
                    this.imageNatW = event.width;
                    this.imageNatH = event.height;
                    this.hasCenteredImage = false;
                    this.recalcDisplay();
                  }
                }
              })

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

            if (this.hasPendingMarker()) {
              Button() {
                Text('+')
                  .fontSize(16)
                  .fontColor('#111')
              }
              .width(28)
              .height(28)
              .borderRadius(14)
              .backgroundColor(Color.White)
              .shadow({ radius: 4, color: '#33000000', offsetY: 2 })
              .position({ x: `${this.pendingMarkerX * 100}%`, y: `${this.pendingMarkerY * 100}%` })
              .markAnchor({ x: '50%', y: '50%' })
              .onClick(() => {
                this.showAddDialog = true;
              })
            }
          }
          .width(this.displayW)
          .height(this.displayH)
          .translate({ x: this.imageOffsetX, y: this.imageOffsetY })
          .onTouch((event: TouchEvent) => {
            this.onPreviewImageTouch(event);
          })
          .gesture(TapGesture({ count: 1 })
            .onAction((event: GestureEvent) => {
              this.setPendingMarkerFromGesture(event);
            }))
        }
        .width('100%')
        .layoutWeight(1)
        .onAreaChange((oldValue: Area, newValue: Area) => {
          const nextW: number = Number(newValue.width);
          const nextH: number = Number(newValue.height);
          if (nextW <= 0 || nextH <= 0) {
            return;
          }
          if (Math.abs(nextW - this.availableW) > 1 || Math.abs(nextH - this.availableH) > 1) {
            this.availableW = nextW;
            this.availableH = nextH;
            this.hasCenteredImage = false;
            this.recalcDisplay();
          }
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#33000000')

      if (this.showAddDialog) {
        this.AddDialog()
      }
    }
    .width('100%')
    .height('100%')
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
  }

  @Builder
  AddDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#66000000')
        .onClick(() => {
          this.showAddDialog = false;
          this.newSectionName = '';
          this.clearPendingMarker();
        })

      Column({ space: 16 }) {
        Text('新增分区')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
        TextInput({ text: this.newSectionName, placeholder: '输入分区名称' })
          .onChange((value: string) => {
            this.newSectionName = value;
          })
        Row({ space: 12 }) {
          Button('取消')
            .type(ButtonType.Normal)
            .fontColor('#999')
            .backgroundColor('#F0F0F0')
            .layoutWeight(1)
            .onClick(() => {
              this.showAddDialog = false;
              this.newSectionName = '';
              this.clearPendingMarker();
            })
          Button('确认')
            .type(ButtonType.Normal)
            .fontColor(Color.White)
            .backgroundColor('#007AFF')
            .layoutWeight(1)
            .onClick(() => {
              this.addSection();
            })
        }
        .width('100%')
      }
      .width('80%')
      .padding(20)
      .backgroundColor(Color.White)
      .borderRadius(12)
    }
    .width('100%')
    .height('100%')
  }
}
