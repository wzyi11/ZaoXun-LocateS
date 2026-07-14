interface CardData {
  title: string;
  subtitle: string;
  hasActiveEvent: boolean;
}

@Entry
@Component
struct WidgetCard {
  readonly TITLE: string = '智能收纳管家';
  readonly SUBTITLE: string = '打开应用查看待办清单';
  readonly HAS_ACTIVE_EVENT: boolean = false;

  build() {
    Stack() {
      Column({ space: 8 }) {
        Text('📦')
          .fontSize(28)
        Text(this.TITLE)
          .fontSize(15)
          .fontColor('#333')
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.SUBTITLE)
          .fontSize(12)
          .fontColor('#999')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height('100%')
      .padding(12)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
  }
}
