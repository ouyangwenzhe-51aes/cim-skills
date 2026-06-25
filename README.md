# CIM API Skills Reference

本仓库是 51WORLD 的 CIM API（@wdp-api/cim-api）技能文档集合，面向 Agent 路由和能力编排使用。

本插件遵循 APM 插件规范，技能正文按「每个技能一个目录 + `SKILL.md`」组织在 `skills/` 目录下，可在 Copilot / Claude / Cursor 等兼容的 Agent 环境中安装使用。

## 项目概览

- 技能总数：22
- 一级分类：4（ Initialization / InternetMap / Spatial / Hospital）
- 入口技能：`skills/initialization/SKILL.md`

## 目录结构

```
cim-skills/
├── plugin.json              # 插件描述符，声明 "skills": "./skills/"
├── apm.yml                  # APM marketplace authoring source
├── CHANGELOG.md             # 版本变更记录
├── .plugin/                 # 插件配置
├── dev-scripts/             # 发版辅助脚本
│   └── release.ps1
├── hooks/                   # 各 Agent 平台 hooks 配置与脚本
│   ├── hooks.json           # Claude hooks 配置
│   ├── copilot-hooks.json   # Copilot hooks 配置
│   ├── cursor-hooks.json    # Cursor hooks 配置
│   └── scripts/
│       ├── outdated.ps1
│       ├── update-version.ps1
│       ├── check-and-update.ps1
│       ├── outdated.sh
│       ├── update-version.sh
│       └── check-and-update.sh
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

## 安装与更新

推荐从marketplace中搜索 ouyangwenzhe-51aes/cim-skills 进行安装。

发布新版本后，插件会自动检查并更新，更新后需要重启 Agent 环境生效。

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

目录命名约定：

- 子目录名 = `SKILL.md` frontmatter 中的 `name` 字段
- 技能正文文件名必须为 `SKILL.md`
- 扁平的 `*.md` 文件不会被识别为技能

## Hooks 机制

`hooks/` 目录，用于在不同 Agent 平台注入统一的版本检查与更新逻辑：

- `hooks/hooks.json`：Claude 的 hooks 配置
- `hooks/copilot-hooks.json`：Copilot 的 hooks 配置（有问题）
- `hooks/cursor-hooks.json`：Cursor 的 hooks 配置
- `hooks/scripts/outdated.sh|ps1`：定义执行版本检查的脚本
- `hooks/scripts/update-version.sh|ps1`：定义执行版本更新的脚本
- `hooks/scripts/check-and-update.sh|ps1`：执行版本检查并更新的脚本

触发点为 `SessionStart`，在会话开始时自动执行版本检查并更新的脚本。


## 维护建议

1. 新增技能时，在 `skills/` 下新建目录，目录名与 frontmatter 的 `name` 一致，正文写入 `SKILL.md`
2. 修改 API 标识时，以技能文档中的示例调用为准

## 发版流程

本项目按 APM 插件发版流程维护版本：

1. 更新 `plugin.json`、`.claude-plugin/plugin.json`、`.cursor-plugin/plugin.json`、`apm.yml`、`CHANGELOG.md`
2. 提交变更并打 tag，例如 `git tag v1.1.0 && git push origin HEAD && git push origin v1.1.0`
3. 用户本地插件通过脚本检测新版本并自动更新

发布新版本：

```powershell
.\dev-scripts\release.ps1 -Version "1.1.0" 
```

打 tag 并推送：

```powershell
.\dev-scripts\release.ps1 -Version 1.1.0 -RunApmPack -Tag -Push
```
