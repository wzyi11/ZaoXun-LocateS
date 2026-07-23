interface DayInfo {
  day: number;
  isCurrentMonth: boolean;
  isToday: boolean;
  hasEvents: boolean;
}

@Component
export struct CalendarView {
  @Prop @Watch('rebuildGrid') events: number[] = [];
  onDateClick?: (day: number) => void;
  onMonthChange?: (year: number, month: number) => void;
  @State @Watch('rebuildGrid') currentYear: number = 2026;
  @State @Watch('rebuildGrid') currentMonth: number = 7;
  @State selectedDay: number = -1;
  @State dayGrid: DayInfo[] = [];
  private weekDays: string[] = ['日', '一', '二', '三', '四', '五', '六'];

  aboutToAppear(): void {
    const now: Date = new Date();
    this.currentYear = now.getFullYear();
    this.currentMonth = now.getMonth() + 1;
    this.rebuildGrid();
  }

  rebuildGrid(): void {
    const days: DayInfo[] = [];
    const totalDays: number = new Date(this.currentYear, this.currentMonth, 0).getDate();
    const firstDay: number = new Date(this.currentYear, this.currentMonth - 1, 1).getDay();
    const today: Date = new Date();
    const todayDate: number = today.getDate();
    const todayMonth: number = today.getMonth() + 1;
    const todayYear: number = today.getFullYear();

    // 上月补齐
    const prevMonthDays: number = new Date(this.currentYear, this.currentMonth - 1, 0).getDate();
    for (let i = firstDay - 1; i >= 0; i--) {
      days.push({ day: prevMonthDays - i, isCurrentMonth: false, isToday: false, hasEvents: false });
    }

    // 本月
    for (let d = 1; d <= totalDays; d++) {
      days.push({
        day: d,
        isCurrentMonth: true,
        isToday: d === todayDate && this.currentMonth === todayMonth && this.currentYear === todayYear,
        hasEvents: this.events.indexOf(d) >= 0,
      });
    }

    // 下月补齐
    const remainder: number = (7 - (days.length % 7)) % 7;
    for (let d = 1; d <= remainder; d++) {
      days.push({ day: d, isCurrentMonth: false, isToday: false, hasEvents: false });
    }

    this.dayGrid = days;
  }

  prevMonth(): void {
    if (this.currentMonth === 1) {
      this.currentMonth = 12;
      this.currentYear--;
    } else {
      this.currentMonth--;
    }
    this.selectedDay = -1;
    this.onMonthChange?.(this.currentYear, this.currentMonth);
  }

  nextMonth(): void {
    if (this.currentMonth === 12) {
      this.currentMonth = 1;
      this.currentYear++;
    } else {
      this.currentMonth++;
    }
    this.selectedDay = -1;
    this.onMonthChange?.(this.currentYear, this.currentMonth);
  }

  getDayColor(dayInfo: DayInfo): string {
    if (!dayInfo.isCurrentMonth) return '#CCC';
    if (this.selectedDay === dayInfo.day) return '#FFFFFF';
    return '#333';
  }

  getDayBg(dayInfo: DayInfo): string {
    if (this.selectedDay === dayInfo.day && dayInfo.isCurrentMonth) return '#007AFF';
    return 'transparent';
  }

  build() {
    Column({ space: 4 }) {
      // 月份导航栏
      Row() {
        Button('‹')
          .fontSize(22)
          .fontColor('#007AFF')
          .backgroundColor(Color.Transparent)
          .onClick(() => this.prevMonth())

        Text(`${this.currentYear}年${this.currentMonth}月`)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('›')
          .fontSize(22)
          .fontColor('#007AFF')
          .backgroundColor(Color.Transparent)
          .onClick(() => this.nextMonth())
      }
      .width('100%')

      // 星期表头
      Row() {
        ForEach(this.weekDays, (day: string, index: number) => {
          Text(day)
            .fontSize(12)
            .fontColor(index === 0 || index === 6 ? '#FF3B30' : '#666')
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        }, (day: string) => day)
      }
      .width('100%')

      // 日期网格
      Grid() {
        ForEach(this.dayGrid, (dayInfo: DayInfo, index: number) => {
          GridItem() {
            Column() {
              Column() {
                Text(dayInfo.day.toString())
                  .fontSize(16)
                  .fontColor(this.getDayColor(dayInfo))
                  .fontWeight(dayInfo.isToday ? FontWeight.Bold : FontWeight.Normal)
                  .textAlign(TextAlign.Center)
                  .height(dayInfo.hasEvents && this.selectedDay === dayInfo.day ? 20 : 30)
                  .width(34)

                if (dayInfo.hasEvents && this.selectedDay === dayInfo.day) {
                  Text('|')
                    .fontSize(7)
                    .fontColor('#FFFFFF')
                    .height(5)
                    .lineHeight(5)
                  Text('•')
                    .fontSize(12)
                    .fontColor('#FFFFFF')
                    .height(7)
                    .lineHeight(7)
                }
              }
              .width(34)
              .height(34)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .backgroundColor(this.getDayBg(dayInfo))
              .borderRadius(17)
              .borderWidth(dayInfo.isToday && this.selectedDay !== dayInfo.day ? 1.5 : 0)
              .borderColor('#007AFF')
              .borderStyle(BorderStyle.Solid)

              if (dayInfo.hasEvents && this.selectedDay !== dayInfo.day) {
                Text('•')
                  .fontSize(6)
                  .fontColor('#007AFF')
                  .lineHeight(6)
              } else {
                Text('')
                  .fontSize(6)
                  .lineHeight(6)
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
            .height(34)
          }
          .onClick(() => {
            if (dayInfo.isCurrentMonth) {
              this.selectedDay = dayInfo.day;
              this.onDateClick?.(dayInfo.day);
            }
          })
        }, (dayInfo: DayInfo, index: number) => `${dayInfo.day}-${dayInfo.isCurrentMonth}-${dayInfo.isToday}`)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsGap(0)
      .columnsGap(0)
      .width('100%')
      .height(220)
    }
    .width('100%')
    .padding(6)
    .backgroundColor(Color.White)
    .borderRadius(10)
  }
}
