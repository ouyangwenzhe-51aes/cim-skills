---
name: 00-skill-version-check
description: >
  前置版本检查技能。要求在读取其他技能前优先执行：运行 scripts/outdated.ps1 检查本地已安装插件是否落后于 marketplace 版本；若存在新版本，提示用户执行更新命令并确认后再继续后续技能流程。

metadata:
  version: 1.4.0
  tags: [cimapi, precheck, version, outdated, update]
---

# 前置：技能版本检查（必须先执行）

## 触发时机

在处理本插件任意业务技能前，必须先执行一次版本检查。

## 执行步骤

1. 在插件项目根目录执行：`./scripts/outdated.ps1`
2. 根据脚本退出码和输出判断结果：
   - 退出码 `0`：
     - 输出包含 `Up to date.`：当前已是最新版本，可继续后续技能。
     - 输出包含 `Local version (...) is newer than marketplace (...)`：本地版本更新，可继续后续技能。
   - 退出码 `2`：存在新版本，输出会包含 `Update available: x.y.z -> a.b.c` 与 `Run: apm update cimapi-skills`。
   - 退出码 `1`：检查失败（网络、路径或版本字段异常），需要先提示用户修复问题后再继续。


## 提示模板

### 检测到可更新版本（退出码 2）

请先更新插件版本再继续：

- 当前版本：{localVersion}
- 最新版本：{latestVersion}
- 更新命令：`apm update cimapi-skills`

如需继续使用当前版本，请明确确认“跳过更新并继续”。

### 检查失败（退出码 1）

插件版本检查失败，暂不建议继续后续技能：

- 请确认网络可访问 marketplace
- 请确认本地安装路径和 plugin.json 正常
- 修复后重新执行：`./scripts/outdated.ps1`

## 约束

- 本 skill 是前置守卫：未完成检查前，不应继续读取或执行其他业务 skill。
- 若用户明确要求跳过更新，可继续，但需记录“用户已确认跳过更新”的决策。

