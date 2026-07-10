@Component
export struct EmptyState {
  @Prop icon: string = '📦';
  @Prop title: string = '';
  @Prop subtitle: string = '';

  build() {
    Column({ space: 12 }) {
      Text(this.icon)
        .fontSize(48)
      Text(this.title)
        .fontSize(16)
        .fontColor('#333')
        .fontWeight(FontWeight.Medium)
      if (this.subtitle !== '') {
        Text(this.subtitle)
          .fontSize(13)
          .fontColor('#999')
      }
    }
    .width('100%')
    .padding({ top: 60 })
    .alignItems(HorizontalAlign.Center)
  }
}
