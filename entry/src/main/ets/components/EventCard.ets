@Component
export struct EventCard {
  @Prop title: string = '';
  @Prop date: string = '';
  @Prop status: number = 0;
  @Prop prepared: number = 0;
  @Prop total: number = 0;
  onTap: () => void = () => {};

  getStatusText(): string {
    return this.status === 1 ? '已完成' : '进行中';
  }

  getStatusColor(): string {
    return this.status === 1 ? '#34C759' : '#007AFF';
  }

  getStatusBgColor(): string {
    return this.status === 1 ? '#E8F8EE' : '#EBF5FF';
  }

  getProgressText(): string {
    return `${this.prepared}/${this.total}`;
  }

  getProgressValue(): number {
    if (this.total === 0) {
      return 0;
    }
    return this.prepared / this.total * 100;
  }

  build() {
    Row() {
      Column({ space: 8 }) {
        Row({ space: 6 }) {
          Text(this.title)
            .fontSize(15)
            .fontColor('#333')
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          Text(this.getStatusText())
            .fontSize(11)
            .fontColor(this.getStatusColor())
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor(this.getStatusBgColor())
            .borderRadius(4)
        }
        .width('100%')

        Row({ space: 8 }) {
          Text(this.date)
            .fontSize(12)
            .fontColor('#999')
          if (this.total > 0) {
            Text(this.getProgressText())
              .fontSize(12)
              .fontColor('#007AFF')
              .fontWeight(FontWeight.Medium)
          }
        }

        if (this.total > 0) {
          Progress({
            value: this.getProgressValue(),
            total: 100,
            type: ProgressType.Linear
          })
            .width('100%')
            .height(4)
            .color('#007AFF')
            .backgroundColor('#F0F0F0')
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('>')
        .fontSize(18)
        .fontColor('#CCC')
        .margin({ left: 8 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .onClick(() => {
      this.onTap();
    })
  }
}
