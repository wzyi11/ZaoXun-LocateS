import { SymbolGlyphModifier } from "@kit.ArkUI";


export class TabsBarModel {
  private static pageTabBarStyleMap: Map<PageKeyEnum, BottomTabBarStyle[]> = new Map();

  public static getTabBarByPage(pageKey: PageKeyEnum): BottomTabBarStyle[] {
    const tabBarStyleList: BottomTabBarStyle[] = []
    if (!TabsBarModel.pageTabBarStyleMap.has(pageKey)) {
      const tabBarList = PAGE_BAR_MAP.get(pageKey);
      if (tabBarList) {
        tabBarList.forEach((item: BarItem) => {
          const tabBarStyle = new BottomTabBarStyle({
            normal: new SymbolGlyphModifier(item.normalSymbolResource)
              .renderingStrategy(SymbolRenderingStrategy.SINGLE)
              .fontColor([item.normalColor]),
            selected: new SymbolGlyphModifier(item.selectedSymbolResource)
              .renderingStrategy(SymbolRenderingStrategy.SINGLE)
              .fontColor([item.selectedColor])
          }, item.label)
            .labelStyle({
              unselectedColor: item.normalColor,
              selectedColor: item.selectedColor,
            });
          tabBarStyleList.push(tabBarStyle);
        })
      }
      TabsBarModel.pageTabBarStyleMap.set(pageKey, tabBarStyleList);
    }
    return TabsBarModel.pageTabBarStyleMap.get(pageKey) ?? [];
  }
}


export enum PageKeyEnum {
  ADAPTIVE_TAB = 'AdaptiveTabView',
  IMMERSIVE_LIGHT = 'ImmersiveLightView',
  SMART_REACH = 'SmartReachView',
}

const PAGE_BAR_MAP: Map<PageKeyEnum, BarItem[]> = new Map([
  [PageKeyEnum.IMMERSIVE_LIGHT, [
    {
      label: '0',
      normalColor: $r('sys.color.icon_primary'),
      normalSymbolResource: $r('sys.symbol.house_fill'),
      selectedColor: $r('sys.color.icon_emphasize'),
      selectedSymbolResource: $r('sys.symbol.house_fill'),
    } as BarItem,
    {
      label: '1',
      normalColor: $r('sys.color.icon_primary'),
      normalSymbolResource: $r('sys.symbol.bag_fill'),
      selectedColor: $r('sys.color.icon_emphasize'),
      selectedSymbolResource: $r('sys.symbol.bag_fill'),
    },
    {
      label: '2',
      normalColor: $r('sys.color.icon_primary'),
      normalSymbolResource: $r('sys.symbol.meta_service'),
      selectedColor: $r('sys.color.icon_emphasize'),
      selectedSymbolResource: $r('sys.symbol.meta_service'),
    },
    {
      label: '3',
      normalColor: $r('sys.color.icon_primary'),
      normalSymbolResource: $r('sys.symbol.game_fill'),
      selectedColor: $r('sys.color.icon_emphasize'),
      selectedSymbolResource: $r('sys.symbol.game_fill'),
    },
    {
      label: '4',
      normalColor: $r('sys.color.icon_primary'),
      normalSymbolResource: $r('sys.symbol.person_crop_circle_fill'),
      selectedColor: $r('sys.color.icon_emphasize'),
      selectedSymbolResource: $r('sys.symbol.person_crop_circle_fill'),
    },
  ]],
  [PageKeyEnum.ADAPTIVE_TAB, [
    // {
    //   label: '首页',
    //   normalColor: $r('sys.color.icon_primary'),
    //   normalSymbolResource: $r('sys.symbol.house_fill'),
    //   selectedColor: '#FF1949',
    //   selectedSymbolResource: $r('sys.symbol.house_fill'),
    // },
    {
      label: '物品',
      normalColor: $r('sys.color.icon_primary'),
      normalSymbolResource: $r('sys.symbol.box_ellipsis_message_fill'),
      selectedColor: '#FF1949',
      selectedSymbolResource: $r('sys.symbol.box_ellipsis_message_filled'),
    },
    {
      label: '空间',
      normalColor: $r('sys.color.icon_primary'),
      normalSymbolResource: $r('sys.symbol.space_audio'),
      selectedColor: '#FF1949',
      selectedSymbolResource: $r('sys.symbol.space_enlarge'),
    },
    {
      label: '事件',
      normalColor: $r('sys.color.icon_primary'),
      normalSymbolResource: $r('sys.symbol.bag'),
      selectedColor: '#FF1949',
      selectedSymbolResource: $r('sys.symbol.bag_fill'),
    },
    {
      label: '我的',
      normalColor: $r('sys.color.icon_primary'),
      normalSymbolResource: $r('sys.symbol.person'),
      selectedColor: '#FF1949',
      selectedSymbolResource: $r('sys.symbol.person_2'),
    },
  ]],
  [PageKeyEnum.SMART_REACH, [
    {
      label: '0',
      normalColor: $r('sys.color.icon_primary'),
      normalSymbolResource: $r('sys.symbol.house_fill'),
      selectedColor: $r('sys.color.icon_emphasize'),
      selectedSymbolResource: $r('sys.symbol.house_fill'),
    },
    {
      label: '1',
      normalColor: $r('sys.color.icon_primary'),
      normalSymbolResource: $r('sys.symbol.play_hexagon_fill'),
      selectedColor: $r('sys.color.icon_emphasize'),
      selectedSymbolResource: $r('sys.symbol.play_hexagon_fill'),
    },
    {
      label: '2',
      normalColor: $r('sys.color.icon_primary'),
      normalSymbolResource: $r('sys.symbol.bag_fill_1'),
      selectedColor: $r('sys.color.icon_emphasize'),
      selectedSymbolResource: $r('sys.symbol.bag_fill_1'),
    },
    {
      label: '3',
      normalColor: $r('sys.color.icon_primary'),
      normalSymbolResource: $r('sys.symbol.person_crop_circle_fill'),
      selectedColor: $r('sys.color.icon_emphasize'),
      selectedSymbolResource: $r('sys.symbol.person_crop_circle_fill'),
    },
  ]],
]);

export const PAGE_SCROLLER_MAP: Map<PageKeyEnum, Scroller[]> = new Map([
  [PageKeyEnum.IMMERSIVE_LIGHT, new Array(5).fill(null).map(() => new Scroller())],
  [PageKeyEnum.ADAPTIVE_TAB, new Array(4).fill(null).map(() => new Scroller())],
  [PageKeyEnum.SMART_REACH, new Array(4).fill(null).map(() => new Scroller())],
]);

interface BarItem {
  normalSymbolResource: Resource,
  selectedSymbolResource: Resource,
  label: ResourceStr,
  normalColor: ResourceColor;
  selectedColor: ResourceColor;
}