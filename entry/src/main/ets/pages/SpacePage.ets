import { Space } from '../model/SpaceModel';
import { Item } from '../model/ItemModel';
import { SpaceRepository } from '../data/SpaceRepository';
import { ItemRepository } from '../data/ItemRepository';
import { EmptyState } from '../components/EmptyState';

@Entry
@Component
export struct SpacePage {
  @State spaces: Space[] = [];
  @State items: Item[] = [];
  @State breadcrumb: Space[] = [];
  @State loading: boolean = true;
  @State showAddDialog: boolean = false;
  @State newSpaceName: string = '';
  @StorageLink('spaceRefreshToken') @Watch('onSpaceRefreshToken') spaceRefreshToken: number = 0;
  private spaceRepo: SpaceRepository = new SpaceRepository();
  private itemRepo: ItemRepository = new ItemRepository();

  aboutToAppear(): void {
    this.loadSpaces();
  }

  async onSpaceRefreshToken(): Promise<void> {
    if (this.spaceRefreshToken <= 0) {
      return;
    }
    if (this.isShowingItems()) {
      await this.loadItems(this.getParentId());
    } else {
      await this.loadSpaces();
    }
  }

  getParentId(): number {
    if (this.breadcrumb.length === 0) {
      return 0;
    }
    return this.breadcrumb[this.breadcrumb.length - 1].id;
  }

  isShowingItems(): boolean {
    return this.breadcrumb.length >= 3;
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
    try {
      this.items = await this.itemRepo.getBySpaceId(spaceId);
    } catch (e) {
      this.items = [];
    }
  }

  async goBackOneLevel(): Promise<void> {
    if (this.breadcrumb.length === 0) {
      return;
    }
    this.breadcrumb = this.breadcrumb.slice(0, this.breadcrumb.length - 1);
    this.items = [];
    await this.loadSpaces();
  }

  async onSpaceTap(space: Space): Promise<void> {
    if (this.breadcrumb.length >= 2) {
      this.breadcrumb = this.breadcrumb.concat([space]);
      await this.loadItems(space.id);
    } else {
      this.breadcrumb = this.breadcrumb.concat([space]);
      await this.loadSpaces();
    }
  }

  async onBreadcrumbTap(index: number): Promise<void> {
    if (index < 0) {
      this.breadcrumb = [];
      this.items = [];
      await this.loadSpaces();
      return;
    }

    this.breadcrumb = this.breadcrumb.slice(0, index + 1);

    if (this.isShowingItems()) {
      await this.loadItems(this.getParentId());
    } else {
      this.items = [];
      await this.loadSpaces();
    }
  }

  async addSpace(): Promise<void> {
    const name: string = this.newSpaceName.trim();
    if (name === '') {
      return;
    }

    const parentId: number = this.getParentId();
    const level: number = this.breadcrumb.length + 1;

    try {
      const rowId: number = await this.spaceRepo.insert({
        name: name,
        parentId: parentId,
        level: level,
        icon: this.getIconForLevel(level),
      });

      console.info(`Space inserted rowId=${rowId}, parentId=${parentId}, level=${level}`);

      this.newSpaceName = '';
      this.showAddDialog = false;

      const created: Space = {
        id: rowId,
        name: name,
        parentId: parentId,
        level: level,
        icon: this.getIconForLevel(level),
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

  getIconForLevel(level: number): string {
    if (level === 1) {
      return '🏠';
    }
    if (level === 2) {
      return '🗄️';
    }
    return '📦';
  }

  getLevelLabel(): string {
    const level: number = this.breadcrumb.length + 1;
    if (level === 1) {
      return '房间';
    }
    if (level === 2) {
      return '柜子';
    }
    return '格子';
  }

  build() {
    Stack() {
      Column() {
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

        if (this.isShowingItems()) {
          if (this.items.length === 0) {
            Column() {
              EmptyState({ icon: '📦', title: '该格子暂无物品', subtitle: '在物品管理中添加物品并分配到此空间' })
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
        } else if (this.loading) {
          Column() {
            LoadingProgress()
              .width(40)
              .height(40)
              .color('#007AFF')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.spaces.length === 0) {
          Column() {
            EmptyState({
              icon: this.getIconForLevel(this.breadcrumb.length + 1),
              title: `还没有${this.getLevelLabel()}`,
              subtitle: `点击右下角按钮添加${this.getLevelLabel()}`
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
      .width('100%')
      .height('100%')

      if (!this.isShowingItems()) {
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
          this.showAddDialog = true;
        })
      }

      if (this.showAddDialog) {
        Stack() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#66000000')
            .onClick(() => {
              this.showAddDialog = false;
              this.newSpaceName = '';
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
    }
    .width('100%')
    .height('100%')
  }
}
