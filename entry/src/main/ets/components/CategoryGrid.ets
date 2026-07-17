@Component
export struct CategoryGrid {
  @Prop categories: string[] = [];
  @Prop selected: string = '全部';
  onSelect: (category: string) => void = (category: string) => {};

  build() {
    Scroll() {
      Row() {
        ForEach(this.categories, (category: string, index: number) => {
          Text(category)
            .fontSize(12)
            .fontColor(category === this.selected ? '#fff' : '#666')
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor(category === this.selected ? '#007AFF' : '#F0F0F0')
            .borderRadius(14)
            .margin({ right: 8 })
            .onClick(() => {
              this.onSelect(category);
            })
        }, (category: string, index: number) => category)
      }
      .padding({ left: 16, right: 16, top: 4, bottom: 8 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }
}
