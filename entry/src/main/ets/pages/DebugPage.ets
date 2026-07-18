import { AppStorageV2 } from '@kit.ArkUI';
import {
  HdsBarStyle,
  hdsMaterial,
  HdsNavDestination,
  HdsTabs,
  HdsTabsController,
  ScrollEffectType,
} from '@kit.UIDesignKit';
import  {PageKeyEnum, PAGE_SCROLLER_MAP, TabsBarModel} from '../model/ToolsBarModel';


@Entry
@ComponentV2
struct DebugPage {

  @Local isMiniBar: boolean = true;
  private controller: HdsTabsController = new HdsTabsController();
  private tabsBar: BottomTabBarStyle[] = TabsBarModel.getTabBarByPage(PageKeyEnum.ADAPTIVE_TAB) ?? [];


  @Builder
  miniBarBuilder(){
    Row(){
      Column(){
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
    HdsNavDestination(){
      HdsTabs({controller : this.controller}){


        // Repeat(this.tabsBar)
        //   .each((repeatItem: RepeatItem<BottomTabBarStyle>) => {
        //     TabContent() {
        //       WaterFlowView({ currentTabIndex: repeatItem.index, pageKey: PageKeyEnum.ADAPTIVE_TAB })
        //     }
        //     .tabBar(repeatItem.item)
        //   })
        // TabContent(){
        //   Text('lvelvelve')
        //     .fontSize(30)
        //     .height('100%')
        //     .width('100%')
        // }
        // .tabBar()

        Repeat(this.tabsBar)
          .each((repeatItem: RepeatItem<BottomTabBarStyle>) => {
            TabContent() {
              Text('111')
            }
            .tabBar(repeatItem.item)
          })
      }
      .barOverlap(true)
      .vertical(false)
      .barPosition(BarPosition.End)
      .barFloatingStyle({
        // barBottomMargin: this.globalInfoModel.naviIndicatorHeight > 0 ? this.globalInfoModel.naviIndicatorHeight :
        //   $r('sys.float.padding_level8'),
        barBottomMargin:20,
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.IMMERSIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
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
    .titleBar({

      content: {
        title: {
          // mainTitle: this.currentSample?.title ?? '',
          mainTitle: '111',
        },
      },
      style: {
        scrollEffectOpts: {
          enableScrollEffect: true,
          scrollEffectType: ScrollEffectType.GRADIENT_BLUR,
        },
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.ADAPTIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE,
        },
      },
      avoidLayoutSafeArea: true,
      enableComponentSafeArea: false
    })
    // .bindToScrollable(PAGE_SCROLLER_MAP.get(PageKeyEnum.ADAPTIVE_TAB) ?? [])
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
    // Column() {
    // }
    // .width('100%')
    // .height('100%')
  }
}
