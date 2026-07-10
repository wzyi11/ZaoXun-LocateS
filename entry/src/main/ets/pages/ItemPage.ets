import { router } from '@kit.ArkUI';
import { Item } from '../model/ItemModel';
import { ItemRepository } from '../data/ItemRepository';
import { EmptyState } from '../components/EmptyState';
import { ItemCard } from '../components/ItemCard';
import { CategoryGrid } from '../components/CategoryGrid';

@Component
export struct ItemPage {
  @State items: Item[] = [];
  @State filteredItems: Item[] = [];
  @State searchKeyword: string = '';
  @State selectedCategory: string = '全部';
  @State loading: boolean = true;
  @StorageLink('itemRefreshToken') @Watch('onRefreshToken') itemRefreshToken: number = 0;
  private repo: ItemRepository = new ItemRepository();

  aboutToAppear(): void {
    this.loadItems();
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

  build() {
    Stack() {
      Column() {
        Row() {
          TextInput({ text: this.searchKeyword, placeholder: '搜索物品名称...' })
            .onChange((value: string) => {
              this.onSearchChange(value);
            })
            .layoutWeight(1)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding({ left: 12, right: 12 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 4 })

        CategoryGrid({
          selected: this.selectedCategory,
          onSelect: (category: string) => {
            this.onCategorySelect(category);
          }
        })

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
          .padding({ top: 4 })
        }
      }
      .width('100%')
      .height('100%')

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
        router.pushUrl({ url: 'pages/AddItemPage' });
      })
    }
    .width('100%')
    .height('100%')
  }
}
