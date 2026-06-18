---
name: bypolygon
description: >
  POI多边形搜索工具（App.cim.InternetMapPoiByPolygon）。根据多边形范围搜索POI点位，并支持自定义样式挂载到场景。当需要以多边形区域为范围搜索周边POI点位、按分类筛选结果并配置POI样式挂载到场景时，使用该工具。
version: "1.0.0"
valid_until: "2026-12-18"
metadata:
  version: 1.0.0
  tags: [cimapi, internet-map, poi, polygon, search, scene]
---

# App.cim.InternetMapPoiByPolygon - POI搜索："多边形"搜索

## 概述

App.cim.InternetMapPoiByPolygon 提供以下能力：

- 根据多边形坐标范围搜索指定城市的POI点位
- 支持按POI分类类型过滤搜索结果
- 支持通过 customData.poiStyle 配置 marker 样式与标签内容
- 支持通过 customData.visible2D 配置相机距离显隐规则
- 支持通过 customData.calculateCoordZ 配置坐标高度
- 支持 customData 未定义时通过回调事件自行添加 POI

---

### App.cim.InternetMapPoiByPolygon(jsondata)

**功能：** 根据多边形范围搜索 POI，并可通过 customData 自动挂载到场景。

**入参：**

| 参数 | 类型 | 必填 | 取值范围 | 备注 |
| --- | --- | --- | --- | --- |
| coordType | string | 是 | wgs84, gcj02 | 坐标类型 |
| targetCity | string | 否 |  | 城市ID, 若需要限定搜索范围则需要填写, 比如:"北京" |
| coordinates | array | 是 |  | 多边形范围坐标数组，每项为 [lng, lat, alt] |
| type | number | 是 | 0:综合查询; 1:餐饮服务; 2:购物服务; 3:体育休闲服务; 4:医疗保健服务; 5:住宿服务; 6:风景名胜; 7:商务住宅; 8:政府机构及社会团体; 9:科教文化服务; 10:交通设施服务; 11:金融保险服务 | POI分类类型 |
| customData | object | 否 |  | poi相关数据; customData 未定义时; 可自行根据回调数据添加poi; |
| poiStyle.markerNormalUrl | string | 是 |  | 正常状态,图片url地址,支持2种形式: 在线地址如"http://..."; 本地地址如"file:///D:/xxx/markerNormal.png" |
| poiStyle.markerActivateUrl | string | 是 |  | 激活状态,由鼠标划过或点击触发 |
| poiStyle.markerSize | string | 是 |  | marker大小(宽,高 单位:像素) |
| poiStyle.labelContent | array | 否 | ["文本内容", "ff0000ff", "50"] | 富文本; 格式: ["text", "color", "size"] color: HEXA格式 |
| poiStyle.labelContentOffset | array | 否 | [5,5] | label内容相对于label左上角偏移(x,y 单位:像素); 注: x为正向右, y为正向下 |
| poiStyle.labelTop | boolean | 否 | true, false | label是否置于marker顶层 |
| bVisible | boolean | 否 |  | 是否可见(true/false) |
| visible2D.camera.hideDistance | number | 否 | 正整数 | 定义实体隐藏的距离(单位:米),相机超过此距离时,实体会被隐藏 |
| visible2D.camera.hideType | string | 否 | none, default | 实体超出显示距离(none:不显示; default:圆圈显示) |
| visible2D.camera.scaleMode | string | 否 | 2D, 3D | 是否受相机的透视影响(2D:不影响; 3D:影响) |
| calculateCoordZ.coordZRef | string | 否 | surface, ground, altitude | surface:表面; ground:地面; altitude:海拔 |
| calculateCoordZ.coordZOffset | number | 否 |  | 高度(单位:米) |

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
  "coordinates": [
     [121.49572566,31.2394154,69],
     [121.47284211,31.23560092,19],
     [121.48849478,31.23736623,33]
  ],
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

const { success, result } = await App.cim.InternetMapPoiByPolygon(jsondata);


customData 未定义时; 可自行使用回调数据添加POI; 或使用await App.cim.InternetMapPoiByPolygon(jsondata);回调的数据添加;

​App.Renderer.RegisterSceneEvent([
    {
        name: 'OnSearchPointByPolygonResult', func: async function ({ result }) {
            const searchCoord = result?.coordinates || [];
            const searchNames = result?.names || [];
            let __poi = [];
            if (searchCoord.length > 0) {
                for (const key in searchCoord) {
                    const poi = new App.Poi({
                        "location": searchCoord[key],
                        "poiStyle": {
                            "markerNormalUrl": "http://wdpapi.51aes.com/doc-static/images/static/markerNormal.png",
                            "markerActivateUrl": "http://wdpapi.51aes.com/doc-static/images/static/markerActive.png",
                            "markerSize": [50, 114],
                            "labelBgImageUrl": "",
                            "labelBgSize": [1, 1],
                            "labelBgOffset": [0, 0], //x>0,y>0 向右、上偏移(x,y 单位:像素)
                            "labelContent": [searchNames[key], "8e99feff", "12"],
                            "labelContentOffset": [25, -100], //x>0,y>0 label内容 向右、下偏移(x,y 单位:像素)
                            "labelTop": true //label是否置于marker顶层
                        },
                        "visible2D": {
                            "camera": {
                                "hideDistance": 50000,  //定义实体隐藏的距离(单位:米),相机超过此距离时,实体会被隐藏
                                "hideType": "default", //实体超出显示距离(none:不显示; default:圆圈显示)
                                "scaleMode": "2D" //是否受相机的透视影响(2D:不影响; 3D:影响)
                            }
                        }
                    })
                    __poi.push(poi)
                }

                await App.Scene.Add(__poi, {
                    calculateCoordZ: {
                        coordZRef: "ground", //surface:表面;ground:地面;altitude:海拔
                        coordZOffset: 10 //高度(单位:米)
                    }
                })
            }
        }
    }
]);
~~~