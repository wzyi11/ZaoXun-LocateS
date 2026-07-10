// import { router } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { ItemPage } from './ItemPage';
import { SpacePage } from './SpacePage';
import { EventPage } from './EventPage';

@Entry
@Component
struct Index {
  @State currentBottomNav: number = 0;
  @State currentTabIndex: number = 0;

  onPageShow(): void {
    this.currentBottomNav = 0;
    this.refreshCurrentTab();
  }

  build() {
    Column() {
      Row() {
        this.buildTopTab('📦 物品', 0)
        this.buildTopTab('🏠 空间', 1)
        this.buildTopTab('🎒 事件', 2)
      }
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })
      .backgroundColor(Color.White)

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
          Blank()
        }
      }
      .width('100%')
      .layoutWeight(1)

      Row() {
        this.buildBottomTab('🏠', '首页', 0)
        this.buildBottomTab('👤', '我的', 1)
      }
      .width('100%')
      .height(56)
      .backgroundBlurStyle(BlurStyle.Thin, {
        colorMode: ThemeColorMode.SYSTEM
      })
      .backgroundColor('#E8F0F0F0')
    }
    .width('100%')
    .height('100%')
    .padding({ top: 36 })
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildTopTab(label: string, index: number) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(15)
        .fontColor(this.currentTabIndex === index ? '#007AFF' : '#666')
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
      this.currentTabIndex = index;
      this.refreshCurrentTab();
    })
  }

  @Builder
  buildBottomTab(icon: string, label: string, index: number) {
    Button() {
      Column({ space: 2 }) {
        Text(icon)
          .fontSize(24)
        Text(label)
          .fontSize(11)
          .fontColor(this.currentBottomNav === index ? '#007AFF' : '#999')
      }
      .alignItems(HorizontalAlign.Center)
    }
    .type(ButtonType.Normal)
    .backgroundColor(Color.Transparent)
    .onClick(() => {
      if (index === 0) {
        this.currentBottomNav = 0;
        this.refreshCurrentTab();
      } else {
        this.currentBottomNav = 1;
        router.pushUrl({ url: 'pages/ProfilePage' });
      }
    })
    .layoutWeight(1)
  }

  refreshCurrentTab(): void {
    const token: number = Date.now();
    if (this.currentTabIndex === 0) {
      AppStorage.setOrCreate('itemRefreshToken', token);
    } else if (this.currentTabIndex === 1) {
      AppStorage.setOrCreate('spaceRefreshToken', token);
    }
  }
}
