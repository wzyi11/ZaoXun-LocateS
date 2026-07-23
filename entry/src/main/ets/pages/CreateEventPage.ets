import { router } from '@kit.ArkUI';
import { EventInput, combineEventDateAndTime, formatEventDateTime } from '../model/EventModel';
import { Item } from '../model/ItemModel';
import { EventRepository } from '../data/EventRepository';
import { ItemRepository } from '../data/ItemRepository';
import { EmptyState } from '../components/EmptyState';
import { PageBackground } from '../components/PageBackground';

@Entry
@Component
export struct CreateEventPage {
  @State title: string = '';
  @State date: string = '';
  @State selectedDate: Date = new Date();
  @State selectedTime: Date = new Date();
  @State note: string = '';
  @State items: Item[] = [];
  @State selectedIds: number[] = [];
  @State itemSearchKeyword: string = '';
  @State loading: boolean = true;
  private eventRepo: EventRepository = new EventRepository();
  private itemRepo: ItemRepository = new ItemRepository();

  aboutToAppear(): void {
    if (this.date === '') {
      this.selectedDate = new Date();
      this.selectedTime = new Date();
      this.updateDateTime();
    }
    this.loadItems();
  }

  async loadItems(): Promise<void> {
    this.loading = true;
    this.items = await this.itemRepo.getAll();
    this.loading = false;
  }

  isSelected(id: number): boolean {
    for (let i = 0; i < this.selectedIds.length; i++) {
      if (this.selectedIds[i] === id) {
        return true;
      }
    }
    return false;
  }

  toggleSelect(id: number): void {
    if (this.isSelected(id)) {
      const newArr: number[] = [];
      for (let i = 0; i < this.selectedIds.length; i++) {
        if (this.selectedIds[i] !== id) {
          newArr.push(this.selectedIds[i]);
        }
      }
      this.selectedIds = newArr;
    } else {
      this.selectedIds = [...this.selectedIds, id];
    }
  }

  updateDateTime(): void {
    const selected: Date = combineEventDateAndTime(this.selectedDate, this.selectedTime);
    this.date = formatEventDateTime(selected);
  }

  matchesItemSearch(item: Item): boolean {
    const keyword: string = this.itemSearchKeyword.trim().toLowerCase();
    if (keyword === '') {
      return true;
    }
    return item.name.toLowerCase().includes(keyword) || item.category.toLowerCase().includes(keyword);
  }

  async save(): Promise<void> {
    if (this.title.trim() === '' || this.date === '') {
      return;
    }
    const createTime: string = new Date().toISOString();
    const eventInput: EventInput = {
      'title': this.title.trim(),
      'date': this.date,
      'note': this.note,
      'status': 0,
      'createTime': createTime,
    };
    const eventId: number = await this.eventRepo.insert(eventInput);
    for (let i = 0; i < this.selectedIds.length; i++) {
      await this.eventRepo.linkItem(eventId, this.selectedIds[i]);
    }
    AppStorage.setOrCreate('eventRefreshToken', Date.now());
    router.back();
  }

  build() {
    Stack() { PageBackground()
      Column() {
      Row() {
        Button('取消')
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .fontColor('#007AFF')
          .onClick(() => {
            router.back();
          })
        Blank()
        Text('创建事件')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
        Blank()
        Button('保存')
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .fontColor('#007AFF')
          .onClick(() => {
            this.save();
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

      Column({ space: 16 }) {
        Column({ space: 6 }) {
          Text('事件名称')
            .fontSize(13)
            .fontColor('#999')
            .padding({ left: 2 })
          TextInput({ text: this.title, placeholder: '输入事件名称' })
            .onChange((value: string) => {
              this.title = value;
            })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')

        Column({ space: 6 }) {
          Text('日期')
            .fontSize(13)
            .fontColor('#999')
            .padding({ left: 2 })
          CalendarPicker({ selected: this.selectedDate, hintRadius: 16 })
            .height(44)
            .width('100%')
            .backgroundColor('#F5F5F5')
            .borderRadius(10)
            .markToday(true)
            .onChange((value: Date) => {
              this.selectedDate = value;
              this.updateDateTime();
            })
          TimePicker({ selected: this.selectedTime })
            .useMilitaryTime(true)
            .height(96)
            .width('100%')
            .backgroundColor('#F5F5F5')
            .borderRadius(10)
            .onChange((value: TimePickerResult) => {
              const hour: number = value.hour ?? this.selectedTime.getHours();
              const minute: number = value.minute ?? this.selectedTime.getMinutes();
              this.selectedTime = new Date(
                this.selectedDate.getFullYear(),
                this.selectedDate.getMonth(),
                this.selectedDate.getDate(),
                hour,
                minute,
                0,
                0
              );
              this.updateDateTime();
            })
          Text(this.date)
            .fontSize(12)
            .fontColor('#999')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')

        Column({ space: 6 }) {
          Text('备注')
            .fontSize(13)
            .fontColor('#999')
            .padding({ left: 2 })
          TextInput({ text: this.note, placeholder: '事件备注' })
            .onChange((value: string) => {
              this.note = value;
            })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')

        Text('关联物品')
          .fontSize(14)
          .fontColor('#999')
          .fontWeight(FontWeight.Medium)
          .padding({ top: 4 })
          .width('100%')

        if (this.loading) {
          Column() {
            LoadingProgress()
              .width(32)
              .height(32)
              .color('#007AFF')
          }
          .width('100%')
          .padding({ top: 40 })
        } else if (this.items.length === 0) {
          EmptyState({ icon: '📦', title: '还没有物品', subtitle: '请先在物品页添加物品' })
        } else {
          List({ space: 4 }) {
            ListItem() {
              Row() {
                TextInput({ placeholder: '搜索物品名称', text: this.itemSearchKeyword })
                  .backgroundColor(Color.Transparent)
                  .layoutWeight(1)
                  .height(40)
                  .fontSize(14)
                  .onChange((value: string) => {
                    this.itemSearchKeyword = value;
                  })
                Text('🔍')
                  .fontSize(18)
                  .width(28)
                  .height(28)
              }
              .width('100%')
              .height(40)
              .borderRadius(30)
              .border({
                width: 2,
                color: '#43ffffff',
                radius: 30,
                style: BorderStyle.Solid
              })
              .backgroundBlurStyle(BlurStyle.Thin,
                { colorMode: ThemeColorMode.LIGHT, adaptiveColor: AdaptiveColor.DEFAULT, scale: 1.0 })
            }
            ForEach(this.items, (item: Item, index: number) => {
              if (this.matchesItemSearch(item)) {
                ListItem() {
                  Row({ space: 8 }) {
                    Text(this.isSelected(item.id) ? '☑' : '☐')
                      .fontSize(20)
                      .fontColor(this.isSelected(item.id) ? '#007AFF' : '#CCC')
                    Column({ space: 2 }) {
                      Text(item.name)
                        .fontSize(14)
                        .fontColor('#333')
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      if (item.category !== '') {
                        Text(item.category)
                          .fontSize(11)
                          .fontColor('#999')
                      }
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)
                  }
                  .width('100%')
                  .padding({ left: 12, right: 12, top: 10, bottom: 10 })
                  .backgroundColor(this.isSelected(item.id) ? '#F0F7FF' : Color.White)
                  .borderRadius(8)
                  .onClick(() => {
                    this.toggleSelect(item.id);
                  })
                }
              }
            }, (item: Item, index: number) => item.id.toString())
          }
          .width('100%')
          .layoutWeight(1)
          .divider({ strokeWidth: 0 })
          .padding({ top: 4 })
        }

        Text(`已选择 ${this.selectedIds.length} 个物品`)
          .fontSize(12)
          .fontColor('#999')
          .width('100%')
      }
      .padding(16)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding({ top: 36 })
    }
    .width('100%')
    .height('100%')
  }
}
