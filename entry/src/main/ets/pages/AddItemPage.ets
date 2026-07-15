import { router } from '@kit.ArkUI';
import { Item, ItemInput } from '../model/ItemModel';
import { ItemRepository } from '../data/ItemRepository';
import { PageBackground } from '../components/PageBackground';

const CATEGORIES: string[] = ['衣物', '书籍', '数码', '厨房', '文件', '其他'];

@Entry
@Component
export struct AddItemPage {
  @State name: string = '';
  @State category: string = '其他';
  @State purchaseDate: string = '';
  @State note: string = '';
  private repo: ItemRepository = new ItemRepository();

  build() {
    Stack() { PageBackground()
      Column() {
      Row() {
        Button('取消')
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .fontColor('#007AFF')
          .onClick(() => {
            router.back();
          })
        Blank()
        Text('添加物品')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
        Blank()
        Button('保存')
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .fontColor('#007AFF')
          .onClick(() => {
            this.save();
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

      Column({ space: 16 }) {
        Column({ space: 6 }) {
          Text('名称')
            .fontSize(13)
            .fontColor('#999')
            .padding({ left: 2 })
          TextInput({ text: this.name, placeholder: '输入物品名称' })
            .onChange((value: string) => {
              this.name = value;
            })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')

        Column({ space: 6 }) {
          Text('分类')
            .fontSize(13)
            .fontColor('#999')
            .padding({ left: 2 })
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(CATEGORIES, (cat: string, index: number) => {
              Text(cat)
                .fontSize(13)
                .fontColor(cat === this.category ? '#fff' : '#666')
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(cat === this.category ? '#007AFF' : '#F0F0F0')
                .borderRadius(14)
                .margin({ right: 8, bottom: 8 })
                .onClick(() => {
                  this.category = cat;
                })
            }, (cat: string, index: number) => cat)
          }
          .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')

        Column({ space: 6 }) {
          Text('购买日期')
            .fontSize(13)
            .fontColor('#999')
            .padding({ left: 2 })
          TextInput({ text: this.purchaseDate, placeholder: 'YYYY-MM-DD' })
            .onChange((value: string) => {
              this.purchaseDate = value;
            })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')

        Column({ space: 6 }) {
          Text('备注')
            .fontSize(13)
            .fontColor('#999')
            .padding({ left: 2 })
          TextInput({ text: this.note, placeholder: '备注信息' })
            .onChange((value: string) => {
              this.note = value;
            })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }
      .padding(16)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    }
  }

  async save(): Promise<void> {
    if (this.name.trim() === '') {
      return;
    }
    const createTime: string = new Date().toISOString();
    const itemInput: ItemInput = {
      name: this.name.trim(),
      category: this.category,
      spaceId: 0,
      image: '',
      purchaseDate: this.purchaseDate,
      note: this.note,
      createTime: createTime,
    };
    await this.repo.insert(itemInput);
    AppStorage.setOrCreate('itemRefreshToken', Date.now());
    router.back();
  }
}
