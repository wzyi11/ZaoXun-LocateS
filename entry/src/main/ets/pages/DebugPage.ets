import {
  HdsBarStyle,
  hdsMaterial,
  HdsNavDestination,
  HdsTabs,
  HdsTabsController,
  ScrollEffectType,
} from '@kit.UIDesignKit';
import { PageKeyEnum, TabsBarModel } from '../model/ToolsBarModel';
import { ItemPage } from '../tabs/ItemPage';
import { SpacePage } from '../tabs/SpacePage';
import { EventPage } from '../tabs/EventPage';
import { ProfilePage } from '../tabs/ProfilePage';

@Entry
@ComponentV2
struct DebugPage {
  @Local isMiniBar: boolean = true;
  private controller: HdsTabsController = new HdsTabsController();
  private tabsBar: BottomTabBarStyle[] = TabsBarModel.getTabBarByPage(PageKeyEnum.ADAPTIVE_TAB) ?? [];

  @Builder
  miniBarBuilder() {
    Row() {
      Column() {
        Text('A')
          .width('100%')
          .height('100%')
          .borderRadius('100%')
      }
      .padding(this.isMiniBar ? 1 : $r('sys.float.padding_level3'))
      .width(56)
      .aspectRatio(1)
      .justifyContent(FlexAlign.Center)

      Column({ space: 22 }) {
        Text('Espresso')
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_S'))
        Text('Sabrina Carpenter')
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Caption_M'))
      }
      .padding({ left: $r('sys.float.padding_level1') })
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
  }

  build() {
    HdsNavDestination() {
      HdsTabs({ controller: this.controller }) {
        Repeat(this.tabsBar)
          .each((repeatItem: RepeatItem<BottomTabBarStyle>) => {
            TabContent() {
              if (repeatItem.index === 0) {
                ItemPage()
              } else if (repeatItem.index === 1) {
                SpacePage()
              } else if (repeatItem.index === 2) {
                EventPage()
              } else {
                ProfilePage()
              }
            }
            .tabBar(repeatItem.item)
          })
      }
      .barOverlap(true)
      .vertical(false)
      .barPosition(BarPosition.End)
      .barFloatingStyle({
        barBottomMargin: $r('sys.float.padding_level8'),
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.IMMERSIVE,
          materialLevel: hdsMaterial.MaterialLevel.GENTLE
        },
        miniBar: {
          miniBarBuilder: () => this.miniBarBuilder(),
          onBarStyleChange: (miniBarStyle: HdsBarStyle) => {
            this.isMiniBar = miniBarStyle === HdsBarStyle.COLLAPSE
          }
        }
      })
    }
    .hideBackButton(true)
    // .dynamicHideTitleBar({
    //   hideTitleArea:true
    // })
    // .titleBar({
    //   content: {
    //     title: {
    //       mainTitle: 'Debug',
    //     },
    //   },
    //   style: {
    //     scrollEffectOpts: {
    //       enableScrollEffect: true,
    //       scrollEffectType: ScrollEffectType.GRADIENT_BLUR,
    //     },
    //     systemMaterialEffect: {
    //       materialType: hdsMaterial.MaterialType.ADAPTIVE,
    //       materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE,
    //     },
    //   },
    //   avoidLayoutSafeArea: true,
    //   enableComponentSafeArea: false
    // })
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
  }
}
