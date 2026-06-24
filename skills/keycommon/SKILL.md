---
name: keycommon
description: >
  设置高德地图key工具（App.cim.InternetMapCommon）。提供动态设置高德地图key能力。在在场景中需要加载高德地图底图并配置地图访问密钥时，使用该工具。

metadata:
  version: 1.4.0
  tags: [cimapi, internet-map, key]
---

# App.cim.InternetMapCommon - 设置高德地图key

## 概述

App.cim.InternetMapCommon 提供以下能力：

- 动态设置高德地图key

---

### App.cim.InternetMapCommon(jsondata)

**功能：** 动态设置高德key。

**入参：**

| 参数 | 类型 | 必填 | 取值范围 | 备注 |
| --- | --- | --- | --- | --- |
| userkey | string | 是 | 高德地图开放平台-开发者后台获取 |  |

**出参：** 无

> **Agent 行为约定（必读）：** `userkey` 应由用户从高德地图开放平台申请。示例中的 `3d40affab7b6a1dedb2330a817e6e2bd` 为**默认试用 key**，仅供试用。
> 当代码使用该默认 key 时，**必须在浏览器中弹窗提示**：`默认key仅提供试用，请从高德地图开放平台申请key`，引导用户替换为自有 key。

**示例：**

~~~javascript
// 默认试用 key，仅供试用
const DEFAULT_MAP_KEY = "3d40affab7b6a1dedb2330a817e6e2bd";

const userkey = DEFAULT_MAP_KEY;

// 使用默认 key 时，浏览器弹窗提示
if (userkey === DEFAULT_MAP_KEY) {
	alert("默认key仅提供试用，请从高德地图开放平台申请key");
}

const jsondata = {
	"userkey": userkey
}
//调用行为必须在OnWdpSceneIsReady进度达到100%后执行，否则会报错
const res = await App.cim.InternetMapCommon(jsondata);
~~~


