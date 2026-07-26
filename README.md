# 枣寻 LocateS

枣寻 LocateS 是一款面向 HarmonyOS 的个人物品管理与智能收纳应用。它围绕“物品记录、空间定位、事件提醒、AI 辅助”四个核心场景，帮助用户建立个人物品档案，减少遗忘位置、重复购买和临时寻找。

## 项目亮点

- 物品管理：记录物品名称、分类、存放空间、图片、购买日期和备注。
- 空间管理：按房间、柜子、格子建立三级空间结构，支持空间下物品查看。
- 事件清单：创建旅行、考试、搬家等事件，并关联需要准备的物品。
- 准备进度：在事件详情中勾选物品准备状态，查看清单完成进度。
- 系统分享：将事件清单以文本形式分享给他人。
- 服务卡片：提供 HarmonyOS FormExtensionAbility 服务卡片入口。
- 沉浸式界面：使用 ArkUI 与 UIDesignKit 构建顶部标签、底部悬浮导航和轻量化操作入口。

## 技术栈

- HarmonyOS 6.1 / API 24
- ArkTS
- ArkUI
- UIDesignKit
- RelationalStore 本地数据库
- ShareKit 系统分享
- Hypium / Hamock 测试依赖

## 应用结构

```text
.
├── AppScope/                         # 应用级配置与图标资源
├── entry/                            # HarmonyOS entry 模块
│   ├── src/main/ets/pages/           # 页面：主页、物品、空间、事件、我的等
│   ├── src/main/ets/tabs/            # 首页 Tab 页面
│   ├── src/main/ets/components/      # 通用 UI 组件
│   ├── src/main/ets/data/            # 数据库与 Repository
│   ├── src/main/ets/model/           # 数据模型
│   └── src/main/ets/form/            # 服务卡片能力
├── docs/                             # 项目文档、调研、图表、海报与交付物
├── hvigor/                           # Hvigor 构建配置
├── build-profile.json5
├── hvigorfile.ts
└── oh-package.json5
```

## 核心页面

- `pages/Index`：应用入口，包含物品、空间、事件和我的页面导航。
- `tabs/ItemPage`：物品列表、搜索、分类筛选、快速添加入口。
- `tabs/SpacePage`：空间列表、空间层级管理、空间详情与物品查看。
- `tabs/EventPage`：事件列表、日历视图、事件创建入口。
- `pages/ItemDetailPage`：物品详情与删除。
- `pages/EventDetailPage`：事件详情、物品准备清单、进度和分享。
- `pages/ProfilePage`：个人主页、统计信息和设置入口。

## 数据模型

应用使用 `RelationalStore` 持久化本地数据，主要表包括：

- `item`：物品信息。
- `space`：空间层级。
- `event`：事件计划。
- `event_item`：事件与物品的关联及准备状态。
- `category`：物品分类。

详细结构见 [docs/competition/architecture.md](docs/competition/architecture.md)。

## 运行方式

1. 使用 DevEco Studio 打开仓库根目录。
2. 等待 Hvigor 同步依赖和工程配置。
3. 选择 `entry` 模块。
4. 连接 HarmonyOS 设备或启动模拟器。
5. 点击 Run 构建并安装应用。

命令行构建可参考项目 Hvigor 配置。当前测试报告记录在 [docs/competition/test-report.md](docs/competition/test-report.md)。

## 文档

- 架构说明：[docs/competition/architecture.md](docs/competition/architecture.md)
- 测试报告：[docs/competition/test-report.md](docs/competition/test-report.md)

## 当前状态

该仓库包含 HarmonyOS 应用源码、架构说明和测试报告。已完成基础编译验证；真机交互、服务卡片预览和日历权限相关流程需要在设备或模拟器上继续验证。
