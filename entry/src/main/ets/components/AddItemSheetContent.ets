import { Item, ItemInput } from '../model/ItemModel';
import { ItemRepository } from '../data/ItemRepository';
import { CategoryRepository } from '../data/CategoryRepository';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

@Component
export struct AddItemSheetContent {
  @State newItemName: string = '';
  @State newItemCategory: string = '其他';
  @State newItemPurchaseDate: string = '';
  @State newItemPrice: string = '';
  @State newItemQuantity: number = 1;
  @State newItemExpiryDate: string = '';
  @State newItemNote: string = '';
  @State newItemImage: string = '';
  @State categories: string[] = [];
  @State saved: boolean = false;
  private repo: ItemRepository = new ItemRepository();
  private categoryRepo: CategoryRepository = new CategoryRepository();

  aboutToAppear(): void {
    this.loadCategories();
  }

  async loadCategories(): Promise<void> {
    const cats = await this.categoryRepo.getAll();
    this.categories = cats.map(c => c.name);
  }

  resetForm(): void {
    this.newItemName = '';
    this.newItemCategory = '其他';
    this.newItemPurchaseDate = '';
    this.newItemPrice = '';
    this.newItemQuantity = 1;
    this.newItemExpiryDate = '';
    this.newItemNote = '';
    this.newItemImage = '';
    this.saved = false;
  }

  async pickPhoto(): Promise<void> {
    try {
      const picker = new photoAccessHelper.PhotoViewPicker();
      const result = await picker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1,
      });
      if (result.photoUris && result.photoUris.length > 0) {
        this.newItemImage = result.photoUris[0];
      }
    } catch (err) {
      console.error('PhotoPicker error: ' + JSON.stringify(err));
    }
  }

  async save(): Promise<void> {
    if (this.newItemName.trim() === '') {
      return;
    }
    const createTime: string = new Date().toISOString();
    const itemInput: ItemInput = {
      name: this.newItemName.trim(),
      category: this.newItemCategory,
      spaceId: 0,
      image: this.newItemImage,
      purchaseDate: this.newItemPurchaseDate,
      price: this.newItemPrice,
      quantity: this.newItemQuantity,
      expiryDate: this.newItemExpiryDate,
      note: this.newItemNote,
      createTime: createTime,
    };
    await this.repo.insert(itemInput);
    AppStorage.setOrCreate('itemRefreshToken', Date.now());
    AppStorage.setOrCreate('addItemSaved', Date.now());
    this.saved = true;
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 20 }) {
          // ===== 拍照上传 =====
          Column() {
            Text('实物照片')
              .fontSize(14)
              .fontColor('#666')
              .width('100%')
              .textAlign(TextAlign.Start)
              .margin({ bottom: 8 })

            Button() {
              if (this.newItemImage) {
                Column() {
                  Text('📷 已选择照片')
                    .fontSize(14)
                    .fontColor('#007AFF')
                  Text(this.newItemImage.split('/').pop() || '')
                    .fontSize(11)
                    .fontColor('#999')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .justifyContent(FlexAlign.Center)
              } else {
                Column({ space: 4 }) {
                  Text('📷')
                    .fontSize(28)
                  Text('点击拍照或从相册选择')
                    .fontSize(13)
                    .fontColor('#999')
                }
                .justifyContent(FlexAlign.Center)
              }
            }
            .width('100%')
            .height(100)
            .backgroundColor(this.newItemImage ? '#EBF5FF' : '#F5F5F5')
            .borderRadius(12)
            .border({ width: 1, color: this.newItemImage ? '#007AFF' : '#E0E0E0' })
            .onClick(() => {
              this.pickPhoto();
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // ===== 名称 =====
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

          // ===== 分类 =====
          Column({ space: 6 }) {
            Text('分类')
              .fontSize(14)
              .fontColor('#666')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.categories, (cat: string) => {
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

          // ===== 价格 + 数量 同行 =====
          Row({ space: 12 }) {
            Column({ space: 6 }) {
              Text('价格 (元)')
                .fontSize(14)
                .fontColor('#666')
              TextInput({ text: this.newItemPrice, placeholder: '0.00' })
                .height(44)
                .backgroundColor('#F5F5F5')
                .borderRadius(10)
                .padding({ left: 14 })
                .onChange((value: string) => {
                  this.newItemPrice = value;
                })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Column({ space: 6 }) {
              Text('数量')
                .fontSize(14)
                .fontColor('#666')
              Row({ space: 4 }) {
                Button('-')
                  .width(36)
                  .height(36)
                  .backgroundColor('#F0F0F0')
                  .fontColor('#333')
                  .fontSize(18)
                  .borderRadius(18)
                  .onClick(() => {
                    if (this.newItemQuantity > 1) {
                      this.newItemQuantity--;
                    }
                  })
                Text(this.newItemQuantity.toString())
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .width(40)
                  .textAlign(TextAlign.Center)
                Button('+')
                  .width(36)
                  .height(36)
                  .backgroundColor('#F0F0F0')
                  .fontColor('#333')
                  .fontSize(18)
                  .borderRadius(18)
                  .onClick(() => {
                    this.newItemQuantity++;
                  })
              }
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')

          // ===== 购买日期 =====
          Column({ space: 6 }) {
            Text('购买日期')
              .fontSize(14)
              .fontColor('#666')
            TextInput({ text: this.newItemPurchaseDate, placeholder: 'YYYY-MM-DD' })
              .height(44)
              .backgroundColor('#F5F5F5')
              .borderRadius(10)
              .padding({ left: 14 })
              .onChange((value: string) => {
                this.newItemPurchaseDate = value;
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // ===== 保质期 =====
          Column({ space: 6 }) {
            Text('保质期')
              .fontSize(14)
              .fontColor('#666')
            TextInput({ text: this.newItemExpiryDate, placeholder: 'YYYY-MM-DD（选填）' })
              .height(44)
              .backgroundColor('#F5F5F5')
              .borderRadius(10)
              .padding({ left: 14 })
              .onChange((value: string) => {
                this.newItemExpiryDate = value;
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // ===== 备注 =====
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
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST,
      })

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
      .onClick(() => {
        if (this.newItemName.trim().length > 0) {
          this.save();
        }
      })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 24, right: 24 })
  }
}
