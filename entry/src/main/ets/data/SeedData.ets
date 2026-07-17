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

// 预设分类
const CATEGORIES: string[] = ['衣物', '书籍', '数码', '厨房', '文件', '其他'];

function now(): string {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')} ${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}:${String(d.getSeconds()).padStart(2, '0')}`;
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

    // 先创建预设空间：房间 → 柜子 → 格子
    const roomRows: Space[] = [];
    const roomNames = ['卧室', '客厅', '书房', '厨房'];
    for (const name of roomNames) {
      const id = await spaceRepo.insert({ name, parentId: 0, level: 1, icon: '🏠' });
      roomRows.push({ id, name, parentId: 0, level: 1, icon: '🏠' });
    }

    // 给卧室添加柜子
    const wardrobeId = await spaceRepo.insert({ name: '衣柜', parentId: roomRows[0].id, level: 2, icon: '🗄️' });
    const bedSideId = await spaceRepo.insert({ name: '床头柜', parentId: roomRows[0].id, level: 2, icon: '🗄️' });
    // 给书房添加柜子
    const bookcaseId = await spaceRepo.insert({ name: '书柜', parentId: roomRows[2].id, level: 2, icon: '🗄️' });
    const deskId = await spaceRepo.insert({ name: '书桌', parentId: roomRows[2].id, level: 2, icon: '🗄️' });

    // 给衣柜添加格子
    const shirtDrawer = await spaceRepo.insert({ name: '上衣抽屉', parentId: wardrobeId, level: 3, icon: '📦' });
    const pantsDrawer = await spaceRepo.insert({ name: '裤子抽屉', parentId: wardrobeId, level: 3, icon: '📦' });
    const accessoryDrawer = await spaceRepo.insert({ name: '配饰格', parentId: wardrobeId, level: 3, icon: '📦' });

    // 给书柜添加格子
    const techShelf = await spaceRepo.insert({ name: '技术类', parentId: bookcaseId, level: 3, icon: '📦' });
    const litShelf = await spaceRepo.insert({ name: '文学类', parentId: bookcaseId, level: 3, icon: '📦' });
    const gadgetDrawer = await spaceRepo.insert({ name: '数码抽屉', parentId: deskId, level: 3, icon: '📦' });

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
