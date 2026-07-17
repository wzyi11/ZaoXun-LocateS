import { router } from '@kit.ArkUI';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { Event, EventItem } from '../model/EventModel';
import { Item } from '../model/ItemModel';
import { EventRepository } from '../data/EventRepository';
import { ItemRepository } from '../data/ItemRepository';
import { BusinessError } from '@kit.BasicServicesKit';
import { PageBackground } from '../components/PageBackground';
import { ConfirmDeleteDialog } from '../components/ConfirmDeleteDialog';

interface EventItemDetail {
  eventItemId: number;
  itemId: number;
  itemName: string;
  itemCategory: string;
  isPrepared: boolean;
}

@Entry
@Component
export struct EventDetailPage {
  @State event: Event | null = null;
  @State checklist: EventItemDetail[] = [];
  @State prepared: number = 0;
  @State total: number = 0;
  @State loading: boolean = true;
  @State currentEventId: number = 0;
  @State updatingItemId: number = 0;
  private eventRepo: EventRepository = new EventRepository();
  private itemRepo: ItemRepository = new ItemRepository();
  private deleteDialogController: CustomDialogController | null = null;

  aboutToAppear(): void {
    const eventId: number = AppStorage.get<number>('currentEventId') ?? 0;
    this.currentEventId = eventId;
    if (eventId > 0) {
      this.loadData(eventId);
    } else {
      this.loading = false;
    }
  }

  aboutToDisappear(): void {
    AppStorage.setOrCreate('eventRefreshToken', Date.now());
  }

  async loadData(eventId: number, showLoading: boolean = true): Promise<void> {
    if (showLoading) {
      this.loading = true;
    }
    const evt: Event | null = await this.eventRepo.getById(eventId);
    this.event = evt;
    if (evt === null) {
      this.checklist = [];
      this.prepared = 0;
      this.total = 0;
      this.loading = false;
      return;
    }

    const eventItems: EventItem[] = await this.eventRepo.getEventItems(eventId);
    const list: EventItemDetail[] = [];
    let prepCount: number = 0;
    for (let i = 0; i < eventItems.length; i++) {
      const ei: EventItem = eventItems[i];
      const item: Item | null = await this.itemRepo.getById(ei.itemId);
      const detail: EventItemDetail = {
        'eventItemId': ei.id,
        'itemId': ei.itemId,
        'itemName': item !== null ? item.name : '未知物品',
        'itemCategory': item !== null ? item.category : '',
        'isPrepared': ei.isPrepared,
      };
      if (ei.isPrepared) {
        prepCount = prepCount + 1;
      }
      list.push(detail);
    }
    this.checklist = list;
    this.prepared = prepCount;
    this.total = eventItems.length;
    this.loading = false;
  }

  async togglePrepared(index: number): Promise<void> {
    if (index < 0 || index >= this.checklist.length) {
      return;
    }

    const detail: EventItemDetail = this.checklist[index];
    if (this.updatingItemId !== 0) {
      return;
    }

    const newPrepared: boolean = !detail.isPrepared;
    this.updatingItemId = detail.eventItemId;

    const newList: EventItemDetail[] = [];
    let prepCount: number = 0;
    for (let i = 0; i < this.checklist.length; i++) {
      const item: EventItemDetail = this.checklist[i];
      const isPrep: boolean = i === index ? newPrepared : item.isPrepared;
      newList.push({
        'eventItemId': item.eventItemId,
        'itemId': item.itemId,
        'itemName': item.itemName,
        'itemCategory': item.itemCategory,
        'isPrepared': isPrep,
      });
      if (isPrep) {
        prepCount = prepCount + 1;
      }
    }
    this.checklist = newList;
    this.prepared = prepCount;
    this.total = newList.length;

    try {
      await this.eventRepo.updateEventItemPrepared(detail.eventItemId, newPrepared);
      if (this.currentEventId > 0) {
        await this.loadData(this.currentEventId, false);
      }
      AppStorage.setOrCreate('eventRefreshToken', Date.now());
    } catch (err) {
      console.error(`Toggle prepared failed: ${JSON.stringify(err)}`);
      if (this.currentEventId > 0) {
        await this.loadData(this.currentEventId, false);
      }
    } finally {
      this.updatingItemId = 0;
    }
  }

  async markComplete(): Promise<void> {
    if (this.event === null) {
      return;
    }
    await this.eventRepo.complete(this.event.id);
    const updatedEvent: Event = {
      'id': this.event.id,
      'title': this.event.title,
      'date': this.event.date,
      'note': this.event.note,
      'status': 1,
      'createTime': this.event.createTime,
    };
    this.event = updatedEvent;
    AppStorage.setOrCreate('eventRefreshToken', Date.now());
  }

  async deleteEvent(): Promise<void> {
    if (this.event === null) {
      return;
    }
    await this.eventRepo.delete(this.event.id);
    AppStorage.setOrCreate('eventRefreshToken', Date.now());
    router.back();
  }

  openDeleteEventDialog(): void {
    if (this.event === null) {
      return;
    }
    this.deleteDialogController = new CustomDialogController({
      builder: ConfirmDeleteDialog({
        title: '删除事件',
        message: `确认删除“${this.event.title}”？事件清单也会一并删除。`,
        onConfirm: () => {
          this.deleteEvent();
        }
      }),
      autoCancel: true,
      customStyle: true,
      maskColor: '#66000000',
      cornerRadius: 16,
    });
    this.deleteDialogController.open();
  }

  @Builder
  DeleteEventButton() {
    Button() {
      Text('删除事件')
        .fontSize(16)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .height(48)
    .backgroundColor('#FF3B30')
    .borderRadius(8)
    .onClick(() => {
      this.openDeleteEventDialog();
    })
  }

  getStatusText(): string {
    if (this.event === null) {
      return '';
    }
    return this.event.status === 1 ? '已完成' : '进行中';
  }

  getStatusColor(): string {
    if (this.event === null) {
      return '#999';
    }
    return this.event.status === 1 ? '#34C759' : '#007AFF';
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

  allPrepared(): boolean {
    return this.total > 0 && this.prepared === this.total;
  }

  isCompleted(): boolean {
    return this.event !== null && this.event.status === 1;
  }

  buildShareText(): string {
    if (this.event === null) {
      return '';
    }

    const statusText: string = this.isCompleted() ? '已完成' : '进行中';
    const progressText: string = this.total > 0 ? ` (${this.prepared}/${this.total})` : '';

    const lines: string[] = [];
    lines.push(`【事件】${this.event.title}`);
    if (this.event.date !== '') {
      lines.push(`日期: ${this.event.date}`);
    }
    lines.push(`状态: ${statusText}${progressText}`);
    if (this.event.note !== '') {
      lines.push(`备注: ${this.event.note}`);
    }

    if (this.total > 0) {
      lines.push('');
      lines.push('物品清单:');
      for (let i = 0; i < this.checklist.length; i++) {
        const detail: EventItemDetail = this.checklist[i];
        const marker: string = detail.isPrepared ? '✅' : '⬜';
        lines.push(`  ${marker} ${detail.itemName}`);
      }
    }

    lines.push('');
    lines.push('-- 来自智能收纳管家');
    return lines.join('\n');
  }

  doShare(): void {
    if (this.event === null) {
      return;
    }

    const shareText: string = this.buildShareText();
    if (shareText === '') {
      return;
    }

    try {
      const shareData: systemShare.SharedData = new systemShare.SharedData({
        utd: utd.UniformDataType.TEXT,
        content: shareText,
        title: this.event.title,
        description: `事件分享: ${this.event.title}`,
      });
      const controller: systemShare.ShareController = new systemShare.ShareController(shareData);
      const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
      controller.show(context, {
        selectionMode: systemShare.SelectionMode.SINGLE,
        previewMode: systemShare.SharePreviewMode.DETAIL,
      }).then(() => {
        console.info('ShareController show success.');
      }).catch((error: BusinessError) => {
        console.error(`ShareController show error. code: ${error.code}, message: ${error.message}`);
      });
    } catch (err) {
      console.error(`Share failed: ${JSON.stringify(err)}`);
    }
  }

  build() {
    Stack() { PageBackground()
      Column() {
      Row() {
        Button('返回')
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .fontColor('#007AFF')
          .width(112)
          .align(Alignment.Start) // 内容靠左对齐
          .onClick(() => {
            router.back();
          })

        Text('事件详情')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
        Row() {
          Button('分享')
            .type(ButtonType.Normal)
            .backgroundColor(Color.Transparent)
            .fontColor('#007AFF')
            .onClick(() => {
              this.doShare();
            })
          if (!this.isCompleted() && this.event !== null) {
            Button('完成')
              .type(ButtonType.Normal)
              .backgroundColor(Color.Transparent)
              .fontColor('#34C759')
              .onClick(() => {
                this.markComplete();
              })
          }
        }
        .width(112)
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .padding(16)
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
      } else if (this.event === null) {
        Column() {
          Text('事件不存在')
            .fontSize(16)
            .fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Column({ space: 16 }) {
          Row({ space: 8 }) {
            Text(this.event.title)
              .fontSize(18)
              .fontColor('#333')
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(this.getStatusText())
              .fontSize(12)
              .fontColor(this.getStatusColor())
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .backgroundColor(this.isCompleted() ? '#E8F8EE' : '#EBF5FF')
              .borderRadius(4)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8)

          if (this.event.date !== '' || this.event.note !== '') {
            Column({ space: 8 }) {
              if (this.event.date !== '') {
                Row() {
                  Text('日期')
                    .fontSize(14)
                    .fontColor('#999')
                    .width(50)
                  Text(this.event.date)
                    .fontSize(15)
                    .fontColor('#333')
                    .layoutWeight(1)
                }
                .width('100%')
              }
              if (this.event.note !== '') {
                Row() {
                  Text('备注')
                    .fontSize(14)
                    .fontColor('#999')
                    .width(50)
                  Text(this.event.note)
                    .fontSize(15)
                    .fontColor('#333')
                    .layoutWeight(1)
                }
                .width('100%')
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .alignItems(HorizontalAlign.Start)
          }

          Column({ space: 8 }) {
            Row() {
              Text('清单进度')
                .fontSize(14)
                .fontColor('#666')
                .fontWeight(FontWeight.Medium)
              Blank()
              Text(this.getProgressText())
                .fontSize(14)
                .fontColor('#007AFF')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')

            Progress({
              value: this.getProgressValue(),
              total: 100,
              type: ProgressType.Linear
            })
              .width('100%')
              .height(6)
              .color(this.isCompleted() ? '#34C759' : '#007AFF')
              .backgroundColor('#F0F0F0')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8)

          if (this.total > 0) {
            Text('物品清单')
              .fontSize(14)
              .fontColor('#666')
              .fontWeight(FontWeight.Medium)
              .padding({ left: 4 })

            List({ space: 4 }) {
              ForEach(this.checklist, (detail: EventItemDetail, index: number) => {
                ListItem() {
                  Row({ space: 10 }) {
                    Text(detail.isPrepared ? '✅' : '⬜')
                      .fontSize(20)
                    Column({ space: 2 }) {
                      if (detail.isPrepared) {
                        Text(detail.itemName)
                          .fontSize(14)
                          .fontColor('#999')
                          .decoration({ type: TextDecorationType.LineThrough })
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                      } else {
                        Text(detail.itemName)
                          .fontSize(14)
                          .fontColor('#333')
                          .decoration({ type: TextDecorationType.None })
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                      }
                      if (detail.itemCategory !== '') {
                        Text(detail.itemCategory)
                          .fontSize(11)
                          .fontColor('#999')
                      }
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                  .backgroundColor(Color.White)
                  .borderRadius(8)
                  .onClick(() => {
                    if (!this.isCompleted()) {
                      this.togglePrepared(index);
                    }
                  })
                }
              }, (detail: EventItemDetail, index: number) => `${detail.eventItemId}_${detail.isPrepared ? 'p' : 'u'}`)
              ListItem() {
                Column() {
                  this.DeleteEventButton()
                }
                .margin({ top: 12 })
              }
            }
            .width('100%')
            .layoutWeight(1)
            .divider({ strokeWidth: 0 })
          } else {
            this.DeleteEventButton()
          }
        }
        .padding(16)
        .layoutWeight(1)
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
