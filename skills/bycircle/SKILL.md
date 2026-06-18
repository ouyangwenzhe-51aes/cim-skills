---
name: bycircle
description: >
  POI圆形搜索工具（App.cim.InternetMapPoiByCircle）。根据圆心坐标和半径范围搜索POI点位，并支持自定义样式挂载到场景。当需要以圆形区域为范围搜索周边POI点位、按分类筛选结果并配置POI样式挂载到场景时，使用该工具。
version: "1.3.0"
valid_until: "2026-12-18"
metadata:
  version: 1.3.0
  tags: [cimapi, internet-map, poi, circle, search, scene]
---

# App.cim.InternetMapPoiByCircle - POI搜索："圆形"搜索

## 概述

App.cim.InternetMapPoiByCircle 提供以下能力：

- 根据圆心坐标和半径范围搜索指定城市的POI点位
- 支持按POI分类类型过滤搜索结果
- 支持通过 customData.poiStyle 配置 marker 样式与标签内容
- 支持通过 customData.visible2D 配置相机距离显隐规则
- 支持通过 customData.calculateCoordZ 配置坐标高度
- 支持 customData 未定义时通过回调数据自行添加 POI

---

### App.cim.InternetMapPoiByCircle(jsondata)

**功能：** 根据圆心坐标和半径范围搜索 POI，并可通过 customData 自动挂载到场景。

**入参：**

| 参数 | 类型 | 必填 | 取值范围 | 备注 |
| --- | --- | --- | --- | --- |
| coordType | string | 是 | wgs84, gcj02 | 坐标类型 |
| targetCity | string | 否 |  | 城市ID，例如：010=北京 |
| coordinates | array | 是 |  | 圆心坐标，格式为 [lng, lat, alt] |
| radius | number | 是 |  | 搜索半径（单位：米） |
| type | number | 是 | 0:综合查询; 1:餐饮服务; 2:购物服务; 3:体育休闲服务; 4:医疗保健服务; 5:住宿服务; 6:风景名胜; 7:商务住宅; 8:政府机构及社会团体; 9:科教文化服务; 10:交通设施服务; 11:金融保险服务 | POI分类类型 |
| customData | object | 否 |  | POI相关数据；customData 未定义时可自行根据回调数据添加POI |
| poiStyle.markerNormalUrl | string | 是 |  | 正常状态图片url地址，支持在线地址或本地地址 |
| poiStyle.markerActivateUrl | string | 是 |  | 激活状态图片url，由鼠标划过或点击触发 |
| poiStyle.markerSize | array | 是 |  | marker大小（宽, 高 单位：像素） |
| poiStyle.labelContent | array | 否 | ["文本内容", "ff0000ff", "50"] | 富文本；格式：["text", "color", "size"]，color为HEXA格式 |
| poiStyle.labelContentOffset | array | 否 | [5,5] | label内容偏移（x, y 单位：像素） |
| poiStyle.labelTop | boolean | 否 | true, false | label是否置于marker顶层 |
| visible2D.camera.hideDistance | number | 否 | 正整数 | 定义实体隐藏的距离（单位：米），相机超过此距离时实体会被隐藏 |
| visible2D.camera.hideType | string | 否 | none, default | 实体超出显示距离（none:不显示; default:圆圈显示） |
| visible2D.camera.scaleMode | string | 否 | 2D, 3D | 是否受相机的透视影响（2D:不影响; 3D:影响） |
| calculateCoordZ.coordZRef | string | 否 | surface, ground, altitude | surface:表面; ground:地面; altitude:海拔 |
| calculateCoordZ.coordZOffset | number | 否 |  | 高度（单位：米） |

**出参：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| success | boolean | 是否成功 |
| message | string | 错误信息 |
| result.poiObjects | array | POI覆盖物对象数组 |
| result.result.names | array | POI名称数组，与坐标数组一一对应 |
| result.result.coordinates | array | POI坐标数组，每项为 [lng, lat, alt] |

**示例：**

~~~javascript
const jsondata = {
  "coordType": "gcj02",
  "targetCity": "021", // 输入城市ID; [选填(例如:010=北京)]
  "coordinates": [121.46796508,31.23632859,46],
  "radius": 50, //半径(单位:米)
  "type":0, //0:综合查询; 1:餐饮服务; 2:购物服务; 3:体育休闲服务; 4:医疗保健服务; 5:住宿服务; 6:风景名胜; 7:商务住宅; 8:政府机构及社会团体; 9:科教文化服务; 10:交通设施服务; 11:金融保险服务

  "customData": { // 定义POI数据[选填]
    "poiStyle": {
      "markerNormalUrl": "https://wdpapi.51aes.com/doc-static/images/static/markerNormal.png",
      "markerActivateUrl": "https://wdpapi.51aes.com/doc-static/images/static/markerActive.png",
      "markerSize": [50,114],
      "labelContent": ["","76b2ffff","12"],
      "labelContentOffset": [25,-100], //label内容偏移(x,y 单位:像素)
      "labelTop": true //label是否置于marker顶层
    },
    "visible2D": { // [选填]
      "camera": {
        "hideDistance": 20000,//定义实体隐藏的距离(单位:米),相机超过此距离时,实体会被隐藏
        "hideType": "default", //实体超出显示距离(none:不显示; default:圆圈显示)
        "scaleMode": "2D" //是否受相机的透视影响(2D:不影响; 3D:影响)
      }
    },
    "calculateCoordZ": {  //[可选] 坐标类型及坐标高度; 最高优先级
      "coordZRef":"surface",//surface:表面; ground:地面; altitude:海拔
      "coordZOffset": 50 //高度(单位:米)
    }
  }

};

const { success, result } = await App.cim.InternetMapPoiByCircle(jsondata);
~~~