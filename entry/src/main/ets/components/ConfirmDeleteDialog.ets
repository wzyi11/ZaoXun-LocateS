@CustomDialog
export struct ConfirmDeleteDialog {
  controller: CustomDialogController;
  title: string = '确认删除';
  message: string = '';
  onConfirm: () => void = () => {};

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#66000000')

      Column() {
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')

        Text(this.message)
          .fontSize(14)
          .fontColor('#666')
          .margin({ top: 12 })
          .textAlign(TextAlign.Center)

        Row({ space: 12 }) {
          Button('取消')
            .width(112)
            .height(40)
            .backgroundColor('#F0F0F0')
            .fontColor('#666')
            .borderRadius(20)
            .onClick(() => {
              this.controller.close();
            })

          Button('确认删除')
            .width(112)
            .height(40)
            .backgroundColor('#FF3B30')
            .fontColor(Color.White)
            .borderRadius(20)
            .onClick(() => {
              this.onConfirm();
              this.controller.close();
            })
        }
        .margin({ top: 22 })
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      .padding(24)
      .width('82%')
      .backgroundColor(Color.White)
      .borderRadius(16)
      .shadow({ radius: 16, color: '#33000000', offsetY: 6 })
    }
    .width('100%')
    .height('100%')
  }
}
