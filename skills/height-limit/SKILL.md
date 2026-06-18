---
name: height-limit
description: >
  限高分析工具（App.HeightLimitAnalysis）。提供限高分析对象创建、场景挂载与分析参数更新能力。当需要对场景进行限高检测、标记超限区域、配置限高阈值与效果颜色，或在运行时更新分析参数时，使用该工具。
version: "1.0.0"
valid_until: "2026-12-18"
metadata: 
  version: 1.0.0
  tags: [wdpapi, analysis, height-limit, scene, visualization]
---

# App.HeightLimitAnalysis - 限高分析

> 本对象通过 new App.HeightLimitAnalysis(...) 创建后，使用 App.Scene.Add(...) 挂载到场景中生效。

## 概述

App.HeightLimitAnalysis 提供以下能力：

- 设置限高阈值并进行限高分析
- 配置限高效果颜色
- 支持全域检测与指定范围检测
- 支持通过点集定义检测区域
- 支持运行时通过 Update(object) 更新分析参数

---

### 创建对象：new App.HeightLimitAnalysis(object)

**功能：** 创建限高分析对象，并可通过 App.Scene.Add 挂载到场景。

**入参：**

| 参数 | 类型 | 必填 | 说明 | 取值范围 |
| --- | --- | --- | --- | --- |
| heightLimit | string | 是 | 限制高度（单位: 米） | 正数值字符串 |
| limitColor | string | 是 | 限高效果颜色 | 颜色字符串（如十六进制） |
| isAllRegion | boolean | 是 | 是否使用全域检测 | true: 全域；false: 固定范围 |
| points | [string] | 是 | 检测范围点集 | 仅在 isAllRegion=false 时有效，格式建议为 lng,lat 或 lng,lat,alt |

**出参：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| entityObj | object | 创建得到的限高分析实体对象（需调用 App.Scene.Add 生效） |

**示例：**

~~~javascript
const entityObj = new App.HeightLimitAnalysis({
	heightLimit: "1500",
	limitColor: "ffefc9",
	points: [
		"121.49864712620499,31.256147270743853",
		"121.48883000916418,31.251089484058205",
		"121.49043985828526,31.243971677466156",
		"121.50305603093527,31.246380131108076"
	],
	isAllRegion: true
});

const res = await App.Scene.Add(entityObj);
~~~

---

### 成员函数：Update(object)

**功能：** 更新限高分析结果参数。

**入参：**

| 参数 | 类型 | 必填 | 说明 | 取值范围 |
| --- | --- | --- | --- | --- |
| heightLimit | string | 否 | 限制高度（单位: 米） | 正数值字符串 |
| limitColor | string | 否 | 限高效果颜色 | 颜色字符串（如十六进制） |
| isAllRegion | boolean | 否 | 是否使用全域检测 | true: 全域；false: 固定范围 |
| points | [string] | 否 | 更新检测范围点集 | 仅在 isAllRegion=false 时有效 |

**出参：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| result | object | 更新调用结果对象（具体字段以运行时返回为准） |

**示例：**

~~~javascript
const jsondata = {
	// 更新样式（可选）
	heightLimit: "10",
	limitColor: "ff4a8b",

	// 更新区域（可选）
	isAllRegion: true,
	points: ["121.50094189,31.24658765,26"]
};

await cache.get("heightlimit").Update(jsondata);
~~~
