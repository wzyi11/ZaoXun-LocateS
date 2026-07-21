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
            .padding({ left: 8, right: 8, top: 5, bottom: 5 })
            .backgroundColor(category === this.selected ? '#007AFF' : '#59f0f0f0')
            .border({
              width: 1,
              color: '#ffffffff',
              radius: 14,
              style: BorderStyle.Solid
            })
            .height(24)
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
