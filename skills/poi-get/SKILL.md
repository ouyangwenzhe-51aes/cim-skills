---
name: poi-get
description: >
  获取已搜索的POI对象并进行操作（App.cim.InternetMapPoiGet）。当需要获取场景中已搜索的POI对象、按分类筛选、查询信息、控制显隐、更新样式、删除或聚焦到指定POI时，使用该工具。
metadata:
  version: 1.0.0
  tags: [cimapi, internet-map, poi, get, scene]
---

# App.cim.InternetMapPoiGet - 获取搜索POI

## 概述

App.cim.InternetMapPoiGet 提供以下能力：

- 获取已搜索的POI对象，支持按分类筛选或获取全部
- 对获取到的 poiObj 进行信息查询、显隐切换、更新、删除操作
- 支持聚焦到指定 POI 对象
- 支持对同一分类下的全部POI进行批量显隐、更新、删除

---

### App.cim.InternetMapPoiGet(type)

**功能：** 获取已搜索的 POI 对象，按分类返回。

**入参：**

| 参数 | 类型 | 必填 | 取值范围 | 备注 |
| --- | --- | --- | --- | --- |
| type | string | 否 | name, polygon, circle, screen | 不填写则获取所有分类POI |

**出参：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| success | boolean | 是否成功 |
| message | string | 错误信息 |
| result.objects | object | 按分类存储的POI对象，key 为 name/polygon/circle/screen，value 为对象数组 |

**示例：**

~~~javascript
const type = 'polygon'; //不填写则获取所有分类POI
const res = await App.cim.InternetMapPoiGet(type);
console.log(res);

// 示例: 获取其中一个分类poi信息
const poiObj = res.result.objects[type][0];
const { result } = await poiObj.Get();
console.log(result);

// 示例: 聚焦其中一个分类poi
const jsondata = {
  "rotation": {
    "pitch": -40, //俯仰角;取值范围[-90~0]
    "yaw": 0 //偏航角;取值范围[-180~180](0:东; 90:南; -90:北)
  },
  "distanceFactor": 1, //视野参数范围[0.1~1]; 占满屏幕百分比
  "flyTime": 1, //过渡时长(单位:秒)
  "entity": [poiObj] //实体对象
}
await App.CameraControl.Focus(jsondata);

// 示例: 显隐其中一个分类poi
await poiObj.SetVisible(false);  // true: 显示; false: 隐藏

// 示例: 更新其中一个分类poi
await poiObj.Update(updateJson);  //updateJson与wdpapi POI模块数据相同

// 示例: 删除其中一个分类poi
await poiObj.Delete();

// 示例: 显隐其中一个分类全部poi
await App.Scene.SetVisible(res.result.objects[type]);   // true: 显示; false: 隐藏

// 示例: 更新其中一个分类全部poi
await App.Scene.Update(res.result.objects[type], updateJson);  //updateJson与wdpapi POI模块数据相同

// 示例: 删除其中一个分类全部poi
await App.Scene.Delete(res.result.objects[type]);
~~~

**附：updateJson 参数说明**

| 参数 | 类型 | 必填 | 取值范围 | 备注 |
| --- | --- | --- | --- | --- |
| location | array | 否 |  | 坐标 [lng, lat, alt] |
| poiStyle.markerNormalUrl | string | 否 |  | 正常状态图片url |
| poiStyle.markerActivateUrl | string | 否 |  | 激活状态图片url |
| poiStyle.markerSize | array | 否 |  | marker大小（宽, 高 单位：像素） |
| poiStyle.labelBgImageUrl | string | 否 |  | label背景图片url |
| poiStyle.labelBgSize | array | 否 |  | label背景大小（宽, 高 单位：像素） |
| poiStyle.labelBgOffset | array | 否 |  | label背景偏移（x>0向右，y>0向上，单位：像素） |
| poiStyle.labelContent | array | 否 | ["文本内容", "ff0000ff", "24"] | 富文本；格式：["text", "color", "size"]，color为HEXA格式 |
| poiStyle.labelContentOffset | array | 否 |  | label内容偏移（x>0向右，y>0向下，单位：像素） |
| poiStyle.labelTop | boolean | 否 | true, false | label是否置于marker顶层 |
| entityName | string | 否 |  | 实体名称 |
| customId | string | 否 |  | 自定义ID |
| customData | object | 否 |  | 自定义数据 |
| bVisible | boolean | 否 | true, false | 是否可见 |
| visible2D.camera.hideDistance | number | 否 | 正整数 | 定义实体隐藏的距离（单位：米），相机超过此距离时实体会被隐藏 |
| visible2D.camera.hideType | string | 否 | none, default | 实体超出显示距离的处理方式（none:不显示; default:圆圈显示） |
| visible2D.camera.scaleMode | string | 否 | 2D, 3D | 是否受相机透视影响（2D:不影响; 3D:影响） |
| visible2D.interaction.clickTop | boolean | 否 | true, false | 点击时是否显示在最上层 |
| visible2D.interaction.hoverTop | boolean | 否 | true, false | 滑过时是否显示在最上层 |
| visible2D.entity.overlapOrder | number | 否 | 1~10 | 重叠层级，数值越大越浮在最上层 |

