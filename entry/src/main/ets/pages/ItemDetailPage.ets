import { router } from '@kit.ArkUI';
import { Item } from '../model/ItemModel';
import { ItemRepository } from '../data/ItemRepository';

@Entry
@Component
export struct ItemDetailPage {
  @State item: Item | null = null;
  @State loading: boolean = true;
  private repo: ItemRepository = new ItemRepository();

  aboutToAppear(): void {
    const itemId: number = AppStorage.get<number>('currentItemId') ?? 0;
    if (itemId > 0) {
      this.loadItem(itemId);
    }
  }

  async loadItem(itemId: number): Promise<void> {
    this.loading = true;
    const result: Item | null = await this.repo.getById(itemId);
    this.item = result;
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
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Color.White)
          .borderRadius(8)

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
    .backgroundColor('#F5F5F5')
  }
}
