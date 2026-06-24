---
name: select-path
description: >
  SelectNaviPath 提供选择地图提供三条导航路径其中之一。当需要从高德地图返回的多条导航路线中选择其中一条作为最终路径时，使用该工具。

version: "1.0.0"
valid_until: "2026-12-24"
metadata:
  version: 1.0.0
  tags: [cimapi, internet-map, navigation]
---

# SelectNaviPath - 选择导航路径

> 执行Navipath时自行注册事件回调函数添加的路径不可用; 可自行执行路径对象Update等方式处理高亮

## 概述

SelectNaviPath 提供以下能力：

- 选择地图提供三条导航路径其中之一

---

### 选择导航路径：SelectNaviPath(jsondata)

**功能：** 选择地图提供三条导航路径其中之一。

**入参：**

| 参数 | 类型 | 必填 | 取值范围 | 备注 |
| --- | --- | --- | --- | --- |
| naviId | string | 是 | 可选道路id; [1~3] (1:距离优先; 2:速度最快; 3:躲避拥堵) |  |

**出参：** 无

**示例：**

~~~javascript
const jsondata = {
	"naviId": "2" //导航路径id之一
}

const res = await cache.get('mappath').SelectNaviPath(jsondata);
~~~


