# CIM API Skills Reference

本仓库是 51WORLD 的 CIM API（@wdp-api/cim-api）技能文档集合，面向 Agent 路由和能力编排使用。

本插件遵循 APM 插件规范，技能正文按「每个技能一个目录 + `SKILL.md`」组织在 `skills/` 目录下，可在 Copilot / Claude / Cursor 等兼容的 Agent 环境中安装使用。

## 项目概览

- 技能总数：23
- 一级分类：5（Precheck / Initialization / InternetMap / Spatial / Hospital）
- 入口技能：`skills/00-skill-version-check/SKILL.md`

## 目录结构

```
cim-skills/
├── plugin.json              # 插件描述符，声明 "skills": "./skills/"
├── apm.yml                  # APM marketplace authoring source
├── CHANGELOG.md             # 版本变更记录
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

推荐使用带 tag 的固定版本安装：

```powershell
apm install ouyangwenzhe-51aes/cim-skills#v1.1.0
```

也可以安装最新主分支：

```powershell
apm install ouyangwenzhe-51aes/cim-skills
```

发布新版本后，用户通过重新执行对应版本的 `apm install` 获取更新。

## 能力覆盖

### 1) Precheck

- 前置版本检查（先于其他技能执行）
- 执行 `scripts/outdated.ps1` 检查已安装插件是否落后
- 若存在新版本，提示执行 `apm update cimapi-skills`

对应文档：

- `skills/00-skill-version-check/SKILL.md`

### 2) Initialization

- SDK 安装与插件初始化
- 版本查询
- 通用实体获取与删除

对应文档：

- `skills/initialization/SKILL.md`

### 3) InternetMap

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

### 4) Spatial

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

### 5) Hospital

- 电梯管理
- 房间色块
- 附属设备

对应文档：

- `skills/elevator/SKILL.md`
- `skills/box/SKILL.md`
- `skills/device/SKILL.md`

## 插件加载机制

加载器从 `plugin.json` 的 `"skills": "./skills/"` 入口，扫描 `skills/` 下的**子目录**，读取每个子目录中的 `SKILL.md` 作为一个技能。

按目录命名约定，`00-skill-version-check` 必须作为首个读取的守门技能；其余技能目录保持在其后，确保任何业务技能都先经过版本检查。

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

## 发版流程

本项目按 APM 插件发版流程维护版本：

1. 修改 `SKILL.md`，同步更新 frontmatter 的 `version` 和 `valid_until`
2. 更新 `plugin.json`、`.claude-plugin/plugin.json`、`.cursor-plugin/plugin.json`、`apm.yml`、`CHANGELOG.md`
3. 运行 `apm pack`，从 `apm.yml` 重新生成 marketplace 元数据
4. 提交变更并打 tag，例如 `git tag v1.1.0 && git push origin HEAD && git push origin v1.1.0`
5. 用户通过 `apm install ouyangwenzhe-51aes/cim-skills#v1.1.0` 获取更新

可用脚本辅助同步版本字段：

```powershell
.\scripts\release.ps1 -Version 1.2.0 -RunApmPack
```

检查本地已安装版本是否落后于 marketplace 最新版本：

```powershell
.\scripts\outdated.ps1
```

如果发现新版本，会输出更新提示：

```powershell
apm update cimapi-skills
```

如需一并打 tag 并推送：

```powershell
.\scripts\release.ps1 -Version 1.2.0 -RunApmPack -Tag -Push
```
