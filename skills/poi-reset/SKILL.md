---
name: poi-reset
description: >
  App.cim.InternetMapPoiReset 提供清除已搜索的POI的能力，支持按分类清除或清除全部。当需要清除场景中已搜索的POI对象、按指定分类清理或一次性清空所有POI时，使用该工具。
version: "1.2.0"
valid_until: "2026-12-18"
metadata:
  version: 1.2.0
  tags: [cimapi, internet-map, poi, reset]
---

# App.cim.InternetMapPoiReset - 重置搜索POI

## 概述

App.cim.InternetMapPoiReset 提供以下能力：

- 清除已搜索的POI，支持按分类清除或清除全部

---

### App.cim.InternetMapPoiReset(type)

**功能：** 清除已搜索的 POI，可按分类清除或清除全部。

**入参：**

| 参数 | 类型 | 必填 | 取值范围 | 备注 |
| --- | --- | --- | --- | --- |
| type | string | 否 | name, polygon, circle, screen | 不填写则清除所有POI |

**出参：** 无

**示例：**

~~~javascript
const type = 'polygon'; //不填写则清除所有POI
const res = await App.cim.InternetMapPoiReset(type);
~~~