import { router } from '@kit.ArkUI';
import { Space } from '../model/SpaceModel';
import { Item } from '../model/ItemModel';
import { SpaceRepository } from '../data/SpaceRepository';
import { ItemRepository } from '../data/ItemRepository';
import { EmptyState } from '../components/EmptyState';
import { camera, cameraPicker } from '@kit.CameraKit';
import { picker, fileIo as fs, fileUri } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

const SECTION_COLORS: string[] = ['#5B8DEF', '#7ED957', '#F59A2A', '#B06CFF', '#F45B69'];
const IMAGE_PANEL_WIDTH: number = 360;
const IMAGE_PANEL_HEIGHT: number = 260;
const IMAGE_SCROLL_HEIGHT: number = 520;

@Entry
@Component
export struct SpacePage {
  @State spaces: Space[] = [];
  @State items: Item[] = [];
  @State breadcrumb: Space[] = [];
  @State loading: boolean = true;
  @State showAddDialog: boolean = false;
  @State showFullscreenImage: boolean = false;
  @State fsImageWidth: number = 360;
  @State fsImageHeight: number = 780;
  @State showAddSheet: boolean = false;
  @State sheetKey: number = 0;
  @State selectedImageURI: string = '';
  @State selectedImageName: string = '';
  @State showSectionItemSheet: boolean = false;
  @State sectionItemSheetKey: number = 0;
  @State unassignedItems: Item[] = [];
  @State newSpaceName: string = '';
  @State pendingMarkerX: number = -1;
  @State pendingMarkerY: number = -1;
  @StorageLink('spaceRefreshToken') @Watch('onSpaceRefreshToken') spaceRefreshToken: number = 0;
  @StorageLink('itemRefreshToken') @Watch('onItemRefreshToken') itemRefreshToken: number = 0;
  private spaceRepo: SpaceRepository = new SpaceRepository();
  private itemRepo: ItemRepository = new ItemRepository();
  private scrollController: Scroller = new Scroller();

  aboutToAppear(): void {
    this.loadSpaces();
  }

  async onSpaceRefreshToken(): Promise<void> {
    if (this.spaceRefreshToken <= 0) {
      return;
    }
    if (this.isSectionPage()) {
      await this.loadItems(this.getParentId());
    } else {
      await this.loadSpaces();
    }
  }

  async onItemRefreshToken(): Promise<void> {
    if (this.itemRefreshToken <= 0 || !this.isSectionPage()) {
      return;
    }
    await this.loadItems(this.getParentId());
  }

  getParentId(): number {
    if (this.breadcrumb.length === 0) {
      return 0;
    }
    return this.breadcrumb[this.breadcrumb.length - 1].id;
  }

  isSpaceDetailPage(): boolean {
    return this.breadcrumb.length === 1;
  }

  isSectionPage(): boolean {
    return this.breadcrumb.length >= 2;
  }

  hasPendingMarker(): boolean {
    return this.pendingMarkerX >= 0 && this.pendingMarkerY >= 0;
  }

  getNavTitle(): string {
    if (this.breadcrumb.length === 0) {
      return '空间管理';
    }
    return this.breadcrumb[this.breadcrumb.length - 1].name;
  }

  async loadSpaces(): Promise<void> {
    this.loading = true;
    try {
      this.spaces = await this.spaceRepo.getByParent(this.getParentId());
    } catch (e) {
      this.spaces = [];
    }
    this.loading = false;
  }

  async loadItems(spaceId: number): Promise<void> {
    this.loading = true;
    try {
      this.items = await this.itemRepo.getBySpaceId(spaceId);
    } catch (e) {
      this.items = [];
    }
    this.loading = false;
  }

  async goBackOneLevel(): Promise<void> {
    if (this.breadcrumb.length === 0) {
      return;
    }
    this.breadcrumb = this.breadcrumb.slice(0, this.breadcrumb.length - 1);
    this.items = [];
    this.clearPendingMarker();
    if (this.isSectionPage()) {
      await this.loadItems(this.getParentId());
    } else {
      await this.loadSpaces();
    }
  }

  async onSpaceTap(space: Space): Promise<void> {
    this.breadcrumb = this.breadcrumb.concat([space]);
    this.clearPendingMarker();
    if (this.isSectionPage()) {
      await this.loadItems(space.id);
    } else {
      await this.loadSpaces();
    }
  }

  async onBreadcrumbTap(index: number): Promise<void> {
    if (index < 0) {
      this.breadcrumb = [];
      this.items = [];
      this.clearPendingMarker();
      await this.loadSpaces();
      return;
    }

    this.breadcrumb = this.breadcrumb.slice(0, index + 1);
    this.clearPendingMarker();
    if (this.isSectionPage()) {
      await this.loadItems(this.getParentId());
    } else {
      this.items = [];
      await this.loadSpaces();
    }
  }

  setPendingMarker(event: ClickEvent): void {
    const rawX: number = Number(event.x);
    const rawY: number = Number(event.y);
    const scrollOffset = this.scrollController.currentOffset();
    const offsetY: number = scrollOffset ? scrollOffset.yOffset : 0;
    const adjustedY: number = rawY + offsetY;
    const x: number = Math.max(0.06, Math.min(0.94, rawX / IMAGE_PANEL_WIDTH));
    const y: number = Math.max(0.08, Math.min(0.92, adjustedY / IMAGE_SCROLL_HEIGHT));
    this.pendingMarkerX = x;
    this.pendingMarkerY = y;
  }

  setPendingMarkerFullscreen(event: ClickEvent): void {
    const rawX: number = Number(event.x);
    const rawY: number = Number(event.y);
    const x: number = Math.max(0.06, Math.min(0.94, rawX / this.fsImageWidth));
    const y: number = Math.max(0.08, Math.min(0.92, rawY / this.fsImageHeight));
    this.pendingMarkerX = x;
    this.pendingMarkerY = y;
  }

  clearPendingMarker(): void {
    this.pendingMarkerX = -1;
    this.pendingMarkerY = -1;
  }

  async addSpace(): Promise<void> {
    const name: string = this.newSpaceName.trim();
    if (name === '') {
      return;
    }

    const parentId: number = this.getParentId();
    const level: number = this.breadcrumb.length === 0 ? 1 : 2;
    const markerX: number = level === 2 && this.hasPendingMarker() ? this.pendingMarkerX : 0.5;
    const markerY: number = level === 2 && this.hasPendingMarker() ? this.pendingMarkerY : 0.5;
    const markerColor: string = level === 2 ? this.getNextMarkerColor() : '#5B8DEF';

    try {
      const rowId: number = await this.spaceRepo.insert({
        name: name,
        parentId: parentId,
        level: level,
        icon: this.getIconForLevel(level),
        image: this.selectedImageURI,
        markerX: markerX,
        markerY: markerY,
        markerColor: markerColor,
      });

      this.newSpaceName = '';
      this.showAddDialog = false;
      this.showAddSheet = false;
      this.selectedImageURI = '';
      this.selectedImageName = '';
      this.clearPendingMarker();

      const created: Space = {
        id: rowId,
        name: name,
        parentId: parentId,
        level: level,
        icon: this.getIconForLevel(level),
        image: this.selectedImageURI,
        markerX: markerX,
        markerY: markerY,
        markerColor: markerColor,
      };
      this.spaces = this.spaces.concat([created]);
      this.loading = false;

      const refreshed: Space[] = await this.spaceRepo.getByParent(parentId);
      this.spaces = refreshed;
    } catch (err) {
      this.loading = false;
      console.error(`Add space failed: ${JSON.stringify(err)}`);
    }
  }

  getNextMarkerColor(): string {
    return SECTION_COLORS[this.spaces.length % SECTION_COLORS.length];
  }

  getIconForLevel(level: number): string {
    if (level === 1) {
      return '🏠';
    }
    return '📍';
  }

  getLevelLabel(): string {
    if (this.breadcrumb.length === 0) {
      return '空间';
    }
    return '分区';
  }

  openAddItemPage(): void {
    router.pushUrl({
      url: 'pages/AddItemPage',
      params: {
        spaceId: this.getParentId(),
      },
    });
  }

  resetSheetForm(): void {
    this.newSpaceName = '';
    this.selectedImageURI = '';
    this.selectedImageName = '';
  }

  async copyImageToAppDir(srcUri: string): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const fileName = `space_${Date.now()}.jpg`;
      const destPath = `${context.filesDir}/${fileName}`;
      const srcFile = fs.openSync(srcUri, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(srcFile.fd);
      const buf = new ArrayBuffer(stat.size);
      fs.readSync(srcFile.fd, buf);
      fs.closeSync(srcFile);
      const destFile = fs.openSync(destPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
      fs.writeSync(destFile.fd, buf);
      fs.closeSync(destFile);
      this.selectedImageURI = `file://${destPath}`;
      this.selectedImageName = fileName;
    } catch (err) {
      console.error(`copyImageToAppDir failed: ${JSON.stringify(err)}`);
    }
  }

  async takePhoto(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const fileName = `camera_${Date.now()}.jpg`;
      const filePath = `${context.filesDir}/${fileName}`;
      fs.createRandomAccessFileSync(filePath, fs.OpenMode.CREATE);
      const saveUri = fileUri.getUriFromPath(filePath);
      const pickerProfile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK,
        saveUri: saveUri
      };
      await cameraPicker.pick(
        getContext(this),
        [cameraPicker.PickerMediaType.PHOTO],
        pickerProfile
      );
      this.selectedImageURI = `file://${filePath}`;
      this.selectedImageName = fileName;
    } catch (err) {
      console.error(`takePhoto failed: ${JSON.stringify(err)}`);
    }
  }

  async pickFromAlbum(): Promise<void> {
    try {
      const options = new picker.PhotoSelectOptions();
      options.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      options.maxSelectNumber = 1;
      const photoPicker = new picker.PhotoViewPicker();
      const result = await photoPicker.select(options);
      if (result.photoUris.length > 0) {
        await this.copyImageToAppDir(result.photoUris[0]);
      }
    } catch (err) {
      console.error(`pickFromAlbum failed: ${JSON.stringify(err)}`);
    }
  }

  async loadUnassignedItems(): Promise<void> {
    try {
      this.unassignedItems = await this.itemRepo.getUnassigned();
    } catch (err) {
      this.unassignedItems = [];
      console.error(`loadUnassignedItems failed: ${JSON.stringify(err)}`);
    }
  }

  async assignItemToSection(itemId: number): Promise<void> {
    try {
      const item = await this.itemRepo.getById(itemId);
      if (item) {
        item.spaceId = this.getParentId();
        await this.itemRepo.update(item);
        await this.loadUnassignedItems();
        await this.loadItems(this.getParentId());
        AppStorage.setOrCreate('itemRefreshToken', Date.now());
        AppStorage.setOrCreate('spaceRefreshToken', Date.now());
      }
    } catch (err) {
      console.error(`assignItemToSection failed: ${JSON.stringify(err)}`);
    }
  }

  @Builder
  NavigationHeader() {
    Row() {
      if (this.breadcrumb.length > 0) {
        Button('‹ 返回')
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .fontColor('#007AFF')
          .fontSize(15)
          .padding({ left: 0, right: 8 })
          .onClick(() => {
            this.goBackOneLevel();
          })
          .width(72)
      } else {
        Blank()
          .width(72)
      }
      Text(this.getNavTitle())
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#222')
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
      Blank()
        .width(72)
    }
    .width('100%')
    .height(48)
    .padding({ left: 12, right: 12 })
    .backgroundColor(Color.White)
  }

  @Builder
  BreadcrumbBar() {
    if (this.breadcrumb.length > 0) {
      Flex({ wrap: FlexWrap.Wrap }) {
        Text('全部')
          .fontSize(13)
          .fontColor('#007AFF')
          .onClick(() => {
            this.onBreadcrumbTap(-1);
          })
        ForEach(this.breadcrumb, (space: Space, index: number) => {
          Row({ space: 2 }) {
            Text(' >')
              .fontSize(11)
              .fontColor('#CCC')
            Text(space.name)
              .fontSize(13)
              .fontColor(index === this.breadcrumb.length - 1 ? '#333' : '#007AFF')
              .fontWeight(index === this.breadcrumb.length - 1 ? FontWeight.Medium : FontWeight.Normal)
          }
          .onClick(() => {
            this.onBreadcrumbTap(index);
          })
        }, (space: Space, index: number) => space.id.toString())
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 4, bottom: 4 })
    }
  }

  @Builder
  RootSpaces() {
    if (this.loading) {
      this.LoadingView()
    } else if (this.spaces.length === 0) {
      Column() {
        EmptyState({
          icon: this.getIconForLevel(1),
          title: '还没有空间',
          subtitle: '点击右下角按钮添加空间'
        })
      }
      .width('100%')
      .layoutWeight(1)
    } else {
      List({ space: 8 }) {
        ForEach(this.spaces, (space: Space, index: number) => {
          ListItem() {
            Row() {
              Text(space.icon)
                .fontSize(28)
                .margin({ right: 12 })
              Text(space.name)
                .fontSize(15)
                .fontColor('#333')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
              Text('>')
                .fontSize(18)
                .fontColor('#CCC')
            }
            .width('100%')
            .padding(14)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .onClick(() => {
              this.onSpaceTap(space);
            })
          }
          .margin({ left: 16, right: 16 })
        }, (space: Space, index: number) => space.id.toString())
      }
      .width('100%')
      .layoutWeight(1)
      .divider({ strokeWidth: 0 })
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  SpaceDetail() {
    Scroll() {
      Column({ space: 12 }) {
        Stack() {
          Scroll(this.scrollController) {
            Stack() {
              if (this.breadcrumb.length > 0 && this.breadcrumb[0].image) {
                Image(this.breadcrumb[0].image)
                  .width('100%')
                  .height(IMAGE_SCROLL_HEIGHT)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(12)
              } else {
                Image($r('app.media.bg_preset_1'))
                  .width('100%')
                  .height(IMAGE_SCROLL_HEIGHT)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(12)
              }

              ForEach(this.spaces, (section: Space, index: number) => {
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
                  this.onSpaceTap(section);
                })
              }, (section: Space, index: number) => section.id.toString())
            }
            .width('100%')
            .height(IMAGE_SCROLL_HEIGHT)
          }
          .width('100%')
          .height(IMAGE_PANEL_HEIGHT)
          .scrollBar(BarState.Off)

          Button() {
            Text('🔍')
              .fontSize(18)
          }
          .width(32)
          .height(32)
          .type(ButtonType.Circle)
          .backgroundColor('#66000000')
          .fontColor(Color.White)
          .position({ x: 8, y: 8 })
          .onClick(() => {
            this.showFullscreenImage = true;
          })
        }
        .width('100%')
        .height(IMAGE_PANEL_HEIGHT)

        Row() {
          Text('位置')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#111')
          Blank()
          Text(`${this.spaces.length} 个分区`)
            .fontSize(12)
            .fontColor('#999')
        }
        .width('100%')

        if (this.loading) {
          this.LoadingView()
        } else if (this.spaces.length === 0) {
          Column() {
            EmptyState({ icon: '📍', title: '还没有分区', subtitle: '点击图片位置添加分区' })
          }
          .width('100%')
          .height(220)
        } else {
          Column({ space: 8 }) {
            ForEach(this.spaces, (section: Space, index: number) => {
              Row() {
                Circle()
                  .width(20)
                  .height(20)
                  .fill(section.markerColor)
                  .margin({ right: 16 })
                Text(section.name)
                  .fontSize(16)
                  .fontColor('#333')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                Text('>')
                  .fontSize(18)
                  .fontColor('#CCC')
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(8)
              .onClick(() => {
                this.onSpaceTap(section);
              })
            }, (section: Space, index: number) => section.id.toString())
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 88 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  SectionItems() {
    Column() {
      Row() {
        Text('物品')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111')
        Blank()
        Button('添加物品')
          .type(ButtonType.Normal)
          .fontColor(Color.White)
          .backgroundColor('#007AFF')
          .borderRadius(18)
          .height(36)
          .onClick(() => {
            this.loadUnassignedItems();
            this.showSectionItemSheet = false;
            this.sectionItemSheetKey++;
            this.showSectionItemSheet = true;
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      if (this.loading) {
        this.LoadingView()
      } else if (this.items.length === 0) {
        Column() {
          EmptyState({ icon: '📦', title: '该分区暂无物品', subtitle: '点击右上角添加物品' })
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        List({ space: 8 }) {
          ForEach(this.items, (item: Item, index: number) => {
            ListItem() {
              Row() {
                Column({ space: 4 }) {
                  Text(item.name)
                    .fontSize(15)
                    .fontColor('#333')
                    .fontWeight(FontWeight.Medium)
                  Text(item.category)
                    .fontSize(12)
                    .fontColor('#007AFF')
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .backgroundColor('#EBF5FF')
                    .borderRadius(4)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Color.White)
              .borderRadius(8)
            }
            .margin({ left: 16, right: 16 })
          }, (item: Item, index: number) => item.id.toString())
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 0 })
        .scrollBar(BarState.Off)
        .padding({ top: 4, bottom: 80 })
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  LoadingView() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#007AFF')
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
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
          this.newSpaceName = '';
          if (this.isSpaceDetailPage()) {
            this.clearPendingMarker();
          }
        })

      Column({ space: 16 }) {
        Text(`新增${this.getLevelLabel()}`)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
        TextInput({ text: this.newSpaceName, placeholder: `输入${this.getLevelLabel()}名称` })
          .onChange((value: string) => {
            this.newSpaceName = value;
          })
        Row({ space: 12 }) {
          Button('取消')
            .type(ButtonType.Normal)
            .fontColor('#999')
            .backgroundColor('#F0F0F0')
            .layoutWeight(1)
            .onClick(() => {
              this.showAddDialog = false;
              this.newSpaceName = '';
              if (this.isSpaceDetailPage()) {
                this.clearPendingMarker();
              }
            })
          Button('确认')
            .type(ButtonType.Normal)
            .fontColor(Color.White)
            .backgroundColor('#007AFF')
            .layoutWeight(1)
            .onClick(() => {
              this.addSpace();
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

  @Builder
  addSpaceSheet() {
    Column() {
      Scroll() {
        Column({ space: 20 }) {
          Column({ space: 6 }) {
            Text('空间名称')
              .fontSize(14)
              .fontColor('#666')
            TextInput({ text: this.newSpaceName, placeholder: '输入空间名称' })
              .height(44)
              .backgroundColor('#F5F5F5')
              .borderRadius(10)
              .padding({ left: 14 })
              .onChange((value: string) => {
                this.newSpaceName = value;
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: 10 }) {
            Text('空间图片')
              .fontSize(14)
              .fontColor('#666')

            if (this.selectedImageURI) {
              Column({ space: 6 }) {
                Image(this.selectedImageURI)
                  .width('100%')
                  .height(160)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(10)
                Text(this.selectedImageName)
                  .fontSize(12)
                  .fontColor('#999')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
            }

            Row({ space: 12 }) {
              Button('📷 拍照')
                .type(ButtonType.Normal)
                .fontColor('#333')
                .backgroundColor('#F0F0F0')
                .layoutWeight(1)
                .onClick(() => {
                  this.takePhoto();
                })
              Button('🖼 从相册选择')
                .type(ButtonType.Normal)
                .fontColor('#333')
                .backgroundColor('#F0F0F0')
                .layoutWeight(1)
                .onClick(() => {
                  this.pickFromAlbum();
                })
            }
            .width('100%')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')

      Button() {
        Text('保存')
          .fontSize(16)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(48)
      .backgroundColor(this.newSpaceName.trim() ? '#007AFF' : '#B0D4FF')
      .borderRadius(24)
      .margin({ top: 16, bottom: 8 })
      .enabled(this.newSpaceName.trim().length > 0)
      .onClick(() => {
        this.addSpace();
      })
    }
    .padding({ left: 24, right: 24, top: 8, bottom: 24 })
    .width('100%')
    .height('100%')
  }

  @Builder
  addItemToSectionSheet() {
    Column() {
      Scroll() {
        if (this.unassignedItems.length === 0) {
          Column() {
            EmptyState({ icon: '📦', title: '没有未分配物品', subtitle: '点击下方按钮添加新物品' })
          }
          .width('100%')
          .height('100%')
        } else {
          List({ space: 8 }) {
            ForEach(this.unassignedItems, (item: Item, idx: number) => {
              ListItem() {
                Row() {
                  Column({ space: 4 }) {
                    Text(item.name)
                      .fontSize(15)
                      .fontColor('#333')
                      .fontWeight(FontWeight.Medium)
                    Text(item.category)
                      .fontSize(12)
                      .fontColor('#007AFF')
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .backgroundColor('#EBF5FF')
                      .borderRadius(4)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  Button('添加')
                    .type(ButtonType.Normal)
                    .fontColor(Color.White)
                    .backgroundColor('#007AFF')
                    .borderRadius(14)
                    .height(28)
                    .fontSize(12)
                    .padding({ left: 12, right: 12 })
                    .onClick(() => {
                      this.assignItemToSection(item.id);
                    })
                }
                .width('100%')
                .padding(12)
                .backgroundColor(Color.White)
                .borderRadius(8)
              }
              .margin({ left: 16, right: 16 })
            }, (item: Item, idx: number) => item.id.toString())
          }
          .width('100%')
          .divider({ strokeWidth: 0 })
          .scrollBar(BarState.Off)
        }
      }
      .layoutWeight(1)
      .width('100%')

      Button() {
        Text('+ 添加新物品')
          .fontSize(15)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(44)
      .backgroundColor('#007AFF')
      .borderRadius(22)
      .margin({ top: 12, bottom: 8 })
      .onClick(() => {
        this.showSectionItemSheet = false;
        this.openAddItemPage();
      })
    }
    .padding({ left: 24, right: 24, top: 8, bottom: 24 })
    .width('100%')
    .height('100%')
  }

  @Builder
  fullscreenImagePreview() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#FF000000')

      if (this.breadcrumb.length > 0 && this.breadcrumb[0].image) {
        Image(this.breadcrumb[0].image)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)
          .onAreaChange((oldValue: Area, newValue: Area) => {
            this.fsImageWidth = Number(newValue.width);
            this.fsImageHeight = Number(newValue.height);
          })
          .onClick((event: ClickEvent) => {
            this.setPendingMarkerFullscreen(event);
          })
      } else {
        Image($r('app.media.bg_preset_1'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)
          .onAreaChange((oldValue: Area, newValue: Area) => {
            this.fsImageWidth = Number(newValue.width);
            this.fsImageHeight = Number(newValue.height);
          })
          .onClick((event: ClickEvent) => {
            this.setPendingMarkerFullscreen(event);
          })
      }

      ForEach(this.spaces, (section: Space, index: number) => {
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
          this.onSpaceTap(section);
        })
      }, (section: Space, index: number) => section.id.toString())

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
          this.showFullscreenImage = false;
          this.showAddDialog = true;
        })
      }

      Button() {
        Text('✕')
          .fontSize(20)
          .fontColor(Color.White)
      }
      .width(40)
      .height(40)
      .type(ButtonType.Circle)
      .backgroundColor('#66000000')
      .position({ x: '100%', y: 0 })
      .markAnchor({ x: '100%', y: 0 })
      .offset({ x: -12, y: 48 })
      .onClick(() => {
        this.showFullscreenImage = false;
      })
    }
    .width('100%')
    .height('100%')
  }

  build() {
    Stack() {
      Column() {
        this.NavigationHeader()
        this.BreadcrumbBar()

        if (this.isSectionPage()) {
          this.SectionItems()
        } else if (this.isSpaceDetailPage()) {
          this.SpaceDetail()
        } else {
          this.RootSpaces()
        }
      }
      .width('100%')
      .height('100%')
      .bindSheet(this.showSectionItemSheet, this.addItemToSectionSheet, {
        height: '75%',
        dragBar: true,
        showClose: true,
        title: { title: '添加物品到分区' },
        onDisappear: () => {
          this.showSectionItemSheet = false;
        },
      })

      if (this.breadcrumb.length === 0) {
        Button() {
          Text('+')
            .fontSize(28)
            .fontColor(Color.White)
        }
        .width(56)
        .height(56)
        .borderRadius(28)
        .backgroundColor('#007AFF')
        .position({ x: '100%', y: '100%' })
        .markAnchor({ x: '100%', y: '100%' })
        .offset({ x: -24, y: -24 })
        .shadow({ radius: 8, color: '#33007AFF', offsetY: 4 })
        .onClick(() => {
          this.resetSheetForm();
          this.showAddSheet = false;
          this.sheetKey++;
          this.showAddSheet = true;
        })
      }

      if (this.showAddDialog) {
        this.AddDialog()
      }

      if (this.showFullscreenImage) {
        this.fullscreenImagePreview()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .bindSheet(this.showAddSheet, this.addSpaceSheet, {
      height: '50%',
      dragBar: true,
      showClose: true,
      title: { title: '添加空间' },
      onDisappear: () => {
        this.showAddSheet = false;
        this.resetSheetForm();
      },
    })
  }
}
