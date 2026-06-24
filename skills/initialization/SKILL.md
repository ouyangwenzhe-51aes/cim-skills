---
name: initialization
description: >
  CIM API SDK 安装初始化与通用行为。包含SDK安装、插件初始化（WdpApi + CimApi）、版本查询（App.cim.GetVersion），以及所有实体对象通用的属性获取（entityObj.Get）和删除（entityObj.Delete）操作。当需要初始化 CIM API SDK 并安装插件时；需要查询 SDK 或场景插件版本时；需要获取或删除场景中已创建的实体对象时，使用该工具。

metadata:
  version: 1.4.0
  tags: [cimapi, init, plugin, version, get, delete, common]
---

# SDK安装与初始化

## 概述

CIM API SDK 提供以下能力：

- 通过 npm 安装 wdpapi 和 @wdp-api/cim-api
- 初始化 WdpApi 实例并安装 CimApi 插件
- 卸载已安装的 CimApi 插件

---

### 安装与初始化

**功能：** 安装SDK依赖，初始化 WdpApi 实例，并将 CimApi 作为插件挂载。

**入参（config）：**

| 参数 | 类型 | 必填 | 取值范围 | 备注 |
| --- | --- | --- | --- | --- |
| id | string | 是 |  | 播放器容器ID |
| url | string | 是 |  | 渲染器地址 |
| order | string | 是 |  | 渲染器订单号 |
| debugMode | string | 否 | normal | 调试模式 |
| resolution | array | 否 |  | 分辨率，格式 [width, height] |
| keyboard.normal | boolean | 否 | true, false | 是否启用普通键盘 |
| keyboard.func | boolean | 否 | true, false | 是否启用功能键（F1~F12） |

**出参（App.Plugin.Install）：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| result.id | string | 已安装插件的ID，用于卸载 |

> **Agent 行为约定（必读）：** `url`（渲染器地址）与 `order`（渲染器订单号）为**必填且无默认值**，由用户从 51WORLD 云平台获取。
> 当用户未明确提供这两个值时，**必须先停下来向用户提问索取 `url` 和 `order`**，禁止臆造、复用文档示例值或用占位符直接运行；只有在拿到用户提供的真实值后，才生成并执行初始化代码。

**示例：**

~~~javascript
// 1. 安装 CIM API SDK
// npm install wdpapi
// npm install @wdp-api/cim-api

// 2. 工程中引入cimApi
import WdpApi from "wdpapi";
import CimApi from "@wdp-api/cim-api";

// 3. 初始化插件
// 设置初始化参数
// 注意：url 与 order 必须向用户索取，切勿写死下方占位值
const config = {
  "id": 'player',
  "url": "<向用户索取：渲染器地址>",
  "order": "<向用户索取：渲染器订单号>",
  "debugMode": "normal",
  "resolution": [1920, 1080],
  "keyboard": {
    "normal": false,
    "func": false
  }
}

// 实例化wdpapi对象
const App = new WdpApi(config);

// 4. 启动云渲染（必须，否则场景不会加载）
const startRes = await App.Renderer.Start();
if (!startRes.success) throw new Error(startRes.message);

// 5. 监听场景加载完成
await App.Renderer.RegisterSceneEvent([
  {
    name: 'OnWdpSceneIsReady',
    func: (res) => {
      if (res.result.progress === 100) {
        // 场景加载完成
      }
    }
  }
]);

// 6. 安装CimApi插件到wdpapi对象

const res = await App.Plugin.Install(CimApi);
console.log(res.result.id)

// 插件卸载
await App.Plugin.Uninstall(res.result.id);
~~~

### 获取版本信息：App.cim.GetVersion()

**功能：** 获取 CIM API JS SDK 和场景插件的当前版本信息。

**入参：** 无

**出参：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| success | boolean | 是否成功 |
| message | string | 错误信息 |
| result.CimApiJsSdk | string | JS SDK 版本号 |
| result.CimApiScenePlugins | string | 场景插件版本号 |

**示例：**

~~~javascript
const res = await App.cim.GetVersion();
console.log(res);
~~~

### 获取属性：entityObj.Get()

**功能：** 获取实体对象的属性信息。entityObj 为 new App.xxx({...}) 时创建的对象。

**入参：** 无

**出参：** 取决于具体实体类型

**示例：**

~~~javascript
async function GetInfo () {
  // 示例: 获取高线分析对象信息
  // entityObj 为 new App.ContourAnalysis({...}) 时创建的对象;

  const res = await entityObj.Get();
  console.log(res)
}
~~~

### 删除实体：entityObj.Delete()

**功能：** 删除实体对象。entityObj 为 new App.xxx({...}) 时创建的对象。

**入参：** 无

**出参：** 无

**示例：**

~~~javascript
async function Delete () {
  // 示例: 删除 高线分析实体 ContourAnalysis
  // entityObj 为 new App.ContourAnalysis({...}) 时创建的对象;
  await entityObj.Delete();
}
~~~


