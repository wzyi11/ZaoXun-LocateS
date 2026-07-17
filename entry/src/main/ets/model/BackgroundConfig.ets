export interface GradientPreset {
  id: string;
  name: string;
  colors: Array<[string, number]>;
  direction: GradientDirection;
}

export const BACKGROUND_TYPE_NONE: string = 'none';
export const BACKGROUND_TYPE_GRADIENT: string = 'gradient';
export const BACKGROUND_TYPE_IMAGE_PRESET: string = 'image_preset';
export const BACKGROUND_TYPE_CUSTOM: string = 'custom';

export const GRADIENT_PRESETS: Array<GradientPreset> = [
  {
    id: 'sunrise',
    name: '晨曦暖橙',
    colors: [['#FF9A9E', 0.0], ['#FAD0C4', 1.0]],
    direction: GradientDirection.LeftTop
  },
  {
    id: 'ocean',
    name: '深海蓝紫',
    colors: [['#4FACFE', 0.0], ['#00F2FE', 1.0]],
    direction: GradientDirection.Top
  },
  {
    id: 'forest',
    name: '森林绿',
    colors: [['#11998E', 0.0], ['#38EF7D', 1.0]],
    direction: GradientDirection.LeftTop
  },
  {
    id: 'sakura',
    name: '樱花粉',
    colors: [['#F093FB', 0.0], ['#F5576C', 1.0]],
    direction: GradientDirection.Top
  },
  {
    id: 'twilight',
    name: '暮光紫',
    colors: [['#A18CD1', 0.0], ['#FBC2EB', 1.0]],
    direction: GradientDirection.LeftTop
  },
  {
    id: 'aurora',
    name: '极光绿',
    colors: [['#0BA360', 0.0], ['#3CBA92', 1.0]],
    direction: GradientDirection.Top
  }
];

export const IMAGE_PRESETS: Array<string> = [
  'bg_preset_1',
  'bg_preset_2',
  'bg_preset_3',
  'bg_preset_4'
];

export const IMAGE_PRESET_NAMES: Array<string> = [
  '山峰自然',
  '海洋水纹',
  '抽象几何',
  '简约纹理'
];

export function getGradientById(id: string): GradientPreset | undefined {
  for (let i = 0; i < GRADIENT_PRESETS.length; i++) {
    if (GRADIENT_PRESETS[i].id === id) {
      return GRADIENT_PRESETS[i];
    }
  }
  return undefined;
}
