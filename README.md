# CIM API Skills Reference

本仓库是 51WORLD 的 CIM API（@wdp-api/cim-api）技能文档集合，面向 Agent 路由和能力编排使用。

当前版本通过 `manifest.json` 维护技能索引，技能正文集中在 `SKILL/` 目录。

## 项目概览

- 技能总数：22
- 一级分类：4（Initialization / InternetMap / Spatial / Hospital）
- 入口技能：`SKILL/initialization-skill.md`

## 能力覆盖

### 1) Initialization

- SDK 安装与插件初始化
- 版本查询
- 通用实体获取与删除

对应文档：

- `SKILL/initialization-skill.md`

### 2) InternetMap

- 地图 key 配置
- POI 搜索（文本/多边形/圆形/屏幕）
- POI 获取与重置
- 导航路径创建、查询与选择

对应文档：

- `SKILL/keycommon-skill.md`
- `SKILL/lifecircle-skill.md`
- `SKILL/searchbytext-skill.md`
- `SKILL/searchbypolygon-skill.md`
- `SKILL/searchbycircle-skill.md`
- `SKILL/searchbyscreen-skill.md`
- `SKILL/poiget-skill.md`
- `SKILL/poireset-skill.md`
- `SKILL/searchpath-skill.md`
- `SKILL/getpath-skill.md`
- `SKILL/selectpath-skill.md`

### 3) Spatial

- 开敞度
- 等高线
- 日照
- 天际线
- 填挖方
- 通视
- 限高

对应文档：

- `SKILL/openness-skill.md`
- `SKILL/contour-skill.md`
- `SKILL/sunlight-skill.md`
- `SKILL/skyline-skill.md`
- `SKILL/digterrain-skill.md`
- `SKILL/intervisible-skill.md`
- `SKILL/heightlimit-skill.md`

### 4) Hospital

- 电梯管理
- 房间色块
- 附属设备

对应文档：

- `SKILL/elevator-skill.md`
- `SKILL/box-skill.md`
- `SKILL/device-skill.md`

## 与 manifest 的关系

`manifest.json` 是运行时索引，维护以下信息：

- 分类与技能分组（`categories`）
- 技能文件路径（`path`）
- API 关键标识（`api`）
- 全量技能索引（`skillIndex`）
- 统计信息（`stats`）

当 `SKILL/` 目录新增、删除或重命名文件时，需同步更新 `manifest.json`。

## 维护建议

1. 新增技能时，优先复用现有命名风格：`<feature>-skill.md`
2. `manifest.json` 的 `skillIndex` 应与实际文件保持一一对应
3. 修改 API 标识时，以技能文档中的示例调用为准
4. 修改后建议做一次 JSON 解析校验，确保 manifest 可被正常读取

