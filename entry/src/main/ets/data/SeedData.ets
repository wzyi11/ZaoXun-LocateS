import { ItemInput } from '../model/ItemModel';
import { ItemRepository } from '../data/ItemRepository';
import { SpaceRepository } from '../data/SpaceRepository';
import { Space } from '../model/SpaceModel';

const TAG = '[SeedData]';

interface SeedItem {
  name: string;
  category: string;
  spaceId: number;
}

const SECTION_COLORS: string[] = ['#5B8DEF', '#7ED957', '#F59A2A', '#B06CFF', '#F45B69'];

function now(): string {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')} ${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}:${String(d.getSeconds()).padStart(2, '0')}`;
}

async function insertSeedSpace(
  repo: SpaceRepository,
  name: string,
  parentId: number,
  level: number,
  icon: string,
  markerIndex: number = 0,
): Promise<Space> {
  const markerX: number = 0.22 + (markerIndex % 3) * 0.28;
  const markerY: number = 0.26 + Math.floor(markerIndex / 3) * 0.24;
  const markerColor: string = SECTION_COLORS[markerIndex % SECTION_COLORS.length];
  const id = await repo.insert({
    name: name,
    parentId: parentId,
    level: level,
    icon: icon,
    image: '',
    markerX: markerX,
    markerY: markerY,
    markerColor: markerColor,
  });
  return { id, name, parentId, level, icon, image: '', markerX, markerY, markerColor };
}

// 预设示例物品
const PRESET_ITEMS: SeedItem[] = [
  { name: '白色短袖T恤', category: '衣物', spaceId: 0 },
  { name: '蓝色牛仔裤', category: '衣物', spaceId: 0 },
  { name: '黑色运动鞋', category: '衣物', spaceId: 0 },
  { name: '灰色卫衣', category: '衣物', spaceId: 0 },
  { name: '夏季连衣裙', category: '衣物', spaceId: 0 },
  { name: '羽绒服', category: '衣物', spaceId: 0 },
  { name: '棒球帽', category: '衣物', spaceId: 0 },
  { name: '围巾', category: '衣物', spaceId: 0 },
  { name: '真皮腰带', category: '衣物', spaceId: 0 },
  { name: '羊毛袜', category: '衣物', spaceId: 0 },

  // 书籍
  { name: '深入理解计算机系统', category: '书籍', spaceId: 0 },
  { name: '设计模式之禅', category: '书籍', spaceId: 0 },
  { name: '算法导论', category: '书籍', spaceId: 0 },
  { name: '人类群星闪耀时', category: '书籍', spaceId: 0 },
  { name: '三体全集', category: '书籍', spaceId: 0 },
  { name: '百年孤独', category: '书籍', spaceId: 0 },
  { name: '数据结构与算法分析', category: '书籍', spaceId: 0 },
  { name: 'Python编程从入门到实践', category: '书籍', spaceId: 0 },

  // 数码
  { name: 'MacBook Pro 14英寸', category: '数码', spaceId: 0 },
  { name: 'iPhone 15 Pro', category: '数码', spaceId: 0 },
  { name: 'AirPods Pro', category: '数码', spaceId: 0 },
  { name: '机械键盘', category: '数码', spaceId: 0 },
  { name: '4K显示器', category: '数码', spaceId: 0 },
  { name: '移动硬盘 2TB', category: '数码', spaceId: 0 },
  { name: 'USB-C扩展坞', category: '数码', spaceId: 0 },
  { name: '无线鼠标', category: '数码', spaceId: 0 },
  { name: 'Kindle电子书', category: '数码', spaceId: 0 },
  { name: '智能手表', category: '数码', spaceId: 0 },

  // 厨房
  { name: '不粘锅套装', category: '厨房', spaceId: 0 },
  { name: '陶瓷刀', category: '厨房', spaceId: 0 },
  { name: '砧板', category: '厨房', spaceId: 0 },
  { name: '保温杯', category: '厨房', spaceId: 0 },
  { name: '玻璃饭盒', category: '厨房', spaceId: 0 },
  { name: '电子秤', category: '厨房', spaceId: 0 },

  // 文件
  { name: '身份证复印件', category: '文件', spaceId: 0 },
  { name: '护照', category: '文件', spaceId: 0 },
  { name: '学位证书', category: '文件', spaceId: 0 },
  { name: '租房合同', category: '文件', spaceId: 0 },
  { name: '体检报告', category: '文件', spaceId: 0 },
  { name: '银行流水', category: '文件', spaceId: 0 },

  // 其他
  { name: '瑜伽垫', category: '其他', spaceId: 0 },
  { name: '羽毛球拍', category: '其他', spaceId: 0 },
  { name: '旅行收纳包', category: '其他', spaceId: 0 },
  { name: '雨伞', category: '其他', spaceId: 0 },
  { name: '充电宝', category: '其他', spaceId: 0 },
  { name: '钥匙扣', category: '其他', spaceId: 0 },
];

export async function seedDataIfEmpty(): Promise<void> {
  try {
    const itemRepo = new ItemRepository();
    const spaceRepo = new SpaceRepository();
    const existingItems = await itemRepo.getAll();

    if (existingItems.length > 0) {
      console.info(TAG, `已有 ${existingItems.length} 条数据，跳过种子数据`);
      return;
    }

    console.info(TAG, '开始插入种子数据...');
    const time = now();

    // 先创建预设空间：空间 -> 分区
    const roomRows: Space[] = [];
    const roomNames = ['卧室', '客厅', '书房', '厨房'];
    for (const name of roomNames) {
      roomRows.push(await insertSeedSpace(spaceRepo, name, 0, 1, '🏠'));
    }

    const shirtDrawer = (await insertSeedSpace(spaceRepo, '上衣抽屉', roomRows[0].id, 2, '📍', 0)).id;
    const pantsDrawer = (await insertSeedSpace(spaceRepo, '裤子抽屉', roomRows[0].id, 2, '📍', 1)).id;
    const accessoryDrawer = (await insertSeedSpace(spaceRepo, '配饰格', roomRows[0].id, 2, '📍', 2)).id;
    await insertSeedSpace(spaceRepo, '床头柜', roomRows[0].id, 2, '📍', 3);

    const techShelf = (await insertSeedSpace(spaceRepo, '技术类', roomRows[2].id, 2, '📍', 0)).id;
    const litShelf = (await insertSeedSpace(spaceRepo, '文学类', roomRows[2].id, 2, '📍', 1)).id;
    const gadgetDrawer = (await insertSeedSpace(spaceRepo, '数码抽屉', roomRows[2].id, 2, '📍', 2)).id;
    await insertSeedSpace(spaceRepo, '书桌', roomRows[2].id, 2, '📍', 3);

    // 分配物品到空间
    const spaceMap: Record<string, number> = {
      '衣物-上衣抽屉': shirtDrawer, '衣物-裤子抽屉': pantsDrawer, '衣物-配饰格': accessoryDrawer,
      '书籍-技术类': techShelf, '书籍-文学类': litShelf,
      '数码-数码抽屉': gadgetDrawer,
    };

    let inserted = 0;
    for (const item of PRESET_ITEMS) {
      const key = `${item.category}-上衣抽屉`;
      const key2 = `${item.category}-技术类`;
      const key3 = `${item.category}-数码抽屉`;
      const key4 = `${item.category}-裤子抽屉`;
      const key5 = `${item.category}-配饰格`;
      const assignedSpaceId = spaceMap[key] || spaceMap[key2] || spaceMap[key3] || spaceMap[key4] || spaceMap[key5] || 0;

      const input: ItemInput = {
        name: item.name,
        category: item.category,
        spaceId: assignedSpaceId,
        image: '',
        purchaseDate: '',
        note: '',
        createTime: time,
      };
      await itemRepo.insert(input);
      inserted++;
    }

    console.info(TAG, `种子数据插入完成: ${inserted} 个物品, ${roomRows.length + 8} 个空间`);
  } catch (err) {
    console.error(TAG, `种子数据插入失败: ${JSON.stringify(err)}`);
  }
}
