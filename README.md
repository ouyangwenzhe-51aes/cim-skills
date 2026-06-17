# CIM API Skills Reference

本仓库是 51WORLD 的 CIM API（@wdp-api/cim-api）技能文档集合，面向 Agent 路由和能力编排使用。

本插件遵循 APM 插件规范，技能正文按「每个技能一个目录 + `SKILL.md`」组织在 `skills/` 目录下，可在 Copilot / Claude / Cursor 等兼容的 Agent 环境中安装使用。

## 项目概览

- 技能总数：22
- 一级分类：4（Initialization / InternetMap / Spatial / Hospital）
- 入口技能：`skills/initialization/SKILL.md`

## 目录结构

```
cim-skills/
├── plugin.json              # 插件描述符，声明 "skills": "./skills/"
├── .claude-plugin/          # Claude / Copilot 插件配置
│   ├── plugin.json
│   └── marketplace.json
├── .cursor-plugin/          # Cursor 插件配置
│   ├── plugin.json
│   └── marketplace.json
└── skills/                  # 每个技能一个目录，正文为 SKILL.md
    ├── initialization/SKILL.md
    ├── keycommon/SKILL.md
    └── ...
```

## 能力覆盖

### 1) Initialization

- SDK 安装与插件初始化
- 版本查询
- 通用实体获取与删除

对应文档：

- `skills/initialization/SKILL.md`

### 2) InternetMap

- 地图 key 配置
- POI 搜索（文本/多边形/圆形/屏幕）
- POI 获取与重置
- 导航路径创建、查询与选择

对应文档：

- `skills/keycommon/SKILL.md`
- `skills/lifecircle/SKILL.md`
- `skills/bytext/SKILL.md`
- `skills/bypolygon/SKILL.md`
- `skills/bycircle/SKILL.md`
- `skills/byscreen/SKILL.md`
- `skills/poi-get/SKILL.md`
- `skills/poi-reset/SKILL.md`
- `skills/search-path/SKILL.md`
- `skills/get-path/SKILL.md`
- `skills/select-path/SKILL.md`

### 3) Spatial

- 开敞度
- 等高线
- 日照
- 天际线
- 填挖方
- 通视
- 限高

对应文档：

- `skills/openness/SKILL.md`
- `skills/contour/SKILL.md`
- `skills/sunlight/SKILL.md`
- `skills/skyline/SKILL.md`
- `skills/dig-terrain/SKILL.md`
- `skills/intervisible/SKILL.md`
- `skills/height-limit/SKILL.md`

### 4) Hospital

- 电梯管理
- 房间色块
- 附属设备

对应文档：

- `skills/elevator/SKILL.md`
- `skills/box/SKILL.md`
- `skills/device/SKILL.md`

## 插件加载机制

加载器从 `plugin.json` 的 `"skills": "./skills/"` 入口，扫描 `skills/` 下的**子目录**，读取每个子目录中的 `SKILL.md` 作为一个技能。

- 子目录名 = `SKILL.md` frontmatter 中的 `name` 字段
- 技能正文文件名必须为 `SKILL.md`
- 扁平的 `*.md` 文件不会被识别为技能

`SKILL.md` 的 frontmatter 标准格式：

```yaml
---
name: <skill-name>
description: >
  能力说明与触发场景。
metadata:
  version: 1.0.0
  tags: [cimapi, ...]
---
```

## 维护建议

1. 新增技能时，在 `skills/` 下新建目录，目录名与 frontmatter 的 `name` 一致，正文写入 `SKILL.md`
2. frontmatter 缩进统一使用 2 个空格，避免 TAB 与空格混用
3. 修改 API 标识时，以技能文档中的示例调用为准
4. 修改后建议对 `plugin.json`、`.claude-plugin/`、`.cursor-plugin/` 下的 JSON 做一次解析校验

