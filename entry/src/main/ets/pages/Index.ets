// import { router } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { ItemPage } from './ItemPage';
import { SpacePage } from './SpacePage';
import { EventPage } from './EventPage';
import { PageBackground } from '../components/PageBackground';

@Entry
@Component
struct Index {
  // 底部导航，两个，用来变样式
  @State currentBottomNav: number = 0;
  // 顶部选项，3个
  @State currentTabIndex: number = 0;

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

      // HDS 风格浮动底部导航栏
      Row() {
        this.buildBottomTabItem(this.bottomTabs[0])
        this.buildBottomTabItem(this.bottomTabs[1])
      }
      .width('100%')
      .height(64)
      .padding({ left: 16, right: 16, top: 0, bottom: 0 })
      .backgroundBlurStyle(BlurStyle.Thin, {
        colorMode: ThemeColorMode.SYSTEM
      })
      .backgroundColor('#E8F5F5F7')
    }
    .width('100%')
    .height('100%')
    .padding({ top: 36 })
    }
    .width('100%')
    .height('100%')
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
      if (tab.index === 0) {
        this.currentBottomNav = 0;
        this.refreshCurrentTab();
      } else {
        this.currentBottomNav = 1;
        router.pushUrl({ url: 'pages/ProfilePage' });
      }
    })
  }

  refreshCurrentTab(): void {
    const token: number = Date.now();
    if (this.currentTabIndex === 0) {
      AppStorage.setOrCreate('itemRefreshToken', token);
    } else if (this.currentTabIndex === 1) {
      AppStorage.setOrCreate('spaceRefreshToken', token);
    } else if (this.currentTabIndex === 2) {
      AppStorage.setOrCreate('eventRefreshToken', token);
    }
  }
}

interface BottomTabItem {
  icon: Resource;
  label: ResourceStr;
  index: number;
}
