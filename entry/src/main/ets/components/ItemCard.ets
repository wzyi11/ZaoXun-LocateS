@Component
export struct ItemCard {
  @Prop name: string = '';
  @Prop category: string = '';
  @Prop location: string = '';
  onTap: () => void = () => {};

  build() {
    Row() {
      Column({ space: 4 }) {
        Text(this.name)
          .fontSize(15)
          .fontColor('#333')
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row({ space: 8 }) {
          Text(this.category)
            .fontSize(11)
            .fontColor('#007AFF')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor('#EBF5FF')
            .borderRadius(4)
          Text(this.location)
            .fontSize(11)
            .fontColor('#999')
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('>')
        .fontSize(18)
        .fontColor('#CCC')
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#b9ffffff')
    .border({
      width: 3,
      color: '#43ffffff',
      radius: 8,
      style: BorderStyle.Solid
    })

    .borderRadius(8)
    .onClick(() => {
      this.onTap();
    })
  }
}
