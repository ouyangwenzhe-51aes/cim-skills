---
name: sunlight
description: >
   日照分析工具（App.SunLightAnalysis），提供日照分析对象创建、场景挂载与时间区间日照计算配置能力。当需要按时间段评估指定区域的光照覆盖效果，进行建筑方案比选、住区采光评估、日照合规校核或公共空间舒适度分析时，使用该工具。
version: "1.4.0"
valid_until: "2026-12-18"
metadata: 
  version: 1.4.0
  tags: [cimapi, analysis, sunlight, scene, simulation]
---

# App.SunLightAnalysis - 日照分析

> 本对象通过 new App.SunLightAnalysis(...) 创建后，使用 App.Scene.Add(...) 挂载到场景中生效。

## 概述

App.SunLightAnalysis 提供以下能力：

- 基于多点坐标集合定义分析区域
- 设置限高分析高度
- 设置日照分析开始和结束时间
- 支持时区与夏令时参数配置

---

### 创建对象：new App.SunLightAnalysis(object)

**功能：** 创建日照分析对象，并可通过 App.Scene.Add 挂载到场景。

**入参：**

| 参数 | 类型 | 必填 | 说明 | 取值范围 |
| --- | --- | --- | --- | --- |
| coordinates | array | 是 | 分析区域坐标集合 | 每项建议为 [lng, lat, alt] |
| height | integer | 是 | 限高分析高度 | 数值，单位米 |
| startDateTime | string | 是 | 限高分析开始时间 | 时间字符串（示例格式见下） |
| endDateTime | string | 是 | 限高分析结束时间 | 时间字符串（示例格式见下） |
| timeZone | integer | 是 | 时区 | 例如 8 表示东八区 |
| isDaylightSavingTime | boolean | 是 | 是否为夏令时 | true 或 false |

**出参：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| entityObj | object | 创建得到的日照分析实体对象（需调用 App.Scene.Add 生效） |

**示例：**

~~~javascript
const entityObj = new App.SunLightAnalysis({
	coordinates: [
		[121.47243551, 31.22135755, 39],
		[121.49274509, 31.22718139, 42],
		[121.46511916, 31.22184437, 55],
		[121.49234913, 31.23381847, 18],
		[121.47021573, 31.21914543, 24],
		[121.46516786, 31.2355321, 48]
	],
	height: 400,
	startDateTime: "2023.12.13-09.00.00",
	endDateTime: "2023.12.13-18.00.00",
	timeZone: 8,
	isDaylightSavingTime: false
});

const res = await App.Scene.Add(entityObj);
~~~



