import { router } from '@kit.ArkUI';
import { Item } from '../model/ItemModel';
import { ItemRepository } from '../data/ItemRepository';
import { CategoryRepository } from '../data/CategoryRepository';

@Entry
@Component
export struct ItemDetailPage {
  @State item: Item | null = null;
  @State loading: boolean = true;
  @State isEditing: boolean = false;
  @State editCategories: string[] = [];

  // 编辑用副本
  @State editName: string = '';
  @State editCategory: string = '';
  @State editPrice: string = '';
  @State editQuantity: number = 1;
  @State editPurchaseDate: string = '';
  @State editExpiryDate: string = '';
  @State editNote: string = '';

  private repo: ItemRepository = new ItemRepository();
  private categoryRepo: CategoryRepository = new CategoryRepository();

  aboutToAppear(): void {
    const itemId: number = AppStorage.get<number>('currentItemId') ?? 0;
    if (itemId > 0) {
      this.loadItem(itemId);
    }
    this.loadCategories();
  }

  async loadCategories(): Promise<void> {
    const cats = await this.categoryRepo.getAll();
    this.editCategories = cats.map(c => c.name);
  }

  async loadItem(itemId: number): Promise<void> {
    this.loading = true;
    const result: Item | null = await this.repo.getById(itemId);
    this.item = result;
    if (result) {
      this.editName = result.name;
      this.editCategory = result.category;
      this.editPrice = result.price;
      this.editQuantity = result.quantity;
      this.editPurchaseDate = result.purchaseDate;
      this.editExpiryDate = result.expiryDate;
      this.editNote = result.note;
    }
    this.loading = false;
  }

  async deleteItem(): Promise<void> {
    if (this.item !== null) {
      await this.repo.delete(this.item.id);
      router.back();
    }
  }

  async saveEdit(): Promise<void> {
    if (this.item === null || this.editName.trim() === '') return;
    const updated: Item = {
      id: this.item.id,
      name: this.editName.trim(),
      category: this.editCategory,
      spaceId: this.item.spaceId,
      image: this.item.image,
      purchaseDate: this.editPurchaseDate,
      price: this.editPrice,
      quantity: this.editQuantity,
      expiryDate: this.editExpiryDate,
      note: this.editNote,
      createTime: this.item.createTime,
    };
    await this.repo.update(updated);
    this.item = updated;
    AppStorage.setOrCreate('itemRefreshToken', Date.now());
    this.isEditing = false;
  }

  cancelEdit(): void {
    if (this.item) {
      this.editName = this.item.name;
      this.editCategory = this.item.category;
      this.editPrice = this.item.price;
      this.editQuantity = this.item.quantity;
      this.editPurchaseDate = this.item.purchaseDate;
      this.editExpiryDate = this.item.expiryDate;
      this.editNote = this.item.note;
    }
    this.isEditing = false;
  }

  getDetailTitle(): string {
    if (this.isEditing) return '编辑物品';
    return this.item !== null ? this.item.name : '物品详情';
  }

  build() {
    Column() {
      // 顶栏
      Row() {
        Button('返回')
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .fontColor('#007AFF')
          .onClick(() => {
            if (this.isEditing) {
              this.cancelEdit();
            } else {
              router.back();
            }
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
          if (this.isEditing) {
            Button('取消')
              .type(ButtonType.Normal)
              .backgroundColor(Color.Transparent)
              .fontColor('#999')
              .onClick(() => this.cancelEdit())
          } else {
            Button('编辑')
              .type(ButtonType.Normal)
              .backgroundColor(Color.Transparent)
              .fontColor('#007AFF')
              .onClick(() => { this.isEditing = true; })
          }
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
      } else if (this.isEditing) {
        // ====== 编辑模式 ======
        Scroll() {
          Column({ space: 16 }) {
            // 名称
            Column({ space: 6 }) {
              Text('名称').fontSize(14).fontColor('#666')
              TextInput({ text: this.editName, placeholder: '输入物品名称' })
                .height(44).backgroundColor('#F5F5F5').borderRadius(10).padding({ left: 14 })
                .onChange(v => { this.editName = v; })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 分类
            Column({ space: 6 }) {
              Text('分类').fontSize(14).fontColor('#666')
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.editCategories, (cat: string) => {
                  Text(cat)
                    .fontSize(13)
                    .fontColor(cat === this.editCategory ? '#fff' : '#666')
                    .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                    .backgroundColor(cat === this.editCategory ? '#007AFF' : '#F0F0F0')
                    .borderRadius(16)
                    .margin({ right: 8, bottom: 8 })
                    .onClick(() => { this.editCategory = cat; })
                })
              }
              .width('100%')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 价格 + 数量
            Row({ space: 12 }) {
              Column({ space: 6 }) {
                Text('价格 (元)').fontSize(14).fontColor('#666')
                TextInput({ text: this.editPrice, placeholder: '0.00' })
                  .height(44).backgroundColor('#F5F5F5').borderRadius(10).padding({ left: 14 })
                  .onChange(v => { this.editPrice = v; })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Column({ space: 6 }) {
                Text('数量').fontSize(14).fontColor('#666')
                Row({ space: 4 }) {
                  Button('-').width(36).height(36).backgroundColor('#F0F0F0')
                    .fontColor('#333').fontSize(18).borderRadius(18)
                    .onClick(() => { if (this.editQuantity > 1) this.editQuantity--; })
                  Text(this.editQuantity.toString()).fontSize(16).fontWeight(FontWeight.Medium)
                    .width(40).textAlign(TextAlign.Center)
                  Button('+').width(36).height(36).backgroundColor('#F0F0F0')
                    .fontColor('#333').fontSize(18).borderRadius(18)
                    .onClick(() => { this.editQuantity++; })
                }
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')

            // 购买日期
            Column({ space: 6 }) {
              Text('购买日期').fontSize(14).fontColor('#666')
              TextInput({ text: this.editPurchaseDate, placeholder: 'YYYY-MM-DD' })
                .height(44).backgroundColor('#F5F5F5').borderRadius(10).padding({ left: 14 })
                .onChange(v => { this.editPurchaseDate = v; })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 保质期
            Column({ space: 6 }) {
              Text('保质期').fontSize(14).fontColor('#666')
              TextInput({ text: this.editExpiryDate, placeholder: 'YYYY-MM-DD' })
                .height(44).backgroundColor('#F5F5F5').borderRadius(10).padding({ left: 14 })
                .onChange(v => { this.editExpiryDate = v; })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 备注
            Column({ space: 6 }) {
              Text('备注').fontSize(14).fontColor('#666')
              TextInput({ text: this.editNote, placeholder: '备注信息' })
                .height(44).backgroundColor('#F5F5F5').borderRadius(10).padding({ left: 14 })
                .onChange(v => { this.editNote = v; })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)

        // 保存按钮
        Button() {
          Text('保存修改')
            .fontSize(16).fontColor(Color.White).fontWeight(FontWeight.Medium)
        }
        .width('90%')
        .height(48)
        .backgroundColor(this.editName.trim() ? '#007AFF' : '#B0D4FF')
        .borderRadius(24)
        .margin({ bottom: 24 })
        .onClick(() => {
          if (this.editName.trim().length > 0) {
            this.saveEdit();
          }
        })
      } else {
        // ====== 查看模式 ======
        Scroll() {
          Column({ space: 16 }) {
            // 照片
            if (this.item.image !== '') {
              Row() {
                Text('照片').fontSize(14).fontColor('#999').width(70)
                Text('已上传').fontSize(15).fontColor('#007AFF').layoutWeight(1)
              }
              .width('100%').padding(12).backgroundColor(Color.White).borderRadius(8)
            }

            Row() {
              Text('名称').fontSize(14).fontColor('#999').width(70)
              Text(this.item.name).fontSize(15).fontColor('#333').layoutWeight(1)
            }
            .width('100%').padding(12).backgroundColor(Color.White).borderRadius(8)

            Row() {
              Text('分类').fontSize(14).fontColor('#999').width(70)
              Text(this.item.category).fontSize(12).fontColor('#007AFF')
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .backgroundColor('#EBF5FF').borderRadius(4)
            }
            .width('100%').padding(12).backgroundColor(Color.White).borderRadius(8)

            if (this.item.price !== '' && this.item.price !== '0') {
              Row() {
                Text('价格').fontSize(14).fontColor('#999').width(70)
                Text(`¥${this.item.price}`).fontSize(15).fontColor('#333').layoutWeight(1)
              }
              .width('100%').padding(12).backgroundColor(Color.White).borderRadius(8)
            }

            if (this.item.quantity > 1) {
              Row() {
                Text('数量').fontSize(14).fontColor('#999').width(70)
                Text(`${this.item.quantity}`).fontSize(15).fontColor('#333').layoutWeight(1)
              }
              .width('100%').padding(12).backgroundColor(Color.White).borderRadius(8)
            }

            if (this.item.purchaseDate !== '') {
              Row() {
                Text('购买日期').fontSize(14).fontColor('#999').width(70)
                Text(this.item.purchaseDate).fontSize(15).fontColor('#333').layoutWeight(1)
              }
              .width('100%').padding(12).backgroundColor(Color.White).borderRadius(8)
            }

            if (this.item.expiryDate !== '') {
              Row() {
                Text('保质期').fontSize(14).fontColor('#999').width(70)
                Text(this.item.expiryDate).fontSize(15).fontColor('#333').layoutWeight(1)
              }
              .width('100%').padding(12).backgroundColor(Color.White).borderRadius(8)
            }

            if (this.item.note !== '') {
              Row() {
                Text('备注').fontSize(14).fontColor('#999').width(70)
                Text(this.item.note).fontSize(15).fontColor('#333').layoutWeight(1)
              }
              .width('100%').padding(12).backgroundColor(Color.White).borderRadius(8)
            }

            Row() {
              Text('创建时间').fontSize(14).fontColor('#999').width(70)
              Text(this.item.createTime).fontSize(15).fontColor('#333').layoutWeight(1)
            }
            .width('100%').padding(12).backgroundColor(Color.White).borderRadius(8)

            // 删除按钮
            Button() {
              Text('删除物品')
                .fontSize(16).fontColor('#FF3B30').fontWeight(FontWeight.Medium)
            }
            .width('90%').height(48)
            .backgroundColor('#FFF0EF')
            .borderRadius(24)
            .onClick(() => { this.deleteItem(); })
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .padding({ top: 36 })
    .backgroundColor('#F5F5F5')
  }
}
