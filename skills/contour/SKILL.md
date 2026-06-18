---
name: contour
description: >
 等高线分析工具（App.ContourAnalysis）。提供等高线分析对象创建、场景挂载与等高线/等高面样式配置能力。当需要对指定区域进行地形高程分析、创建等高线或等高面可视化效果并挂载到场景时，使用该工具。
version: "1.4.0"
valid_until: "2026-12-18"
metadata: 
  version: 1.4.0
  tags: [cimapi, analysis, contour, scene, visualization]
---

# App.ContourAnalysis - 等高线分析

> 本对象通过 new App.ContourAnalysis(...) 创建后，使用 App.Scene.Add(...) 挂载到场景中生效。

## 概述

App.ContourAnalysis 提供以下能力：

- 按中心点与分析范围创建等高线分析对象
- 设置高程归一化最小值、最大值与等高线间隔
- 控制展示类型（等高线、等高面或同时显示）
- 配置等高线颜色与等高面颜色数组

---

### 创建对象：new App.ContourAnalysis(object)

**功能：** 创建等高线分析对象，并可通过 App.Scene.Add 挂载到场景。

**入参：**

| 参数 | 类型 | 必填 | 说明 | 取值范围 |
| --- | --- | --- | --- | --- |
| coord | string | 是 | 中心坐标经纬度 | lng,lat 或 lng,lat,alt |
| coordZ | integer | 是 | 中心坐标高度 | 数值，单位米 |
| coordZType | integer | 是 | 坐标高度类型 | 0: 相对3D世界表面；1: 相对3D世界地面；2: 相对3D世界海拔；CAD 坐标无效 |
| sizeX | integer | 是 | 东西方向长度 | 数值，单位米 |
| sizeY | integer | 是 | 南北方向长度 | 数值，单位米 |
| minHeight | integer | 是 | 高程归一化最小高度 | 数值，单位 cm |
| maxHeight | integer | 是 | 高程归一化最大高度 | 数值，单位 cm |
| interval | integer | 是 | 等高线间隔 | 数值，单位米 |
| type | integer | 是 | 等高线类型 | 1: 只显示等高线；2: 只显示等高面；3: 同时显示等高线和等高面 |
| lineColor | string | 否 | 等高线颜色 | 支持十六进制颜色代码；不设置时使用默认等高线颜色 |
| surfaceColors | [string] | 是 | 面颜色数组 | 最大限制 5 个；不设置时使用默认 5 种等高线颜色 |

**出参：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| entityObj | object | 创建得到的等高线分析实体对象（需调用 App.Scene.Add 生效） |

**示例：**

~~~javascript
const entityObj = new App.ContourAnalysis({
	coord: "121.50868189,31.23486569,16",
	coordZ: 0,
	coordZType: 0,
	sizeX: 2100,
	sizeY: 2100,
	minHeight: 0,
	maxHeight: 100,
	interval: 5,
	type: 1,
	lineColor: "ffcb35",
	surfaceColors: ["00009CFF", "007633FF", "917200FF", "C00000FF", "FFFFE9FF"]
});

const res = await App.Scene.Add(entityObj);
~~~

---

### 成员函数

当前截图未提供成员函数（如 Update(object)）的定义与参数说明，后续补充资料后可按同模板继续完善。
