---
name: keycommon
description: >
  设置高德地图key工具（App.cim.InternetMapCommon）。提供动态设置高德地图key能力。在在场景中需要加载高德地图底图并配置地图访问密钥时，使用该工具。
version: "1.4.0"
valid_until: "2026-12-18"
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

**示例：**

~~~javascript
const jsondata = {
	"userkey": "3d40affab7b6a1dedb2330a817e6e2bd"
}

const res = await App.cim.InternetMapCommon(jsondata);
~~~
