import { router } from '@kit.ArkUI';
import {
  HdsBarStyle,
  hdsMaterial,
  HdsNavDestination,
  HdsTabs,
  HdsTabsController,
} from '@kit.UIDesignKit';
import { PageKeyEnum, TabsBarModel } from '../model/ToolsBarModel';
import { ItemPage } from './ItemPage';
import { SpacePage } from './SpacePage';
import { EventPage } from './EventPage';
import { ProfilePage } from './ProfilePage';
import { PageBackground } from '../components/PageBackground';

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0;
  @State isMiniBar: boolean = true;
  @StorageLink('statusBarHeight') statusBarHeight: number = 36;
  @StorageLink('naviIndicatorHeight') naviIndicatorHeight: number = 0;
  private tabRefreshSeq: number = 0;
  private controller: HdsTabsController = new HdsTabsController();
  private tabsBar: BottomTabBarStyle[] = TabsBarModel.getTabBarByPage(PageKeyEnum.ADAPTIVE_TAB) ?? [];

  onPageShow(): void {
    this.refreshCurrentTab();
  }

  @Builder
  miniBarBuilder() {
    Row() {
      if (this.isMiniBar) {
        Column() {
          Text('+')
            .fontSize(30)
            .fontColor('#007AFF')
            .fontWeight(FontWeight.Medium)
        }
        .width(56)
        .aspectRatio(1)
        .borderRadius('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Row({ space: 10 }) {
          this.buildMiniAddAction('item', () => {
            router.pushUrl({ url: 'pages/AddItemPage' });
          })
          this.buildMiniAddAction('space', () => {
            this.controller.changeIndex(1);
            this.currentTabIndex = 1;
            this.refreshCurrentTab();
            AppStorage.setOrCreate('quickAddSpace', Date.now());
          })
          this.buildMiniAddAction('event', () => {
            router.pushUrl({ url: 'pages/CreateEventPage' });
          })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    Stack() {
      PageBackground()

      // .margin({ top: this.statusBarHeight + 4 })
      // .margin({ left: 16, right: 16, bottom: 12 + this.naviIndicatorHeight })
      HdsNavDestination() {
        HdsTabs({ controller: this.controller }) {
          ForEach(this.tabsBar, (tabBar: BottomTabBarStyle, index: number) => {
            TabContent() {
              if (index === 0) {
                ItemPage()
              } else if (index === 1) {
                SpacePage()
              } else if (index === 2) {
                EventPage()
              } else {
                ProfilePage()
              }
            }
            .tabBar(tabBar)
          }, (tabBar: BottomTabBarStyle, index: number) => index.toString())
        }
        .barOverlap(true)
        .vertical(false)
        .barPosition(BarPosition.End)
        .onChange((index: number) => {
          this.currentTabIndex = index;
          this.refreshCurrentTab();
        })
        .barFloatingStyle({
          // barBottomMargin: 16 + this.naviIndicatorHeight,
          barBottomMargin: 16,
          systemMaterialEffect: {
            materialType: hdsMaterial.MaterialType.IMMERSIVE,
            materialLevel: hdsMaterial.MaterialLevel.GENTLE
          },
          miniBar: {
            miniBarBuilder: () => this.miniBarBuilder(),
            onBarStyleChange: (miniBarStyle: HdsBarStyle) => {
              this.isMiniBar = miniBarStyle === HdsBarStyle.COLLAPSE;
            }
          }
        })
      }
      .hideBackButton(true)
      .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildMiniAddAction(label: string, onClick: () => void) {
    Button(label)
    .type(ButtonType.Normal)
    .fontSize(13)
    .fontColor('#007AFF')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .height(32)
    .padding({ left: 14, right: 14 })
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
