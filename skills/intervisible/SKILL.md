---
name: intervisible
description: >
 通视分析工具（App.IntervisibleAnalysis）。提供通视分析对象创建、场景挂载与显示参数更新能力。当需要检测观察点与目标点之间是否可视、分析视线遮挡情况并区分可视与遮挡区域时，使用该工具。

version: "1.0.0"
valid_until: "2026-12-24"
metadata: 
  version: 1.0.0
  tags: [wdpapi, analysis, intervisible, line-of-sight, scene]
---

# App.IntervisibleAnalysis - 通视分析

> 本对象通过 new App.IntervisibleAnalysis(...) 创建后，使用 App.Scene.Add(...) 挂载到场景中生效。

## 概述

App.IntervisibleAnalysis 提供以下能力：

- 设置观察点坐标进行通视分析
- 支持单个或多个目标点参与分析
- 设置可视与遮挡部分颜色
- 支持运行时通过 Update(object) 更新显示参数

---

### 创建对象：new App.IntervisibleAnalysis(object)

**功能：** 创建通视分析对象，并可通过 App.Scene.Add 挂载到场景。

**入参：**

| 参数 | 类型 | 必填 | 说明 | 取值范围 |
| --- | --- | --- | --- | --- |
| startCoords | string | 是 | 观察点坐标值 | x,y 为经纬度；z 为高度，单位米 |
| endCoords | [string] | 是 | 目标点坐标集合 | 支持不止一个目标点 |
| visibleColor | string | 是 | 可视部分颜色 | 颜色字符串（如十六进制） |
| hiddenColor | string | 是 | 遮挡部分颜色 | 颜色字符串（如十六进制） |

**出参：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| entityObj | object | 创建得到的通视分析实体对象（需调用 App.Scene.Add 生效） |

**示例：**

~~~javascript
const entityObj = new App.IntervisibleAnalysis({
	startCoords: "121.49931942,31.25302133,32",
	endCoords: ["121.51419652,31.23725071,55"],
	visibleColor: "fe6668",
	hiddenColor: "84ffa0"
});

const res = await App.Scene.Add(entityObj);
~~~

---

### 成员函数：Update(object)

**功能：** 更新通视分析结果显示参数。

**入参：**

| 参数 | 类型 | 必填 | 说明 | 取值范围 |
| --- | --- | --- | --- | --- |
| visibleColor | string | 否 | 可视部分颜色 | 颜色字符串（如十六进制） |
| hiddenColor | string | 否 | 遮挡部分颜色 | 颜色字符串（如十六进制） |

**出参：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| result | object | 更新调用结果对象（具体字段以运行时返回为准） |

**示例：**

~~~javascript
const jsondata = {
	visibleColor: "fea4a",
	hiddenColor: "1bfe17"
};

await cache.get("intervisible").Update(jsondata);
~~~


