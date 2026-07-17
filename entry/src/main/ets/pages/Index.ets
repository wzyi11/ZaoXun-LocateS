import { router } from '@kit.ArkUI';
import { ItemPage } from './ItemPage';
import { SpacePage } from './SpacePage';
import { EventPage } from './EventPage';
import { PageBackground } from '../components/PageBackground';

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
      // ====== 渐变背景层 ======
      PageBackground()

      // ====== 主内容 ======
      Column() {
        // 顶部 Tab
        Row() {
          this.buildTopTab('📦 物品', 0)
          this.buildTopTab('🏠 空间', 1)
          this.buildTopTab('🎒 事件', 2)
        }
        .width('100%')
        .height(48)
        .padding({ left: 12, right: 12 })

        // 内容区
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
      }
      .width('100%')
      .height('100%')

      // ====== miniBar 快速操作栏 ======
      if (this.isFabActive) {
        Column() {
          Row({ space: 8 }) {
            this.buildQuickAction('📦', '物品', () => {
              this.isFabActive = false;
              router.pushUrl({ url: 'pages/AddItemPage' });
            })
            this.buildQuickAction('🏠', '空间', () => {
              this.isFabActive = false;
              this.currentTabIndex = 1;
              this.currentBottomNav = 0;
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
        .position({ bottom: 100 })
      }

      // ====== miniBar 点击关闭覆盖层 ======
      if (this.isFabActive) {
        Column()
          .width('100%')
          .height('100%')
          .onClick(() => {
            this.isFabActive = false;
          })
      }

      // ====== HDS 浮动底部导航栏 ======
      Row() {
        // 首页 Tab
        this.buildBottomTabItem(this.bottomTabs[0])

        // 中间 FAB
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

        // 我的 Tab
        this.buildBottomTabItem(this.bottomTabs[1])
      }
      .width('100%')
      .height(68)
      .padding({ left: 20, right: 20, top: 0, bottom: 0 })
      .margin({ left: 16, right: 16, bottom: 12 })
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
        .fontSize(15)
        .fontColor(this.currentTabIndex === index ? '#007AFF' : '#666666')
        .fontWeight(this.currentTabIndex === index ? FontWeight.Medium : FontWeight.Normal)
      if (this.currentTabIndex === index) {
        Divider()
          .width(24).height(3).color('#007AFF').borderRadius(2)
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
