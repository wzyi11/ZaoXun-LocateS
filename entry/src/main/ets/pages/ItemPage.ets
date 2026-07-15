import { router } from '@kit.ArkUI';
import { Item } from '../model/ItemModel';
import { ItemRepository } from '../data/ItemRepository';
import { CategoryRepository } from '../data/CategoryRepository';
import { EmptyState } from '../components/EmptyState';
import { ItemCard } from '../components/ItemCard';
import { CategoryGrid } from '../components/CategoryGrid';

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
  @StorageLink('itemRefreshToken') @Watch('onRefreshToken') itemRefreshToken: number = 0;
  private repo: ItemRepository = new ItemRepository();
  private categoryRepo: CategoryRepository = new CategoryRepository();
  private addCategoryDialogController: CustomDialogController | null = null;

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
    const DEFAULT_CATEGORIES: string[] = ['全部', '衣物', '书籍', '数码', '厨房', '文件', '其他'];
    let cats = await this.categoryRepo.getAll();
    if (cats.length === 0) {
      for (const name of DEFAULT_CATEGORIES) {
        if (name !== '全部') {
          await this.categoryRepo.insert({ name });
        }
      }
      cats = await this.categoryRepo.getAll();
    }
    this.categories = ['全部', ...cats.map(c => c.name)];
  }

  onPageShow(): void {
    this.loadItems();
  }

  onRefreshToken(): void {
    if (this.itemRefreshToken > 0) {
      this.loadItems();
    }
  }

  async loadItems(): Promise<void> {
    this.loading = true;
    this.items = await this.repo.getAll();
    this.applyFilters();
    this.loading = false;
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
      });
    }
  }

  build() {
    Stack() {
      Column() {
        // 搜索框
        Row() {
          TextInput({ text: this.searchKeyword, placeholder: '搜索物品名称...' })
            .onChange((value: string) => {
              this.onSearchChange(value);
            })
            .layoutWeight(1)
            .backgroundColor('#d5F5F5')
            .padding({ left: 12, right: 40 })

          Text('🔍')
            .fontSize(20)
            .padding({right: 10})
            .onClick(() => {
              this.applyFilters();
            })
        }
        .backgroundColor('#d5F5F5')
        .borderRadius(15)
        .margin({left: 16, right: 16, top: 12, bottom: 4 })

        // 分类标签栏
        Row() {
          CategoryGrid({
            categories: this.categories,
            selected: this.selectedCategory,
            onSelect: (category: string) => {
              this.onCategorySelect(category);
            },
            onAddCategory: () => {
              this.onAddCategoryTap();
            }
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
              EmptyState({ icon: '📦', title: '还没有物品', subtitle: '点击右下角按钮添加第一个物品' })
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
                  location: item.spaceId > 0 ? `空间${item.spaceId}` : '未分配',
                  onTap: () => {
                    AppStorage.setOrCreate('currentItemId', item.id);
                    router.pushUrl({ url: 'pages/ItemDetailPage' });
                  }
                })
                  .margin({ left: 16, right: 16 })
              }
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
      .height('100%')

      // 右下角添加物品按钮
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
        AppStorage.setOrCreate('triggerAddItemSheet', Date.now());
      })
    }
    .width('100%')
    .height('100%')
  }
}
