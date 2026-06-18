---
name: skyline
description: >
   天际线分析工具（App.SkyLineAnalysis）。提供天际线分析对象创建、场景挂载、线条样式设置与截图输出参数配置能力。当需要分析场景建筑轮廓形成的天际线、渲染天际线效果并导出截图时，使用该工具。
version: "1.2.0"
valid_until: "2026-12-18"
metadata: 
  version: 1.2.0
  tags: [wdpapi, analysis, skyline, scene, visualization]
---

# App.SkyLineAnalysis - 天际线分析

> 本对象通过 new App.SkyLineAnalysis(...) 创建后，使用 App.Scene.Add(...) 挂载到场景中生效。

## 概述

App.SkyLineAnalysis 提供以下能力：

- 创建天际线分析实体并渲染分析结果
- 设置天际线颜色与线条粗细
- 配置输出图片宽高
- 支持指定输出文件名导出（支持 png、jpg）
- 支持运行时通过 Update(object) 更新显示参数

---

### 创建对象：new App.SkyLineAnalysis(object)

**功能：** 创建天际线分析对象，并可通过 App.Scene.Add 挂载到场景。

**入参：**

| 参数 | 类型 | 必填 | 说明 | 取值范围 |
| --- | --- | --- | --- | --- |
| color | string | 是 | 天际线颜色 | 颜色字符串 |
| thickness | integer | 是 | 天际线线条粗细 | 正整数 |
| outputWidth | integer | 是 | 输出图片宽度 | outputImageFileName 非空时生效 |
| outputHeight | integer | 是 | 输出图片高度 | outputImageFileName 非空时生效 |
| outputImageFileName | string | 是 | 输出图片文件完整名称 | 支持 png、jpg；如果为空则输出截图 |

**出参：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| entityObj | object | 创建得到的天际线分析实体对象（需调用 App.Scene.Add 生效） |

**示例：**

~~~javascript
const entityObj = new App.SkyLineAnalysis({
	color: "27ff3e",
	thickness: 15,
	outputWidth: "1920",
	outputHeight: "1080",
	outputImageFileName: ""
});

const res = await App.Scene.Add(entityObj);
~~~

---

### 成员函数：Update(object)

**功能：** 更新天际线分析结果显示参数。

**入参：**

| 参数 | 类型 | 必填 | 说明 | 取值范围 |
| --- | --- | --- | --- | --- |
| color | string | 否 | 天际线颜色 | 颜色字符串 |
| thickness | integer | 否 | 天际线线条粗细 | 正整数 |

**出参：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| result | object | 更新调用结果对象（具体字段以运行时返回为准） |

**示例：**

~~~javascript
const jsondata = {
	color: "ff3788",
	thickness: 100
};

await cache.get("skyline").Update(jsondata);
~~~
