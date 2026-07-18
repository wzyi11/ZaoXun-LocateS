import { router } from '@kit.ArkUI';
import { ItemPage } from './ItemPage';
import { SpacePage } from './SpacePage';
import { EventPage } from './EventPage';
import { ProfilePage } from './ProfilePage';
import { PageBackground } from '../components/PageBackground';
import { ENABLE_DEV_MODE } from '../model/DevMode';

interface BottomTabItem {
  icon: Resource;
  label: ResourceStr;
  index: number;
}

@Entry
@Component
struct Index {
  @State currentBottomNav: number = 0;
  @State currentTabIndex: number = 0;
  @State isFabActive: boolean = false;
  @StorageLink('statusBarHeight') statusBarHeight: number = 36;
  @StorageLink('naviIndicatorHeight') naviIndicatorHeight: number = 0;
  private tabRefreshSeq: number = 0;

  private bottomTabs: BottomTabItem[] = [
    { icon: $r('sys.symbol.house_fill'), label: '首页', index: 0 },
    { icon: $r('sys.symbol.person_crop_circle_fill'), label: '我的', index: 1 },
  ];

  onPageShow(): void {
    this.currentBottomNav = 0;
    this.refreshCurrentTab();
  }

  build() {
    Stack() {
      PageBackground()

      Column() {
        if (this.currentBottomNav === 0) {
          Row() {
            this.buildTopTab('📦 物品', 0)
            this.buildTopTab('🏠 空间', 1)
            this.buildTopTab('🎒 事件', 2)
            if (ENABLE_DEV_MODE) {
              Text('🔧')
                .fontSize(16)
                .fontColor('#666666')
              .width(36)
              .height(30)
              .textAlign(TextAlign.Center)
              .onClick(() => {
                router.pushUrl({ url: 'pages/DebugPage' });
              })
            }
          }
          .width('100%')
          .height(30)
          .padding({ left: 12, right: 12 })
          // .margin({ top: this.statusBarHeight + 4 })
          .margin({ top: 40 })
        }

        Stack() {
          if (this.currentBottomNav === 0) {
            if (this.currentTabIndex === 0) {
              ItemPage()
            } else if (this.currentTabIndex === 1) {
              SpacePage()
            } else {
              EventPage()
            }
          } else {
            ProfilePage()
          }
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')

      if (this.isFabActive) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#01000000')
          .onClick(() => {
            this.isFabActive = false;
          })
      }

      if (this.isFabActive) {
        Column() {
          Row({ space: 8 }) {
            this.buildQuickAction('📦', '物品', () => {
              this.isFabActive = false;
              router.pushUrl({ url: 'pages/AddItemPage' });
            })
            this.buildQuickAction('🏠', '空间', () => {
              this.isFabActive = false;
              this.currentBottomNav = 0;
              this.currentTabIndex = 1;
              AppStorage.setOrCreate('quickAddSpace', Date.now());
            })
            this.buildQuickAction('🎒', '事件', () => {
              this.isFabActive = false;
              router.pushUrl({ url: 'pages/CreateEventPage' });
            })
          }
          .padding({ left: 20, right: 20, top: 10, bottom: 10 })
          .backgroundBlurStyle(BlurStyle.Thin, { colorMode: ThemeColorMode.SYSTEM })
          .backgroundColor('#F0FFFFFF')
          .borderRadius(22)
          .shadow({ radius: 12, color: '#1A000000', offsetY: 4 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .position({ bottom: 10 + this.naviIndicatorHeight })
      }

      Row() {
        this.buildBottomTabItem(this.bottomTabs[0])

        Column() {
          Button() {
            SymbolGlyph($r('sys.symbol.plus'))
              .fontSize(24)
              .fontColor([Color.White])
          }
          .type(ButtonType.Circle)
          .width(56)
          .height(56)
          .backgroundColor('#007AFF')
          .shadow({ radius: 12, color: '#33007AFF', offsetY: 4 })
          .onClick(() => {
            this.isFabActive = !this.isFabActive;
          })
        }
        .offset({ y: -16 })
        .width(72)
        .alignItems(HorizontalAlign.Center)

        this.buildBottomTabItem(this.bottomTabs[1])
      }
      .width('100%')
      .height(68)
      .padding({ left: 20, right: 20 })
      // .margin({ left: 16, right: 16, bottom: 12 + this.naviIndicatorHeight })
      .margin({ left: 16, right: 16, bottom: 16 })
      .backgroundBlurStyle(BlurStyle.Thin, { colorMode: ThemeColorMode.SYSTEM })
      .backgroundColor('#F0F5F5F7')
      .borderRadius(34)
      .shadow({ radius: 16, color: '#1A000000', offsetY: -2 })
      .position({ bottom: 0 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildTopTab(label: string, index: number) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(16)
        .fontColor(this.currentTabIndex === index ? '#007AFF' : '#666666')
        .fontWeight(this.currentTabIndex === index ? FontWeight.Medium : FontWeight.Normal)
      if (this.currentTabIndex === index) {
        Divider()
          .width(24)
          .height(3)
          .color('#007AFF')
          .borderRadius(2)
      }
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .layoutWeight(1)
    .height('100%')
    .onClick(() => {
      this.currentBottomNav = 0;
      this.currentTabIndex = index;
      this.refreshCurrentTab();
    })
  }

  @Builder
  buildBottomTabItem(tab: BottomTabItem) {
    Column({ space: 2 }) {
      SymbolGlyph(tab.icon)
        .fontSize(22)
        .fontColor(this.currentBottomNav === tab.index ? ['#007AFF'] : ['#999999'])
      Text(tab.label)
        .fontSize(10)
        .fontColor(this.currentBottomNav === tab.index ? '#007AFF' : '#999999')
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .layoutWeight(1)
    .height('100%')
    .onClick(() => {
      this.currentBottomNav = tab.index;
      if (tab.index === 0) {
        this.refreshCurrentTab();
      }
      this.isFabActive = false;
    })
  }

  @Builder
  buildQuickAction(icon: string, label: string, onClick: () => void) {
    Column({ space: 4 }) {
      Text(icon)
        .fontSize(22)
      Text(label)
        .fontSize(11)
        .fontColor('#666666')
    }
    .alignItems(HorizontalAlign.Center)
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .borderRadius(16)
    .backgroundColor(Color.White)
    .onClick(onClick)
  }

  refreshCurrentTab(): void {
    this.tabRefreshSeq++;
    const token: number = this.tabRefreshSeq;
    if (this.currentTabIndex === 0) {
      AppStorage.setOrCreate('itemRefreshToken', token);
    } else if (this.currentTabIndex === 1) {
      AppStorage.setOrCreate('spaceRefreshToken', token);
    } else if (this.currentTabIndex === 2) {
      AppStorage.setOrCreate('eventRefreshToken', token);
    }
  }
}
