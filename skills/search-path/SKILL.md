---
name: search-path
description: >
  导航路径工具（App.InternetMapPath）。提供两点间导航路线创建、场景挂载、路径删除与自定义路径样式能力。当需要基于高德地图在两点之间创建导航路径、自定义路径样式或删除已有导航路径时，使用该工具。
metadata:
  version: 1.0.0
  tags: [cimapi, internet-map, navigation, path, scene]
---

# App.InternetMapPath - 搜索导航路径

> 本对象通过 new App.InternetMapPath(...) 创建后，使用 App.Scene.Add(...) 挂载到场景中生效。
> 需要提前设置高德地图key。

## 概述

App.InternetMapPath 提供以下能力：

- 创建两点之间的导航路线，提供三条导航路径
- 支持驾车、骑行、自行车、电动自行车等出行类型
- 支持通过 customData 配置路径样式与高亮颜色
- 支持删除已创建的导航路径
- 支持通过回调事件自定义注册路径样式

---

### 创建对象：new App.InternetMapPath(object)

**功能：** 创建导航路径对象，并可通过 App.Scene.Add 挂载到场景。

**入参：**

| 参数 | 类型 | 必填 | 取值范围 | 备注 |
| --- | --- | --- | --- | --- |
| coordType | string | 是 | wgs84, gcj02 | 坐标类型 |
| startCoord | string | 是 |  | 起点坐标经纬度 |
| endCoord | string | 是 |  | 终点坐标经纬度 |
| naviType | string | 是 |  | 导航类型(0:驾车; 1:骑行; 2:自行车; 3:电动自行车) |
| strategy | string | 是 |  | 出行策略, 仅针对驾车有效(0:高德推荐线路; 1:距离优先(仅返回一条); 2:速度最快; 3:躲避拥堵) |
| customData | object | 否 |  | 路径相关数据; customData 未定义时; 可自行注册事件回调函数并添加路径; |
| customData.highlightColor | string | 否 | HEXA,RGBA | 自定义执行SelectNavipath时路径高亮颜色; 默认:00ff7fff |
| customData.pathStyle.type | string | 否 | fit_solid(贴台地面), solid, arrow, arrow_dot, dashed_dot, arrow_dashed, railway | 路径样式类型 |
| customData.pathStyle.width | number | 否 | 正数 | 宽度, 单位米(在"adaptive_solid"中, 单位像素) |
| customData.pathStyle.color | string | 否 | HEXA,RGBA | 颜色 |
| customData.calculateCoordZ.coordZRef | string | 否 | surface, ground, altitude | surface:表面; ground:地面; altitude:海拔; 默认: altitude:海拔 |
| customData.calculateCoordZ.coordZOffset | number | 否 |  | 高度(单位:米); 默认: 20米 |

**出参：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| success | boolean | 是否成功 |
| message | string | 错误信息 |
| result.result | array | 导航路径数组，最多三条 |
| result.result[].duration | string | 预计行驶时间（单位：秒） |
| result.result[].distance | string | 路径总距离（单位：米） |
| result.result[].trafficlights | string | 途经红绿灯数量 |
| result.result[].coordinates | array | 路径坐标点数组，每项为 [lng, lat, alt] |
| result.result[].waypoints | string | 途经道路名称，分号分隔 |
| result.object | object | 路径实体对象 |
| result.pathObjects | object | 路径覆盖物对象 |
| result.poiObjects | object | POI覆盖物对象 |

**示例：**

~~~javascript
const entityObj = new App.InternetMapPath({
	"coordType": "gcj02",
	"startCoord": "121.48883000916418,31.251089484058205,10",
	"endCoord": "121.49043985828526,31.243971677466156,10",
	"naviType": "0",
	"strategy": "0",
	"customData": { //[可选] 定义路径数据；更多样式, 参考: WdpApi 实体覆盖物对象 --> 路径模块
		"highlightColor": "", //[选填] 执行SelectNavipath时路径高亮颜色; 默认: 00ff7fff
		"pathStyle": {
			"type": "solid",
			"width": 10,
			"color": "bcff70ff"
		},
		"calculateCoordZ": {
			"coordZRef": "altitude", //surface:表面; ground:地面; altitude:海拔
			"coordZOffset": 20 //高度(单位:米)
		}
	}
});

const { success, result } = await App.Scene.Add(entityObj);
cache.set('mappath', entityObj);
~~~

---

### 成员函数：Delete()

**功能：** 删除导航路径对象。

**入参：** 无

**出参：** 无

**示例：**

~~~javascript
await entityObj.Delete();
~~~

---

### 自定义导航路径样式

customData 未定义时; 可自行注册事件回调函数并添加路径; 或使用await App.Scene.Add(entityObj);回调的数据进行添加

~~~javascript
App.Renderer.RegisterSceneEvent([
	{
		name: 'OnNaviPathResult', func: async function ({ result }) {
			const naviPath = result.naviPathDetails || [];
			if (naviPath.length > 0) {
				for (let i = 0; i < naviPath.length; i++) {
					const pathObj = new App.Path({
						"polyline": {
							"coordinates": naviPath[i].coordinates
						},
						"pathStyle": {
							"type": "solid",
							"width": 10,
							"color": "bcff70ff"
						}
					});
					const { success } = await App.Scene.Add(pathObj, {
						"calculateCoordZ": {
							"coordZRef": "altitude", //surface:表面; ground:地面; altitude:海拔
							"coordZOffset": 20
						}
					});
				}
			}
		}
	}
]);
~~~
