import { router } from '@kit.ArkUI';
import { PageBackground } from '../components/PageBackground';
import { Item, ItemInput } from '../model/ItemModel';
import { Space } from '../model/SpaceModel';
import { Category } from '../model/CategoryModel';
import { ItemRepository } from '../data/ItemRepository';
import { CategoryRepository, DEFAULT_CATEGORY_NAME } from '../data/CategoryRepository';
import { SpaceRepository } from '../data/SpaceRepository';
import { EmptyState } from '../components/EmptyState';
import { ItemCard } from '../components/ItemCard';
import { CategoryGrid } from '../components/CategoryGrid';
import { ConfirmDeleteDialog } from '../components/ConfirmDeleteDialog';

interface ItemLocationLabel {
  itemId: number;
  label: string;
}

@CustomDialog
struct AddCategoryDialog {
  controller: CustomDialogController;
  @State inputValue: string = '';
  onConfirm: (name: string) => void = (name: string) => {};

  build() {
    Column() {
      Text('添加分类')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333')

      TextInput({ placeholder: '请输入新分类名称', text: this.inputValue })
        .width('100%')
        .height(44)
        .backgroundColor('#F5F5F5')
        .borderRadius(10)
        .padding({ left: 12 })
        .margin({ top: 16 })
        .onChange((value: string) => {
          this.inputValue = value;
        })

      Row({ space: 12 }) {
        Button('取消')
          .width(100)
          .height(40)
          .backgroundColor('#F0F0F0')
          .fontColor('#666')
          .borderRadius(20)
          .onClick(() => {
            this.controller.close();
          })

        Button('确定')
          .width(100)
          .height(40)
          .backgroundColor('#007AFF')
          .borderRadius(20)
          .onClick(() => {
            const name: string = this.inputValue.trim();
            if (name.length > 0) {
              this.onConfirm(name);
            }
            this.inputValue = '';
            this.controller.close();
          })
      }
      .margin({ top: 20 })
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .padding(24)
    .width('100%')
  }
}

@Component
export struct ItemPage {
  @State items: Item[] = [];
  @State filteredItems: Item[] = [];
  @State searchKeyword: string = '';
  @State selectedCategory: string = '全部';
  @State loading: boolean = true;
  @State categories: string[] = [];
  @State itemLocationLabels: ItemLocationLabel[] = [];
  @State showCategoryManageSheet: boolean = false;
  @State managedCategories: Category[] = [];
  @StorageLink('itemRefreshToken') @Watch('onRefreshToken') itemRefreshToken: number = 0;
  @StorageLink('quickAddItem') @Watch('onQuickAddItem') quickAddItem: number = 0;
  @StorageLink('quickAddItemSpaceId') quickAddItemSpaceId: number = 0;
  private repo: ItemRepository = new ItemRepository();
  private categoryRepo: CategoryRepository = new CategoryRepository();
  private spaceRepo: SpaceRepository = new SpaceRepository();
  private addCategoryDialogController: CustomDialogController | null = null;
  private deleteCategoryDialogController: CustomDialogController | null = null;

  // ---- 半模态面板状态 ----
  @State showAddItemSheet: boolean = false;
  @State sheetKey: number = 0;
  @State newItemName: string = '';
  @State newItemCategory: string = DEFAULT_CATEGORY_NAME;
  @State newItemDate: string = '';
  @State newItemNote: string = '';

  aboutToAppear(): void {
    this.addCategoryDialogController = new CustomDialogController({
      builder: AddCategoryDialog({ onConfirm: (name: string) => this.onAddCategoryConfirm(name) }),
      autoCancel: true,
      customStyle: true,
      cornerRadius: 16,
    });
    this.loadItems();
    this.loadCategories();
  }

  async loadCategories(): Promise<void> {
    const cats: Category[] = await this.categoryRepo.ensureDefaults();
    const names: string[] = cats.map(c => c.name);
    const otherIdx: number = names.indexOf(DEFAULT_CATEGORY_NAME);
    if (otherIdx >= 0) {
      names.splice(otherIdx, 1);
      names.push(DEFAULT_CATEGORY_NAME);
    }
    this.categories = ['全部', ...names];
  }

  onPageShow(): void {
    this.loadItems();
  }

  onRefreshToken(): void {
    if (this.itemRefreshToken > 0) {
      this.loadItems();
    }
  }

  onQuickAddItem(): void {
    if (this.quickAddItem <= 0) {
      return;
    }
    this.resetNewItemForm();
    this.showAddItemSheet = false;
    this.sheetKey++;
    this.showAddItemSheet = true;
  }

  async loadItems(): Promise<void> {
    this.loading = true;
    const items: Item[] = await this.repo.getAll();
    this.itemLocationLabels = await this.buildItemLocationLabels(items);
    this.items = items;
    this.applyFilters();
    this.loading = false;
  }

  async buildItemLocationLabels(items: Item[]): Promise<ItemLocationLabel[]> {
    const labels: ItemLocationLabel[] = [];
    for (let i = 0; i < items.length; i++) {
      labels.push({
        itemId: items[i].id,
        label: await this.resolveLocationLabel(items[i].spaceId),
      });
    }
    return labels;
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

  getItemLocationLabel(itemId: number): string {
    for (let i = 0; i < this.itemLocationLabels.length; i++) {
      if (this.itemLocationLabels[i].itemId === itemId) {
        return this.itemLocationLabels[i].label;
      }
    }
    return '未分配';
  }

  applyFilters(): void {
    let result: Item[] = this.items;
    if (this.selectedCategory !== '全部') {
      result = result.filter((item: Item) => item.category === this.selectedCategory);
    }
    if (this.searchKeyword.trim() !== '') {
      const kw: string = this.searchKeyword.trim().toLowerCase();
      result = result.filter((item: Item) => item.name.toLowerCase().includes(kw));
    }
    this.filteredItems = result;
  }

  onSearchChange(value: string): void {
    this.searchKeyword = value;
    this.applyFilters();
  }

  onCategorySelect(category: string): void {
    this.selectedCategory = category;
    this.applyFilters();
  }

  onAddCategoryTap(): void {
    this.addCategoryDialogController?.open();
  }

  onAddCategoryConfirm(name: string): void {
    if (this.categories.indexOf(name) === -1) {
      this.categoryRepo.insert({ name }).then(() => {
        this.loadCategories();
        if (this.showCategoryManageSheet) {
          this.categoryRepo.getAll().then((categories: Category[]) => {
            this.managedCategories = categories;
          });
        }
        AppStorage.setOrCreate('itemRefreshToken', Date.now());
      });
    }
  }

  async openCategoryManageSheet(): Promise<void> {
    const allCats: Category[] = await this.categoryRepo.getAll();
    const catOtherIdx: number = allCats.findIndex((cat: Category) => cat.name === DEFAULT_CATEGORY_NAME);
    if (catOtherIdx >= 0) {
      const otherCat: Category = allCats[catOtherIdx];
      allCats.splice(catOtherIdx, 1);
      allCats.push(otherCat);
    }
    this.managedCategories = allCats;
    this.showCategoryManageSheet = true;
  }

  openDeleteCategoryDialog(category: Category): void {
    this.deleteCategoryDialogController = new CustomDialogController({
      builder: ConfirmDeleteDialog({
        title: '删除分类',
        message: `确认删除“${category.name}”？该分类下的物品会改为“${DEFAULT_CATEGORY_NAME}”。`,
        onConfirm: () => {
          this.deleteCategory(category);
        }
      }),
      autoCancel: true,
      customStyle: true,
      maskColor: '#66000000',
      cornerRadius: 16,
    });
    this.deleteCategoryDialogController.open();
  }

  async deleteCategory(category: Category): Promise<void> {
    if (category.name === DEFAULT_CATEGORY_NAME) {
      return;
    }
    await this.repo.updateCategory(category.name, DEFAULT_CATEGORY_NAME);
    await this.categoryRepo.delete(category.id);
    if (this.selectedCategory === category.name) {
      this.selectedCategory = '全部';
    }
    await this.loadCategories();
    await this.loadItems();
    const refreshCats: Category[] = await this.categoryRepo.getAll();
    const refreshOtherIdx: number = refreshCats.findIndex((cat: Category) => cat.name === DEFAULT_CATEGORY_NAME);
    if (refreshOtherIdx >= 0) {
      const otherCat: Category = refreshCats[refreshOtherIdx];
      refreshCats.splice(refreshOtherIdx, 1);
      refreshCats.push(otherCat);
    }
    this.managedCategories = refreshCats;
    AppStorage.setOrCreate('itemRefreshToken', Date.now());
  }

  resetNewItemForm(): void {
    this.newItemName = '';
    this.newItemCategory = DEFAULT_CATEGORY_NAME;
    this.newItemDate = '';
    this.newItemNote = '';
  }

  async saveNewItem(): Promise<void> {
    if (this.newItemName.trim() === '') {
      return;
    }
    const createTime: string = new Date().toISOString();
    const itemInput: ItemInput = {
      name: this.newItemName.trim(),
      category: this.newItemCategory,
      spaceId: this.quickAddItemSpaceId > 0 ? this.quickAddItemSpaceId : 0,
      image: '',
      purchaseDate: this.newItemDate,
      note: this.newItemNote,
      createTime: createTime,
    };
    await this.repo.insert(itemInput);
    AppStorage.setOrCreate('itemRefreshToken', Date.now());
    AppStorage.setOrCreate('spaceRefreshToken', Date.now());
    AppStorage.setOrCreate('quickAddItemSpaceId', 0);
    this.resetNewItemForm();
    this.showAddItemSheet = false;
    this.loadItems();
  }

  @Builder
  addItemSheet() {
    Column() {
      // 标题区
      Text('添加物品')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ bottom: 20 })

      Scroll() {
        Column({ space: 20 }) {
          // 名称
          Column({ space: 6 }) {
            Text('名称')
              .fontSize(14)
              .fontColor('#666')
            TextInput({ text: this.newItemName, placeholder: '输入物品名称' })
              .height(44)
              .backgroundColor('#F5F5F5')
              .borderRadius(10)
              .padding({ left: 14 })
              .onChange((value: string) => {
                this.newItemName = value;
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 分类
          Column({ space: 6 }) {
            Text('分类')
              .fontSize(14)
              .fontColor('#666')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.categories.filter(c => c !== '全部'), (cat: string) => {
                Text(cat)
                  .fontSize(13)
                  .fontColor(cat === this.newItemCategory ? '#fff' : '#666')
                  .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                  .backgroundColor(cat === this.newItemCategory ? '#007AFF' : '#F0F0F0')
                  .borderRadius(16)
                  .margin({ right: 8, bottom: 8 })
                  .onClick(() => {
                    this.newItemCategory = cat;
                  })
              })
            }
            .width('100%')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 购买日期
          Column({ space: 6 }) {
            Text('购买日期')
              .fontSize(14)
              .fontColor('#666')
            TextInput({ text: this.newItemDate, placeholder: 'YYYY-MM-DD' })
              .height(44)
              .backgroundColor('#F5F5F5')
              .borderRadius(10)
              .padding({ left: 14 })
              .onChange((value: string) => {
                this.newItemDate = value;
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 备注
          Column({ space: 6 }) {
            Text('备注')
              .fontSize(14)
              .fontColor('#666')
            TextInput({ text: this.newItemNote, placeholder: '备注信息（选填）' })
              .height(44)
              .backgroundColor('#F5F5F5')
              .borderRadius(10)
              .padding({ left: 14 })
              .onChange((value: string) => {
                this.newItemNote = value;
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')

      // 保存按钮
      Button() {
        Text('保存')
          .fontSize(16)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(48)
      .backgroundColor(this.newItemName.trim() ? '#007AFF' : '#B0D4FF')
      .borderRadius(24)
      .margin({ top: 16, bottom: 8 })
      .enabled(this.newItemName.trim().length > 0)
      .onClick(() => {
        this.saveNewItem();
      })
    }
    .padding({ left: 24, right: 24, top: 8, bottom: 24 })
    .width('100%')
    .height('100%')
  }

  @Builder
  categoryManageSheet() {
    Column() {
      Scroll() {
        if (this.managedCategories.length === 0) {
          EmptyState({ icon: '🏷', title: '还没有分类', subtitle: '点击下方按钮添加分类' })
        } else {
          Column({ space: 8 }) {
            ForEach(this.managedCategories, (category: Category, index: number) => {
              Row() {
                Text(category.name)
                  .fontSize(15)
                  .fontColor('#333')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                if (category.name === DEFAULT_CATEGORY_NAME) {
                  Text('默认')
                    .fontSize(12)
                    .fontColor('#999')
                } else {
                  Button('删除')
                    .type(ButtonType.Normal)
                    .backgroundColor(Color.Transparent)
                    .fontColor('#FF3B30')
                    .fontSize(14)
                    .padding({ left: 8, right: 8 })
                    .onClick(() => {
                      this.openDeleteCategoryDialog(category);
                    })
                }
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Color.White)
              .borderRadius(8)
            }, (category: Category, index: number) => category.id.toString())
          }
          .width('100%')
        }
      }
      .layoutWeight(1)
      .width('100%')

      Button() {
        Text('添加分类')
          .fontSize(16)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(44)
      .backgroundColor('#007AFF')
      .borderRadius(22)
      .margin({ top: 12, bottom: 8 })
      .onClick(() => {
        this.onAddCategoryTap();
      })
    }
    .padding({ left: 24, right: 24, top: 8, bottom: 24 })
    .width('100%')
    .height('100%')
  }

  build() {
    Stack() {
      PageBackground()
      Column() {
        // 搜索框
        Row() {

          TextInput({ placeholder: '搜索物品名称' })
            .backgroundColor(Color.Transparent)
            .layoutWeight(1)
            .height(44)
            .fontSize(16)
          Text('🔍')
            .fontSize(20)
            .width(30).height(30)
            .margin({ left: 20 })
        }
        .width('90%')
        .height(40)
        .borderRadius(30)
        .border({
          width: 2,
          color: '#43ffffff',
          radius: 30,
          style: BorderStyle.Solid
        })
        .margin({top: 62, bottom: 5})
        .backgroundBlurStyle(BlurStyle.Thin,
          { colorMode: ThemeColorMode.LIGHT, adaptiveColor: AdaptiveColor.DEFAULT, scale: 1.0 })


        // 分类标签栏
        Row({ space: 8 }) {
          CategoryGrid({
            categories: this.categories,
            selected: this.selectedCategory,
            onSelect: (category: string) => {
              this.onCategorySelect(category);
            }
          })
            .layoutWeight(1)
          Button('管理')
            .type(ButtonType.Normal)
            .fontColor('#ce007aff')
            .backgroundColor('#72d5edfd')
            .backgroundBlurStyle(BlurStyle.Thick,
              { colorMode: ThemeColorMode.LIGHT, adaptiveColor: AdaptiveColor.DEFAULT, scale: 1.0 })
            .borderRadius(14)
            .height(24)
            .fontSize(12)
            .padding({ left: 10, right: 10 })
            .margin({ right: 12, bottom: 6 })
            .onClick(() => {
              this.openCategoryManageSheet();
            })
        }
        .width("100%")

        // 内容区域
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
        } else if (this.filteredItems.length === 0) {
          Column() {
            if (this.items.length === 0) {
              EmptyState({ icon: '📦', title: '还没有物品', subtitle: '点击底部加号添加第一个物品' })
            } else {
              EmptyState({ icon: '🔍', title: '没有找到匹配的物品', subtitle: '试试调整筛选条件' })
            }
          }
          .width('100%')
          .layoutWeight(1)
        } else {
          List({ space: 8 }) {
            ForEach(this.filteredItems, (item: Item, index: number) => {
              ListItem() {
                ItemCard({
                  name: item.name,
                  category: item.category,
                  location: this.getItemLocationLabel(item.id),
                  onTap: () => {
                    AppStorage.setOrCreate('currentItemId', item.id);
                    router.pushUrl({ url: 'pages/ItemDetailPage' });
                  }
                })
                  .margin({ left: 16, right: 16 })
              }
            }, (item: Item, index: number) => item.id.toString())
            ListItem() {
              Row(){}.height(80)
            }
          }
          .width('100%')
          .layoutWeight(1)
          .divider({ strokeWidth: 0 })
          .scrollBar(BarState.Off)
          .padding({ top: 4 })
        }
      }
      .width('100%')
      .height('100%')
      .bindSheet(this.showCategoryManageSheet, this.categoryManageSheet, {
        height: '60%',
        dragBar: true,
        showClose: true,
        title: { title: '管理分类' },
        onDisappear: () => {
          this.showCategoryManageSheet = false;
        },
      })

    }
    .width('100%')
    .height('100%')
    //.key('addSheet-' + this.sheetKey)
    .bindSheet(this.showAddItemSheet, this.addItemSheet, {
      height: '75%',
      dragBar: true,
      showClose: true,
      title: { title: '添加物品' },
      onDisappear: () => {
        this.showAddItemSheet = false;
        AppStorage.setOrCreate('quickAddItemSpaceId', 0);
      },
    })
  }
}
