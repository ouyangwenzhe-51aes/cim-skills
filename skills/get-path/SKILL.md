---
name: get-path
description: >
  获取已添加到场景中的导航路径对象数据，并支持对路径进行显隐、更新、删除与聚焦操作。当需要获取场景中已存在的导航路径并对其进行显隐控制、样式更新、删除或聚焦操作时，使用该工具。

metadata:
  version: 1.4.0
  tags: [cimapi, internet-map, navigation, path, scene]
---

# GetNaviPath - 获取导航路径

> 获取到的路径对象，操作属性与wdpapi路径模块相同。

## 概述

GetNaviPath 提供以下能力：

- 获取已添加到场景中的导航路径对象数据
- 支持对单条路径进行显隐、更新、删除操作
- 支持对全部路径进行批量显隐、更新、删除操作
- 支持聚焦路径

---

### 获取导航路径：GetNaviPath()

**功能：** 获取添加到场景中的导航路径对象数据。

**入参：** 无

**出参：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| success | boolean | 是否成功 |
| message | string | 错误信息 |
| result.objects | array | 路径对象数组，每项可独立进行显隐、更新、删除等操作 |

**示例：**

~~~javascript
const res = await cache.get('mappath').GetNaviPath();
console.log(res);

// 示例：显隐其中一条路径
await pathObj.SetVisible(false); // true: 显示; false: 隐藏

// 示例：更新其中一条路径
await pathObj.Update(updateJson); //updateJson与wdpapi路径模块数据相同

// 示例：删除其中一条路径
await pathObj.Delete();

// 示例：显隐全部路径
await App.Scene.SetVisible(res.result.objects); // true: 显示; false: 隐藏

// 示例：更新全部路径
await App.Scene.Update(res.result.objects, updateJson); //updateJson与wdpapi路径模块数据相同

// 示例：删除全部路径
await App.Scene.Delete(res.result.objects);

// 示例: 聚焦路径
await App.CameraControl.Focus({
    "rotation": {
        "pitch": -85, //俯仰角;取值范围[-90~0]
        "yaw": 0 //偏航角;取值范围[-180~180](0:东; 90:南; -90:北)
    },
    "distanceFactor": 0.6, //视野参数范围[0.1~1]; 占满屏幕百分比
    "flyTime": 1, //过渡时长(单位:秒)
    "entity": [res.result.objects[0]] //实体对象
});

// 示例: 点击路径聚焦
res.result.objects[0].onClick(async ({ result }) => {
    const res = await entityFocus(result.object);
    console.log(res);
})
~~~

---

### updateJson 数据结构

| 参数 | 类型 | 必填 | 取值范围 | 备注 |
| --- | --- | --- | --- | --- |
| polyline.coordinates | array | 否 |  | 路径坐标点数组，每项为 [lng, lat, alt] |
| pathStyle.type | string | 否 |  | 路径样式类型 |
| pathStyle.width | number | 否 | 正数 | 宽度，单位米 |
| pathStyle.color | string | 否 | HEXA,RGBA | 整体颜色 |
| pathStyle.passColor | string | 否 | HEXA,RGBA | 已通过段颜色 |
| bVisible | boolean | 否 |  | 是否显示 |
| entityName | string | 否 |  | 实体名称 |
| customId | string | 否 |  | 自定义ID |
| customData | object | 否 |  | 自定义数据 |

~~~javascript
const updateJson = {
	"polyline": {
		"coordinates": [
			[121.49968476, 31.24861346, 44],
			[121.49956979, 31.25093239, 96],
			[121.47613890, 31.23725069, 39]
		]
	},
	"pathStyle": {
		"type": "arrow",
		"width": 100,
		"color": "b4fed7ff", //HEXA或rgba(0,0,0,0.8)
		"passColor": "ffb3deff"
	},
	"bVisible": true,
	"entityName": "myName",
	"customId": "myId1",
	"customData": {
		"data": "myCustomData"
	}
}
~~~



