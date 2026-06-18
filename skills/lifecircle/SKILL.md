---
name: lifecircle
description: >
  N分钟生活圈能力（App.cim.InternetMapLifeCircle）。用于按时间与出行方式计算生活圈范围。在需要基于中心点坐标和出行条件（时间、方式）计算可达范围并可视化展示时，使用该工具。
version: "1.0.0"
valid_until: "2026-12-18"
metadata:
  version: 1.0.0
  tags: [cimapi, internet-map, life-circle, range]
---

# N分钟生活圈

> 调用 `App.cim.InternetMapLifeCircle(jsondata)`，根据中心点、出行时间和出行方式返回生活圈范围数据。

## 概述

App.cim.InternetMapLifeCircle 提供以下能力：

- 基于中心点坐标计算 N 分钟生活圈范围
- 支持按出行时间与出行方式计算范围
- 支持通过 customData.rangeStyle 配置围栏样式
- 支持使用回调数据创建并添加范围区域


### 计算N分钟生活圈范围：App.cim.InternetMapLifeCircle(jsondata)

**功能：**

计算 N 分钟生活圈范围；可通过 `customData.rangeStyle` 指定围栏样式。

**入参：**

| 参数 | 类型 | 必填 | 取值范围 | 备注 |
| --- | --- | --- | --- | --- |
| coordType | string | 是 |  | 场景坐标类型(wgs84,gcj02) |
| targetCity | array | 是 |  | 城市ID, 若需要限定搜索范围则需要填写,比如:"北京" |
| coordinates | array | 是 |  | 中心点坐标经纬度 |
| time | number | 是 |  | 预计出行时间范围(单位:分钟) |
| type | string | 是 |  | 出行方式(0:汽车,1:步行,2:自行车,3:电瓶车) |
| customData | object | 否 |  | range相关数据; customData 未定义时; 可自行根据回调数据添加range; |
| rangeStyle.type | string | 是 | wave, loop_line, grid, stripe, bias | 围栏样式 |
| rangeStyle.fillAreaType | string | 是 | solid, block, block2, dot, dot2, dot3, dash_line, radar | 封底样式 |
| rangeStyle.height | number | 是 | 正数 | 围栏高度,单位米 |
| rangeStyle.strokeWeight | number | 是 | 正数 | 封底轮廓线宽度,单位米 |
| rangeStyle.color | string | 是 | HEXA,RGBA | 整体颜色 |

**出参：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| success | boolean | 是否成功 |
| message | string | 错误信息 |
| result | object | 计算结果 |

**示例：**

~~~javascript
const jsondata = {
	"coordType": "gcj02", // 坐标类型(wgs84/gcj02)
	"targetCity": "021", // 城市ID; [选填(例如:010=北京)]
	"coordinates": [121.47401451,31.240983,37],
	"time": 50, // 预计出行时间范围(单位:分钟)
	"type": 0, //出行类型：0:汽车; 1:步行; 2:自行车; 3:电瓶车
	"customData": {
		"rangeStyle": {
			"type": "loop_line", //类型
			"fillAreaType": "block", //底部区域填充类型
			"height": 200, //围栏高度(单位:米)
			"strokeWeight": 10, //底部轮廓线宽度(单位:米; 注：区域中含有内环"innerLoops"时无效)
			"color": "2097ffff" //HEXA或rgba(0,0,0,0.8)
		},
		"calculateCoordZ": { // [可选] 坐标类型及坐标高程；最高优先级
			"coordZRef": "ground", //surface:表面; ground:地面; altitude:海拔
			"coordZOffset": 10 //高度(单位:米)
		}
	}
};

await App.cim.InternetMapLifeCircle(jsondata);

customData 未定义时; 可自行使用回调数据添加区域; 或使用await App.cim.InternetMapLifeCircle(jsondata);回调的数据添加;

App.Renderer.RegisterSceneEvent([
	{
		name: 'OnArrivalRangeResult', func: async function ({ result }) {
			console.error(result)
			const searchCoord = result?.coordinates || [];
			if (searchCoord.length > 0){
				const range = new App.Range({
					"polygon2D": {
						"coordinates": [searchCoord]
					},
					"rangeStyle": {
						"type": "loop_line", //类型
						"fillAreaType": "block", //底部区域填充类型
						"height": 200, //围栏高度(单位:米)
						"strokeWeight": 10, //底部轮廓线宽度(单位:米; 注：区域中含有内环"innerLoops"时无效)
						"color": '099cffff' //HEXA或rgba(0,0,0,0.8)
					},
				})
				await App.Scene.Add(range, {
					calculateCoordZ: {
						coordZRef: "ground", //surface:表面;ground:地面;altitude:海拔
						coordZOffset: 0 //高度(单位:米)
					}
				})
			}
		}
	}]);
~~~
