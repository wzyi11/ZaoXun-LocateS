import { router } from '@kit.AbilityKit';
import { SpacePage } from './SpacePage';
import { EventPage } from './EventPage';

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0;    // 0=物品 1=空间 2=事件
  @State currentBottomNav: number = 0;   // 0=首页 1=我的
  @StorageLink('deviceSupportsImmersive') deviceSupportsImmersive: boolean = true;

  private tabsController: TabsController = new TabsController();

  aboutToAppear(): void {
    // Detect device support for immersive blur effect
    // Fallback: use BlurStyle.Thin for all devices on HarmonyOS 6.1
    // Since @hms.hds.hdsMaterial is unavailable, we use native ArkUI blur
    this.deviceSupportsImmersive = true;
  }

  build() {
    Column() {
      // === Top three tabs (immersive floating tabs) ===
      Tabs({
        barPosition: BarPosition.Start,
        controller: this.tabsController
      }) {
        TabContent() {
          // ItemPage placeholder - 物品 tab
          Column() {
            Text('物品管理')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 40 })
            Text('添加、查找、管理你的物品')
              .fontSize(14)
              .fontColor('#999')
              .margin({ top: 8 })
          }
          .width('100%')
          .height('100%')
          .alignItems(HorizontalAlign.Center)
        }
        .tabBar('📦 物品')

        TabContent() {
          SpacePage()
        }
        .tabBar('🏠 空间')

        TabContent() {
          EventPage()
        }
        .tabBar('🎒 事件')
      }
      .barOverlap(true)
      .barBackgroundBlurStyle(BlurStyle.Thin)
      .barBackgroundColor('#E8F0F0F0')
      .onChange((index: number) => {
        this.currentTabIndex = index;
      })
      .layoutWeight(1)

      // === Bottom navigation (immersive blur effect) ===
      Row() {
        Button() {
          Column({ space: 2 }) {
            Text('🏠')
              .fontSize(24)
            Text('首页')
              .fontSize(11)
              .fontColor(this.currentBottomNav === 0 ? '#007AFF' : '#999')
          }
          .alignItems(HorizontalAlign.Center)
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.currentBottomNav = 0;
          this.tabsController.changeIndex(0);
        })
        .layoutWeight(1)

        Button() {
          Column({ space: 2 }) {
            Text('👤')
              .fontSize(24)
            Text('我的')
              .fontSize(11)
              .fontColor(this.currentBottomNav === 1 ? '#007AFF' : '#999')
          }
          .alignItems(HorizontalAlign.Center)
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.currentBottomNav = 1;
          router.pushUrl({ url: 'pages/ProfilePage' });
        })
        .layoutWeight(1)
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
    .backgroundColor('#F5F5F5')
  }
}
