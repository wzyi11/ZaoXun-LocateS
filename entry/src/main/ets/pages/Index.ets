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
  @StorageLink('quickSwitchTab') @Watch('onQuickSwitchTab') quickSwitchTab: number = -1;
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
        Row() {
          this.buildMiniAddAction('📦', () => {
            this.controller.changeIndex(0);
            this.currentTabIndex = 0;
            this.refreshCurrentTab();
            AppStorage.setOrCreate('quickAddItemSpaceId', 0);
            AppStorage.setOrCreate('quickAddItem', Date.now());
          })
          this.buildMiniAddAction('🏠', () => {
            this.controller.changeIndex(1);
            this.currentTabIndex = 1;
            this.refreshCurrentTab();
            AppStorage.setOrCreate('quickAddSpace', Date.now());
          })
          this.buildMiniAddAction('🗓', () => {
            this.controller.changeIndex(2);
            this.currentTabIndex = 2;
            this.refreshCurrentTab();
            AppStorage.setOrCreate('quickAddEvent', Date.now());
          })
        }
        .width(196)
        .height('100%')
        .justifyContent(FlexAlign.SpaceBetween)
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
  buildMiniAddAction(icon: string, onClick: () => void) {
    Button() {
      Text(icon)
        .fontSize(22)
        .textAlign(TextAlign.Center)
    }
    .type(ButtonType.Normal)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .width(40)
    .height(40)
    .onClick(onClick)
  }

  onQuickSwitchTab(): void {
    const targetIndex: number = this.quickSwitchTab > 3
      ? this.quickSwitchTab - Math.floor(this.quickSwitchTab / 10) * 10
      : this.quickSwitchTab;
    if (targetIndex < 0 || targetIndex > 3) {
      return;
    }
    this.controller.changeIndex(targetIndex);
    this.currentTabIndex = targetIndex;
    this.refreshCurrentTab();
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
