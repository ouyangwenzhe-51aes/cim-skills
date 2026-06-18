---
name: dig-terrain
description: >
 填挖方分析工具（App.DigTerrainAnalysis）。提供填挖方分析对象创建、场景挂载与挖方深度配置能力。当需要对指定区域进行土方工程的填挖方分析、设置挖方深度并在场景中展示分析结果时，使用该工具。
version: "1.4.0"
valid_until: "2026-12-18"
metadata: 
  version: 1.4.0
  tags: [cimapi, analysis, dig-terrain, earthwork, scene]
---

# App.DigTerrainAnalysis - 填挖方分析

> 本对象通过 new App.DigTerrainAnalysis(...) 创建后，使用 App.Scene.Add(...) 挂载到场景中生效。

## 概述

App.DigTerrainAnalysis 提供以下能力：

- 基于区域坐标集合创建填挖方分析对象
- 设置挖方深度参数
- 支持场景中展示填挖方分析结果

---

### 创建对象：new App.DigTerrainAnalysis(object)

**功能：** 创建填挖方分析对象，并可通过 App.Scene.Add 挂载到场景。

**入参：**

| 参数 | 类型 | 必填 | 说明 | 取值范围 |
| --- | --- | --- | --- | --- |
| coordinates | array | 是 | 挖方区域坐标集合 | 每项建议为 [lng, lat, alt] |
| depth | integer | 是 | 挖方深度 | 数值，单位米 |

**出参：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| entityObj | object | 创建得到的填挖方分析实体对象（需调用 App.Scene.Add 生效） |

**示例：**

~~~javascript
const entityObj = new App.DigTerrainAnalysis({
	coordinates: [
		[121.47243551, 31.22135755, 39],
		[121.49274509, 31.22718139, 42],
		[121.46511916, 31.22184437, 55],
		[121.49234913, 31.23381847, 18]
	],
	depth: 200
});

const res = await App.Scene.Add(entityObj);
~~~

