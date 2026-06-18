---
name: openness
description: >
   开敞度分析工具（App.OpennessAnalysis）。提供开敞度分析对象创建、场景挂载与分析样式更新能力。当需要评估观察点周围的开敞程度、分析指定扇形区域内的可视与遮挡情况，并配置显示样式与显示模式时，使用该工具。   
version: "1.4.0"
valid_until: "2026-12-18"
metadata: 
  version: 1.4.0
  tags: [cimapi, analysis, openness, scene, visualization]
---

# App.OpennessAnalysis - 开敞度分析

> 本对象通过 new App.OpennessAnalysis(...) 创建后，使用 App.Scene.Add(...) 挂载到场景中生效。

## 概述

App.OpennessAnalysis 提供以下能力：

- 基于给定观察点与半径创建开敞度分析对象
- 控制分析扇形起止角度
- 设置可视与不可视区域颜色
- 控制显示模式（全部/仅可视/仅隐藏）
- 支持是否封口显示
- 支持运行时通过 Update(object) 更新分析参数

---

### 创建对象：new App.OpennessAnalysis(object)

**功能：** 创建开敞度分析对象，并可通过 App.Scene.Add 挂载到场景。

**入参：**

| 参数 | 类型 | 必填 | 说明 | 取值范围 |
| --- | --- | --- | --- | --- |
| coord | string | 是 | 坐标点 | lng,lat 或 lng,lat,alt |
| coordZ | integer | 是 | 高度（单位: 米） | 建议 >= 0 |
| coordZType | integer | 是 | 坐标高度类型 | 0: 相对3D世界表面；1: 相对3D世界地面；2: 相对3D世界海拔；cad坐标无效 |
| radius | integer | 是 | 观察半径（单位: 米） | > 0 |
| startAngle | integer | 是 | 起始角度 | 0~360 |
| endAngle | integer | 是 | 终止角度 | 0~360 |
| visibleColor | string | 是 | 可视部分颜色 | 十六进制颜色字符串 |
| hiddenColor | string | 是 | 隐藏部分颜色 | 十六进制颜色字符串 |
| showType | integer | 是 | 显示类型 | 0: 全部显示；1: 可视部分；2: 隐藏部分 |
| close | boolean | 是 | 是否封口 | true 或 false |

**出参：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| entityObj | object | 创建得到的开敞度分析实体对象（需调用 App.Scene.Add 生效） |

**示例：**

~~~javascript
const entityObj = new App.OpennessAnalysis({
	coord: "121.49704709,31.23592140,32",
	coordZ: 0,
	coordZType: 0,
	radius: 300,
	startAngle: 0,
	endAngle: 360,
	visibleColor: "ae7eff",
	hiddenColor: "16cdff",
	showType: 0,
	close: false
});

const res = await App.Scene.Add(entityObj);
~~~

---

### 成员函数：Update(object)

**功能：** 更新开敞度分析对象的显示参数。

**入参：**

| 参数 | 类型 | 必填 | 说明 | 取值范围 |
| --- | --- | --- | --- | --- |
| radius | integer | 否 | 观察半径（单位: 米） | > 0 |
| startAngle | integer | 否 | 起始角度 | 0~360 |
| endAngle | integer | 否 | 终止角度 | 0~360 |
| visibleColor | string | 否 | 可视部分颜色 | 十六进制颜色字符串 |
| hiddenColor | string | 否 | 隐藏部分颜色 | 十六进制颜色字符串 |
| showType | integer | 否 | 显示类型 | 0: 全部显示；1: 可视部分；2: 隐藏部分 |
| close | boolean | 否 | 是否封口 | true 或 false |

**出参：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| result | object | 更新调用结果对象（具体字段以运行时返回为准） |

**示例：**

~~~javascript
const jsondata = {
	radius: 300,
	startAngle: 0,
	endAngle: 360,
	visibleColor: "7392ff",
	hiddenColor: "ff8e1e",
	showType: 0,
	close: false
};

await cache.get("openness").Update(jsondata);
~~~
