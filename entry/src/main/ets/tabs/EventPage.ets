import { router } from '@kit.ArkUI';
import { Event, EventInput, EventItem, formatEventDate } from '../model/EventModel';
import { Item } from '../model/ItemModel';
import { EventRepository } from '../data/EventRepository';
import { ItemRepository } from '../data/ItemRepository';
import { EventCard } from '../components/EventCard';
import { CalendarPageView } from '../components/CalendarPageView';
import { EmptyState } from '../components/EmptyState';
import { PageBackground } from '../components/PageBackground';

interface EventListItem {
  event: Event;
  prepared: number;
  total: number;
}

@Component
export struct EventPage {
  @State activeEvents: EventListItem[] = [];
  @State completedEvents: EventListItem[] = [];
  @State loading: boolean = true;
  @State showAddEventSheet: boolean = false;
  @State eventSheetKey: number = 0;
  @State newEventTitle: string = '';
  @State newEventDate: string = '';
  @State newEventSelectedDate: Date = new Date();
  @State newEventNote: string = '';
  @State eventItems: Item[] = [];
  @State selectedItemIds: number[] = [];
  @State eventItemsLoading: boolean = true;
  @State activeTab: string = 'active';
  @StorageLink('eventRefreshToken') @Watch('onRefreshToken') eventRefreshToken: number = 0;
  @StorageLink('quickAddEvent') @Watch('onQuickAddEvent') quickAddEvent: number = 0;
  private repo: EventRepository = new EventRepository();
  private itemRepo: ItemRepository = new ItemRepository();

  aboutToAppear(): void {
    this.loadEvents();
  }

  onPageShow(): void {
    this.loadEvents();
  }

  onRefreshToken(): void {
    if (this.eventRefreshToken > 0) {
      this.loadEvents();
    }
  }

  onQuickAddEvent(): void {
    if (this.quickAddEvent <= 0) {
      return;
    }
    this.openAddEventSheet();
  }

  openAddEventSheet(): void {
    this.resetNewEventForm();
    this.showAddEventSheet = false;
    this.eventSheetKey++;
    this.showAddEventSheet = true;
    this.loadEventItems();
  }

  resetNewEventForm(): void {
    const today: Date = new Date();
    this.newEventTitle = '';
    this.newEventSelectedDate = today;
    this.newEventDate = formatEventDate(today);
    this.newEventNote = '';
    this.selectedItemIds = [];
  }

  async loadEventItems(): Promise<void> {
    this.eventItemsLoading = true;
    this.eventItems = await this.itemRepo.getAll();
    this.eventItemsLoading = false;
  }

  isSelected(id: number): boolean {
    for (let i = 0; i < this.selectedItemIds.length; i++) {
      if (this.selectedItemIds[i] === id) {
        return true;
      }
    }
    return false;
  }

  toggleSelect(id: number): void {
    if (this.isSelected(id)) {
      const newArr: number[] = [];
      for (let i = 0; i < this.selectedItemIds.length; i++) {
        if (this.selectedItemIds[i] !== id) {
          newArr.push(this.selectedItemIds[i]);
        }
      }
      this.selectedItemIds = newArr;
    } else {
      this.selectedItemIds = [...this.selectedItemIds, id];
    }
  }

  async saveNewEvent(): Promise<void> {
    if (this.newEventTitle.trim() === '' || this.newEventDate === '') {
      return;
    }
    const createTime: string = new Date().toISOString();
    const eventInput: EventInput = {
      title: this.newEventTitle.trim(),
      date: this.newEventDate,
      note: this.newEventNote,
      status: 0,
      createTime: createTime,
    };
    const eventId: number = await this.repo.insert(eventInput);
    for (let i = 0; i < this.selectedItemIds.length; i++) {
      await this.repo.linkItem(eventId, this.selectedItemIds[i]);
    }
    AppStorage.setOrCreate('eventRefreshToken', Date.now());
    this.resetNewEventForm();
    this.showAddEventSheet = false;
    this.loadEvents();
  }

  getEventListKey(item: EventListItem): string {
    return `${item.event.id}_${item.event.status}_${item.prepared}_${item.total}`;
  }

  async loadEvents(): Promise<void> {
    this.loading = true;
    const events: Event[] = await this.repo.getAll();
    const active: EventListItem[] = [];
    const completed: EventListItem[] = [];
    for (let i = 0; i < events.length; i++) {
      const evt: Event = events[i];
      const items: EventItem[] = await this.repo.getEventItems(evt.id);
      let prepared: number = 0;
      for (let j = 0; j < items.length; j++) {
        if (items[j].isPrepared) {
          prepared = prepared + 1;
        }
      }
      const listItem: EventListItem = {
        'event': evt,
        'prepared': prepared,
        'total': items.length,
      };
      if (evt.status === 1) {
        completed.push(listItem);
      } else {
        active.push(listItem);
      }
    }
    this.activeEvents = active;
    this.completedEvents = completed;
    this.loading = false;
  }

  @Builder
  addEventSheet() {
    Column() {
      Text('添加事件')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ bottom: 20 })

      Scroll() {
        Column({ space: 20 }) {
          Column({ space: 6 }) {
            Text('事件名称')
              .fontSize(14)
              .fontColor('#666')
            TextInput({ text: this.newEventTitle, placeholder: '输入事件名称' })
              .height(44)
              .backgroundColor('#F5F5F5')
              .borderRadius(10)
              .padding({ left: 14 })
              .onChange((value: string) => {
                this.newEventTitle = value;
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: 6 }) {
            Text('日期')
              .fontSize(14)
              .fontColor('#666')
            DatePicker({ selected: this.newEventSelectedDate })
              .height(120)
              .backgroundColor('#F5F5F5')
              .borderRadius(10)
              .width('100%')
              .onChange((value: DatePickerResult) => {
                const year: number = value.year ?? this.newEventSelectedDate.getFullYear();
                const month: number = value.month ?? this.newEventSelectedDate.getMonth() + 1;
                const day: number = value.day ?? this.newEventSelectedDate.getDate();
                const selected: Date = new Date(year, month - 1, day);
                this.newEventSelectedDate = selected;
                this.newEventDate = formatEventDate(selected);
              })
            Text(this.newEventDate)
              .fontSize(12)
              .fontColor('#999')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: 6 }) {
            Text('备注')
              .fontSize(14)
              .fontColor('#666')
            TextInput({ text: this.newEventNote, placeholder: '事件备注（选填）' })
              .height(44)
              .backgroundColor('#F5F5F5')
              .borderRadius(10)
              .padding({ left: 14 })
              .onChange((value: string) => {
                this.newEventNote = value;
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: 8 }) {
            Text('关联物品')
              .fontSize(14)
              .fontColor('#666')
            if (this.eventItemsLoading) {
              LoadingProgress()
                .width(32)
                .height(32)
                .color('#007AFF')
            } else if (this.eventItems.length === 0) {
              EmptyState({ icon: '📦', title: '还没有物品', subtitle: '可以先添加物品后再关联' })
            } else {
              Column({ space: 8 }) {
                ForEach(this.eventItems, (item: Item, index: number) => {
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
                }, (item: Item, index: number) => item.id.toString())
              }
              .width('100%')
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')

      Text(`已选择 ${this.selectedItemIds.length} 个物品`)
        .fontSize(12)
        .fontColor('#999')
        .width('100%')
        .margin({ top: 10 })

      Button() {
        Text('保存')
          .fontSize(16)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(48)
      .backgroundColor(this.newEventTitle.trim() && this.newEventDate !== '' ? '#007AFF' : '#B0D4FF')
      .borderRadius(24)
      .margin({ top: 12, bottom: 8 })
      .enabled(this.newEventTitle.trim().length > 0 && this.newEventDate !== '')
      .onClick(() => {
        this.saveNewEvent();
      })
    }
    .padding({ left: 24, right: 24, top: 8, bottom: 24 })
    .width('100%')
    .height('100%')
  }

  build() {
    Stack() {
      PageBackground()
      Column() {
        // 日历组件
        Row(){
          CalendarPageView({ compact: true, refreshKey: this.eventRefreshToken })
        }
        .width('90%')
        .margin({ top: 60 })

        // 分段控件
        Row({ space: 0 }) {
          Text('进行中')
            .fontSize(14)
            .fontWeight(this.activeTab === 'active' ? FontWeight.Medium : FontWeight.Regular)
            .fontColor(this.activeTab === 'active' ? '#FFFFFF' : '#666')
            .width('50%')
            .textAlign(TextAlign.Center)
            .padding({ top: 8, bottom: 8 })
            .backgroundColor(this.activeTab === 'active' ? '#007AFF' : '#F2F2F2')
            .borderRadius({ topLeft: 8, bottomLeft: 8 })
            .onClick(() => {
              this.activeTab = 'active';
            })

          Text('已完成')
            .fontSize(14)
            .fontWeight(this.activeTab === 'completed' ? FontWeight.Medium : FontWeight.Regular)
            .fontColor(this.activeTab === 'completed' ? '#FFFFFF' : '#666')
            .width('50%')
            .textAlign(TextAlign.Center)
            .padding({ top: 8, bottom: 8 })
            .backgroundColor(this.activeTab === 'completed' ? '#34C759' : '#F2F2F2')
            .borderRadius({ topRight: 8, bottomRight: 8 })
            .onClick(() => {
              this.activeTab = 'completed';
            })
        }
        .width('90%')
        .height(36)
        .margin({ top: 12, left: 16, right: 16 })
        .borderRadius(8)

        // 内容区域
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
        } else {
          List({ space: 8 }) {
            if (this.activeTab === 'active') {
              if (this.activeEvents.length === 0) {
                ListItem() {
                  EmptyState({ icon: '🎒', title: '没有进行中的事件', subtitle: '点击底部加号创建新事件' })
                }
              } else {
                ForEach(this.activeEvents, (item: EventListItem, index: number) => {
                  ListItem() {
                    EventCard({
                      title: item.event.title,
                      date: item.event.date,
                      status: item.event.status,
                      prepared: item.prepared,
                      total: item.total,
                      onTap: () => {
                        AppStorage.setOrCreate('currentEventId', item.event.id);
                        router.pushUrl({ url: 'pages/EventDetailPage' });
                      }
                    })
                      .margin({ left: 16, right: 16 })
                  }
                }, (item: EventListItem, index: number) => this.getEventListKey(item))
              }
            }

            if (this.activeTab === 'completed') {
              if (this.completedEvents.length === 0) {
                ListItem() {
                  EmptyState({ icon: '✅', title: '还没有已完成的事件', subtitle: '完成事件后会显示在这里' })
                }
              } else {
                ForEach(this.completedEvents, (item: EventListItem, index: number) => {
                  ListItem() {
                    EventCard({
                      title: item.event.title,
                      date: item.event.date,
                      status: item.event.status,
                      prepared: item.prepared,
                      total: item.total,
                      onTap: () => {
                        AppStorage.setOrCreate('currentEventId', item.event.id);
                        router.pushUrl({ url: 'pages/EventDetailPage' });
                      }
                    })
                      .margin({ left: 16, right: 16 })
                  }
                }, (item: EventListItem, index: number) => this.getEventListKey(item))
              }
            }
            ListItem() {
              Row(){}.height(80)
            }
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .padding({ top: 8, bottom: 80 })
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .bindSheet(this.showAddEventSheet, this.addEventSheet, {
      height: '75%',
      dragBar: true,
      showClose: true,
      title: { title: '添加事件' },
      onDisappear: () => {
        this.showAddEventSheet = false;
      },
    })
  }
}
