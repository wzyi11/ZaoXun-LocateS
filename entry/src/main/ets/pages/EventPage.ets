import { router } from '@kit.ArkUI';
import { Event, EventItem } from '../model/EventModel';
import { EventRepository } from '../data/EventRepository';
import { EventCard } from '../components/EventCard';
import { EmptyState } from '../components/EmptyState';

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
  @StorageLink('eventRefreshToken') @Watch('onRefreshToken') eventRefreshToken: number = 0;
  private repo: EventRepository = new EventRepository();

  aboutToAppear(): void {
    this.loadEvents();
  }

  onRefreshToken(): void {
    if (this.eventRefreshToken > 0) {
      this.loadEvents();
    }
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

  build() {
    Stack() {
      Column() {
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
        } else if (this.activeEvents.length === 0 && this.completedEvents.length === 0) {
          Column() {
            EmptyState({ icon: '🎒', title: '还没有事件', subtitle: '点击右下角按钮创建第一个事件' })
          }
          .width('100%')
          .layoutWeight(1)
        } else {
          List({ space: 8 }) {
            if (this.activeEvents.length > 0) {
              ListItem() {
                Row() {
                  Text('进行中')
                    .fontSize(13)
                    .fontColor('#999')
                    .fontWeight(FontWeight.Medium)
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 4, bottom: 4 })
              }
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
              }, (item: EventListItem, index: number) => item.event.id.toString())
            }

            if (this.completedEvents.length > 0) {
              ListItem() {
                Row() {
                  Text('已完成')
                    .fontSize(13)
                    .fontColor('#999')
                    .fontWeight(FontWeight.Medium)
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 12, bottom: 4 })
              }
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
              }, (item: EventListItem, index: number) => item.event.id.toString())
            }
          }
          .width('100%')
          .layoutWeight(1)
          .divider({ strokeWidth: 0 })
          .scrollBar(BarState.Off)
          .padding({ top: 4, bottom: 80 })
        }
      }
      .width('100%')
      .height('100%')

      Button() {
        Text('+')
          .fontSize(28)
          .fontColor(Color.White)
      }
      .width(56)
      .height(56)
      .borderRadius(28)
      .backgroundColor('#007AFF')
      .position({ x: '100%', y: '100%' })
      .markAnchor({ x: '100%', y: '100%' })
      .offset({ x: -24, y: -24 })
      .shadow({ radius: 8, color: '#33007AFF', offsetY: 4 })
      .onClick(() => {
        router.pushUrl({ url: 'pages/CreateEventPage' });
      })
    }
    .width('100%')
    .height('100%')
  }
}
