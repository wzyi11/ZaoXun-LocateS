import { router } from '@kit.ArkUI';
import { Item } from '../model/ItemModel';
import { Event } from '../model/EventModel';
import { Category } from '../model/CategoryModel';
import { ItemRepository } from '../data/ItemRepository';
import { EventRepository } from '../data/EventRepository';
import { CategoryRepository, DEFAULT_CATEGORY_NAME } from '../data/CategoryRepository';
import { PageBackground } from '../components/PageBackground';

interface CategoryCount {
  name: string;
  count: number;
}

@Component
export struct ProfilePage {
  @State totalItems: number = 0;
  @State categoryCounts: CategoryCount[] = [];
  @State activeEventCount: number = 0;
  @State completedEventCount: number = 0;
  @State upcomingEvents: Event[] = [];
  @State loading: boolean = true;
  @StorageLink('itemRefreshToken') @Watch('onProfileRefresh') itemRefreshToken: number = 0;
  @StorageLink('eventRefreshToken') @Watch('onProfileRefresh') eventRefreshToken: number = 0;
  private itemRepo: ItemRepository = new ItemRepository();
  private eventRepo: EventRepository = new EventRepository();
  private categoryRepo: CategoryRepository = new CategoryRepository();

  aboutToAppear(): void {
    this.loadStats();
  }

  onPageShow(): void {
    this.loadStats();
  }

  onProfileRefresh(): void {
    this.loadStats();
  }

  async loadStats(): Promise<void> {
    this.loading = true;
    try {
    const items: Item[] = await this.itemRepo.getAll();
    const events: Event[] = await this.eventRepo.getAll();
    const categories: Category[] = await this.categoryRepo.ensureDefaults();

    this.totalItems = items.length;

    const counts: CategoryCount[] = [];
    for (let i = 0; i < categories.length; i++) {
      const catName: string = categories[i].name;
      let cnt: number = 0;
      for (let j = 0; j < items.length; j++) {
        if (items[j].category === catName) {
          cnt = cnt + 1;
        }
      }
      const cc: CategoryCount = { 'name': catName, 'count': cnt };
      counts.push(cc);
    }
    this.categoryCounts = counts;
    const otherIdx: number = this.categoryCounts.findIndex((cc: CategoryCount) => cc.name === DEFAULT_CATEGORY_NAME);
    if (otherIdx >= 0) {
      const other: CategoryCount = this.categoryCounts[otherIdx];
      this.categoryCounts.splice(otherIdx, 1);
      this.categoryCounts.push(other);
    }

    let activeCnt: number = 0;
    let completedCnt: number = 0;
    const upcoming: Event[] = [];
    for (let i = 0; i < events.length; i++) {
      const evt: Event = events[i];
      if (evt.status === 0) {
        activeCnt = activeCnt + 1;
        if (upcoming.length < 3) {
          upcoming.push(evt);
        }
      } else {
        completedCnt = completedCnt + 1;
      }
    }
    this.activeEventCount = activeCnt;
    this.completedEventCount = completedCnt;
    this.upcomingEvents = upcoming;
    } catch (err) {
      console.error('[ProfilePage] loadStats failed', JSON.stringify(err));
    } finally {
    this.loading = false;
    }
  }

  build() {
    Stack() {
      PageBackground()
      Column() {
      Row() {
        Button('返回')
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .fontColor('#007AFF')
          .onClick(() => {
            router.back();
          })
        Blank()
        Text('我的')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('返回')
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .fontColor(Color.Transparent)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(Color.White)

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
        List({ space: 12 }) {
          ListItem() {
            Column() {
              Row() {
                Text('📦')
                  .fontSize(24)
                Text('物品总数')
                  .fontSize(15)
                  .fontColor('#666')
                  .margin({ left: 8 })
                Blank()
                Text(this.totalItems.toString())
                  .fontSize(28)
                  .fontColor('#007AFF')
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(8)
          }

          ListItem() {
            Column({ space: 10 }) {
              Row() {
                Text('📊')
                  .fontSize(18)
                Text('分类统计')
                  .fontSize(14)
                  .fontColor('#666')
                  .fontWeight(FontWeight.Medium)
                  .margin({ left: 6 })
              }
              .width('100%')

              Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceEvenly }) {
                ForEach(this.categoryCounts, (cc: CategoryCount, index: number) => {
                  Column({ space: 4 }) {
                    Text(cc.count.toString())
                      .fontSize(20)
                      .fontColor('#333')
                      .fontWeight(FontWeight.Bold)
                    Text(cc.name)
                      .fontSize(11)
                      .fontColor('#999')
                  }
                  .width(72)
                  .padding({ top: 8, bottom: 8 })
                  .alignItems(HorizontalAlign.Center)
                  .margin({ bottom: 4 })
                }, (cc: CategoryCount, index: number) => cc.name)
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(8)
          }

          ListItem() {
            Column({ space: 10 }) {
              Row() {
                Text('🎒')
                  .fontSize(18)
                Text('事件统计')
                  .fontSize(14)
                  .fontColor('#666')
                  .fontWeight(FontWeight.Medium)
                  .margin({ left: 6 })
              }
              .width('100%')

              Row({ space: 12 }) {
                Column({ space: 4 }) {
                  Text(this.activeEventCount.toString())
                    .fontSize(24)
                    .fontColor('#007AFF')
                    .fontWeight(FontWeight.Bold)
                  Text('进行中')
                    .fontSize(12)
                    .fontColor('#999')
                }
                .layoutWeight(1)
                .padding(12)
                .backgroundColor('#F5F9FF')
                .borderRadius(8)
                .alignItems(HorizontalAlign.Center)

                Column({ space: 4 }) {
                  Text(this.completedEventCount.toString())
                    .fontSize(24)
                    .fontColor('#34C759')
                    .fontWeight(FontWeight.Bold)
                  Text('已完成')
                    .fontSize(12)
                    .fontColor('#999')
                }
                .layoutWeight(1)
                .padding(12)
                .backgroundColor('#F5FFF5')
                .borderRadius(8)
                .alignItems(HorizontalAlign.Center)
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(8)
          }

          ListItem() {
            Column({ space: 10 }) {
              Row() {
                Text('⏰')
                  .fontSize(18)
                Text('进行中提醒')
                  .fontSize(14)
                  .fontColor('#666')
                  .fontWeight(FontWeight.Medium)
                  .margin({ left: 6 })
              }
              .width('100%')

              if (this.upcomingEvents.length === 0) {
                Text('暂无提醒')
                  .fontSize(13)
                  .fontColor('#999')
                  .padding({ top: 4 })
                  .width('100%')
              }
              ForEach(this.upcomingEvents, (evt: Event, index: number) => {
                Row({ space: 8 }) {
                  Column({ space: 2 }) {
                    Text(evt.title)
                      .fontSize(14)
                      .fontColor('#333')
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    if (evt.date !== '') {
                      Text(evt.date)
                        .fontSize(11)
                        .fontColor('#999')
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  Text('进行中')
                    .fontSize(10)
                    .fontColor('#007AFF')
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .backgroundColor('#EBF5FF')
                    .borderRadius(4)
                }
                .width('100%')
                .padding({ top: 6, bottom: 6 })
              }, (evt: Event, index: number) => evt.id.toString())
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(8)
          }

          ListItem() {
            Row({ space: 8 }) {
              Text('🎨')
                .fontSize(20)
              Text('背景设置')
                .fontSize(15)
                .fontColor('#333')
                .layoutWeight(1)
              Text('›')
                .fontSize(16)
                .fontColor('#CCC')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .onClick(() => {
              router.pushUrl({ url: 'pages/BackgroundSettingsPage' });
            })
          }

          ListItem() {
            Column({ space: 4 }) {
              Text('智能收纳管家')
                .fontSize(16)
                .fontColor('#333')
                .fontWeight(FontWeight.Medium)
              Text('物品管理 · 空间管理 · 事件清单')
                .fontSize(12)
                .fontColor('#999')
              Text('HarmonyOS 6.1 · ArkTS')
                .fontSize(11)
                .fontColor('#CCC')
                .margin({ top: 4 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .alignItems(HorizontalAlign.Center)
          }
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 0 })
        .scrollBar(BarState.Off)
        .padding({ left: 16, right: 16, top: 12, bottom: 24 })
      }
    }
    .width('100%')
    .height('100%')
    .padding({ top: 36 })
    }
    .width('100%')
    .height('100%')
  }
}
