import { router } from '@kit.ArkUI';
import { Item } from '../model/ItemModel';
import { Space } from '../model/SpaceModel';
import { Category } from '../model/CategoryModel';
import { ItemRepository } from '../data/ItemRepository';
import { SpaceRepository } from '../data/SpaceRepository';
import { CategoryRepository } from '../data/CategoryRepository';
import { PageBackground } from '../components/PageBackground';
import { EmptyState } from '../components/EmptyState';

const DEFAULT_CATEGORIES: string[] = ['衣物', '书籍', '数码', '厨房', '文件', '其他'];

@Entry
@Component
export struct ItemDetailPage {
  @State item: Item | null = null;
  @State loading: boolean = true;
  @State locationLabel: string = '未分配';
  @State showAssignSheet: boolean = false;
  @State rootSpaces: Space[] = [];
  @State sections: Space[] = [];
  @State selectedAssignSpaceId: number = 0;
  @State selectedAssignSectionId: number = 0;
  @State showCategorySheet: boolean = false;
  @State categories: string[] = [];
  @State selectedCategory: string = '';
  private repo: ItemRepository = new ItemRepository();
  private spaceRepo: SpaceRepository = new SpaceRepository();
  private categoryRepo: CategoryRepository = new CategoryRepository();

  aboutToAppear(): void {
    const itemId: number = AppStorage.get<number>('currentItemId') ?? 0;
    if (itemId > 0) {
      this.loadItem(itemId);
    } else {
      this.item = null;
      this.loading = false;
    }
  }

  async loadItem(itemId: number): Promise<void> {
    this.loading = true;
    const result: Item | null = await this.repo.getById(itemId);
    this.item = result;
    this.locationLabel = result !== null ? await this.resolveLocationLabel(result.spaceId) : '未分配';
    this.loading = false;
  }

  async deleteItem(): Promise<void> {
    if (this.item !== null) {
      await this.repo.delete(this.item.id);
      router.back();
    }
  }

  getDetailTitle(): string {
    return this.item !== null ? this.item.name : '物品详情';
  }

  async resolveLocationLabel(spaceId: number): Promise<string> {
    if (spaceId <= 0) {
      return '未分配';
    }

    const space: Space | null = await this.spaceRepo.getById(spaceId);
    if (space === null) {
      return '未分配';
    }

    if (space.level === 2) {
      const parent: Space | null = await this.spaceRepo.getById(space.parentId);
      if (parent === null) {
        return space.name;
      }
      return `${parent.name} -> ${space.name}`;
    }

    return space.name;
  }

  async openAssignSheet(): Promise<void> {
    this.rootSpaces = await this.spaceRepo.getByParent(0);
    this.sections = [];
    this.selectedAssignSpaceId = 0;
    this.selectedAssignSectionId = 0;

    if (this.item !== null && this.item.spaceId > 0) {
      const currentSpace: Space | null = await this.spaceRepo.getById(this.item.spaceId);
      if (currentSpace !== null && currentSpace.level === 2) {
        this.selectedAssignSpaceId = currentSpace.parentId;
        this.selectedAssignSectionId = currentSpace.id;
        this.sections = await this.spaceRepo.getByParent(currentSpace.parentId);
      }
    }

    this.showAssignSheet = true;
  }

  async selectAssignSpace(spaceId: number): Promise<void> {
    this.selectedAssignSpaceId = spaceId;
    this.selectedAssignSectionId = 0;
    this.sections = await this.spaceRepo.getByParent(spaceId);
  }

  async confirmAssign(): Promise<void> {
    if (this.item === null || this.selectedAssignSectionId <= 0) {
      return;
    }

    const updated: Item = {
      id: this.item.id,
      name: this.item.name,
      category: this.item.category,
      spaceId: this.selectedAssignSectionId,
      image: this.item.image,
      purchaseDate: this.item.purchaseDate,
      note: this.item.note,
      createTime: this.item.createTime,
    };
    await this.repo.update(updated);
    this.item = updated;
    this.locationLabel = await this.resolveLocationLabel(updated.spaceId);
    this.showAssignSheet = false;
    AppStorage.setOrCreate('itemRefreshToken', Date.now());
    AppStorage.setOrCreate('spaceRefreshToken', Date.now());
  }

  async openCategorySheet(): Promise<void> {
    if (this.item === null) {
      return;
    }

    const savedCategories: Category[] = await this.categoryRepo.getAll();
    const names: string[] = savedCategories.length > 0 ? savedCategories.map((cat: Category) => cat.name) : DEFAULT_CATEGORIES;
    if (names.indexOf(this.item.category) === -1) {
      this.categories = names.concat([this.item.category]);
    } else {
      this.categories = names;
    }
    this.selectedCategory = this.item.category;
    this.showCategorySheet = true;
  }

  async confirmCategory(): Promise<void> {
    if (this.item === null || this.selectedCategory.trim() === '') {
      return;
    }

    const updated: Item = {
      id: this.item.id,
      name: this.item.name,
      category: this.selectedCategory,
      spaceId: this.item.spaceId,
      image: this.item.image,
      purchaseDate: this.item.purchaseDate,
      note: this.item.note,
      createTime: this.item.createTime,
    };
    await this.repo.update(updated);
    this.item = updated;
    this.showCategorySheet = false;
    AppStorage.setOrCreate('itemRefreshToken', Date.now());
  }

  @Builder
  assignSheet() {
    Column() {
      Scroll() {
        Column({ space: 18 }) {
          Column({ space: 8 }) {
            Text('选择空间')
              .fontSize(14)
              .fontColor('#666')
              .fontWeight(FontWeight.Medium)
            if (this.rootSpaces.length === 0) {
              EmptyState({ icon: '🏠', title: '还没有空间', subtitle: '请先在空间页创建空间和分区' })
            } else {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.rootSpaces, (space: Space, index: number) => {
                  Text(space.name)
                    .fontSize(13)
                    .fontColor(space.id === this.selectedAssignSpaceId ? '#fff' : '#666')
                    .padding({ left: 14, right: 14, top: 7, bottom: 7 })
                    .backgroundColor(space.id === this.selectedAssignSpaceId ? '#007AFF' : '#F0F0F0')
                    .borderRadius(16)
                    .margin({ right: 8, bottom: 8 })
                    .onClick(() => {
                      this.selectAssignSpace(space.id);
                    })
                }, (space: Space, index: number) => space.id.toString())
              }
              .width('100%')
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          if (this.selectedAssignSpaceId > 0) {
            Column({ space: 8 }) {
              Text('选择分区')
                .fontSize(14)
                .fontColor('#666')
                .fontWeight(FontWeight.Medium)
              if (this.sections.length === 0) {
                EmptyState({ icon: '📍', title: '该空间暂无分区', subtitle: '请先在空间页为该空间创建分区' })
              } else {
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.sections, (section: Space, index: number) => {
                    Text(section.name)
                      .fontSize(13)
                      .fontColor(section.id === this.selectedAssignSectionId ? '#fff' : '#666')
                      .padding({ left: 14, right: 14, top: 7, bottom: 7 })
                      .backgroundColor(section.id === this.selectedAssignSectionId ? '#007AFF' : '#F0F0F0')
                      .borderRadius(16)
                      .margin({ right: 8, bottom: 8 })
                      .onClick(() => {
                        this.selectedAssignSectionId = section.id;
                      })
                  }, (section: Space, index: number) => section.id.toString())
                }
                .width('100%')
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')

      Button() {
        Text('确认分配')
          .fontSize(16)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(48)
      .backgroundColor(this.selectedAssignSectionId > 0 ? '#007AFF' : '#B0D4FF')
      .borderRadius(24)
      .margin({ top: 16, bottom: 8 })
      .enabled(this.selectedAssignSectionId > 0)
      .onClick(() => {
        this.confirmAssign();
      })
    }
    .padding({ left: 24, right: 24, top: 8, bottom: 24 })
    .width('100%')
    .height('100%')
  }

  @Builder
  categorySheet() {
    Column() {
      Scroll() {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.categories, (category: string, index: number) => {
            Text(category)
              .fontSize(14)
              .fontColor(category === this.selectedCategory ? '#fff' : '#666')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor(category === this.selectedCategory ? '#007AFF' : '#F0F0F0')
              .borderRadius(18)
              .margin({ right: 10, bottom: 10 })
              .onClick(() => {
                this.selectedCategory = category;
              })
          }, (category: string, index: number) => category)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')

      Button() {
        Text('确认分类')
          .fontSize(16)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(48)
      .backgroundColor(this.selectedCategory !== '' ? '#007AFF' : '#B0D4FF')
      .borderRadius(24)
      .margin({ top: 16, bottom: 8 })
      .enabled(this.selectedCategory !== '')
      .onClick(() => {
        this.confirmCategory();
      })
    }
    .padding({ left: 24, right: 24, top: 16, bottom: 24 })
    .width('100%')
    .height('100%')
  }

  build() {
    Stack() { PageBackground()
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
        Text(this.getDetailTitle())
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        Blank()
        if (this.item !== null) {
          Button('删除')
            .type(ButtonType.Normal)
            .backgroundColor(Color.Transparent)
            .fontColor('#FF3B30')
            .onClick(() => {
              this.deleteItem();
            })
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

      if (this.loading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#007AFF')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.item === null) {
        Column() {
          Text('物品不存在')
            .fontSize(16)
            .fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Column({ space: 16 }) {
          Row() {
            Text('名称')
              .fontSize(14)
              .fontColor('#999')
              .width(70)
            Text(this.item.name)
              .fontSize(15)
              .fontColor('#333')
              .layoutWeight(1)
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Color.White)
          .borderRadius(8)

          Row() {
            Text('分类')
              .fontSize(14)
              .fontColor('#999')
              .width(70)
            Text(this.item.category)
              .fontSize(12)
              .fontColor('#007AFF')
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .backgroundColor('#EBF5FF')
              .borderRadius(4)
            Blank()
            Text('>')
              .fontSize(18)
              .fontColor('#CCC')
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onClick(() => {
            this.openCategorySheet();
          })

          Row() {
            Text('位置')
              .fontSize(14)
              .fontColor('#999')
              .width(70)
            Text(this.locationLabel)
              .fontSize(15)
              .fontColor('#333')
              .layoutWeight(1)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            // Button('分配')
            //   .type(ButtonType.Normal)
            //   .fontColor(Color.White)
            //   .backgroundColor('#007AFF')
            //   .borderRadius(14)
            //   .height(28)
            //   .fontSize(12)
            //   .padding({ left: 12, right: 12 })
            //   .onClick(() => {
            //     this.openAssignSheet();
            //   })
            Blank()
            Text('>')
              .fontSize(18)
              .fontColor('#CCC')
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onClick(() => {this.openAssignSheet()})

          if (this.item.purchaseDate !== '') {
            Row() {
              Text('购买日期')
                .fontSize(14)
                .fontColor('#999')
                .width(70)
              Text(this.item.purchaseDate)
                .fontSize(15)
                .fontColor('#333')
                .layoutWeight(1)
            }
            .width('100%')
            .padding(12)
            .backgroundColor(Color.White)
            .borderRadius(8)
          }

          if (this.item.note !== '') {
            Row() {
              Text('备注')
                .fontSize(14)
                .fontColor('#999')
                .width(70)
              Text(this.item.note)
                .fontSize(15)
                .fontColor('#333')
                .layoutWeight(1)
            }
            .width('100%')
            .padding(12)
            .backgroundColor(Color.White)
            .borderRadius(8)
          }

          Row() {
            Text('创建时间')
              .fontSize(14)
              .fontColor('#999')
              .width(70)
            Text(this.item.createTime)
              .fontSize(15)
              .fontColor('#333')
              .layoutWeight(1)
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Color.White)
          .borderRadius(8)
        }
        .padding(16)
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .padding({ top: 36 })
    .bindSheet(this.showCategorySheet, this.categorySheet, {
      height: '45%',
      dragBar: true,
      showClose: true,
      title: { title: '修改分类' },
      onDisappear: () => {
        this.showCategorySheet = false;
      },
    })
    }
    .width('100%')
    .height('100%')
    .bindSheet(this.showAssignSheet, this.assignSheet, {
      height: '50%',
      dragBar: true,
      showClose: true,
      title: { title: '分配位置' },
      onDisappear: () => {
        this.showAssignSheet = false;
      },
    })
  }
}
