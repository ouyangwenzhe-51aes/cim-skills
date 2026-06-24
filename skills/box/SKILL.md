---
name: box
description: >
 空间管理工具（App.HimRoomBox）。提供通过 geojson 加载 room 色块、色块控制、聚焦与查询能力。当需要通过 geojson 数据在场景中加载房间色块时；需要控制房间色块的颜色、高亮、显隐状态时；需要聚焦到指定房间或获取房间中心点坐标时；需要获取房间列表或监听房间的鼠标交互事件时，使用该工具。

version: "1.0.0"
valid_until: "2026-12-24"
metadata:
  version: 1.0.0
  tags: [cimapi, hospital, room-box, scene, interaction]
---

# App.HimRoomBox - 空间管理

> 本对象通过 new App.HimRoomBox(...) 创建后，使用 App.Scene.Add(...) 挂载到场景中生效。

## 概述

App.HimRoomBox 提供以下能力：

- 通过 geojson 加载 room 色块
- 色块的颜色控制
- 设置色块高亮效果
- 显示/隐藏房间色块
- 聚焦色块
- 获取色块中心点坐标
- 获取房间列表
- 响应房间交互事件

---

### 创建对象：new App.HimRoomBox(object)

**功能：** 通过 geojson 加载 room 色块。

**入参：**

| 参数 | 类型 | 必填 | 参数说明 |
| --- | --- | --- | --- |
| spaceInfoUrl | string | 是 | 空间信息路径 |
| units | string | 是 | 单位: cm / m |
| visible | boolen | 是 | 默认的显示/隐藏状态 |
| location | array | 是 | 楼层中心点坐标 |
| scale3d | array | 是 | 缩放 |
| rotator | array | 是 | 旋转 |

**示例：**

~~~javascript
const F1 = new App.HimRoomBox({
  "visible": true, //默认显示隐藏状态
  "units": "cm", //单位
  "spaceInfoUrl": "http://47.108.200.15:8089/F2A2.geojson", //geojson地址
  "scale3d": [ //缩放
	1,
	1,
	1
  ],
  "rotator": { //旋转
	"pitch": 0,
	"roll": 0,
	"yaw": 0
  },
  "location": [ //楼层中心点坐标
	119.9555328148281,
	31.783464076386817,
	0
  ]
})

App.Scene.Add(F1, {
  calculateCoordZ: {
	coordZRef: "surface", //surface:表面;ground:地面;altitude:海拔
	coordZOffset: 0 //高度(单位:米);
  }
})
~~~

geojson内容参考

~~~javascript
//参考文件: http://47.108.200.15:8089/AF1.geojson
//预定义属性:
"properties": {
  "fid": 1286, //房间ID
  "spaceCode": "CZSD1-A6-F2-R1", //房间属性, 可选
  "basecolor": "00FF00FF", //默认颜色, 可选
  "highlightcolor": "FF0000FF", //高亮颜色, 可选
  "center": [ //中心点坐标, 可选, 如果等于, 则选择几何中心点作为房间中心点
	-115084.968678619115963,
	25831.596011279569211,
	0.0
  ]
}
~~~

---

### 成员函数：SetRoomBoxColor(roomId: string, visible: boolean)

**功能：** 设置色块的颜色。

**入参：**

~~~javascript
SetRoomBoxColor(roomId: string, visible: boolean)
~~~

**示例：**

~~~javascript
SetRoomBoxColor(roomId: string, visible: boolean) //设置色块的颜色
//示例
F1.SetRoomBoxColor("1286", "FF00FF")
~~~

### 成员函数：SetHighlight(roomId: string, visible: boolean)

**功能：** 设置色块的高亮颜色。

**入参：**

~~~javascript
SetHighlight(roomId: string, visible: boolean)
~~~

**示例：**

~~~javascript
SetHighlight(roomId: string, visible: boolean) //设置色块的高亮颜色
//示例
F1.SetHighlight("1286", "FF00FF")
~~~

### 成员函数：SetRoomBoxVisible(roomId: string, visible: boolean)

**功能：** 显示/隐藏所有色块。

**入参：**

~~~javascript
SetRoomBoxVisible(roomId: string, visible: boolean)
~~~

**示例：**

~~~javascript
SetRoomBoxVisible(roomId: string, visible: boolean) //显示/隐藏所有色块
F1.SetRoomBoxVisible("1286", false) //示例
~~~

### 成员函数：SetRoomBoxFocus(roomId: string, json)

**功能：** 聚焦色块。

**入参：**

~~~javascript
SetRoomBoxFocus(roomId: string, json = {
	distance: 100,
	flyTime: 0,
	rotation: { pitch: -30, yaw: 0 },
})
~~~

**示例：**

~~~javascript
SetRoomBoxFocus(roomId: string, json = {
  distance: 100, //距离(单位:米)
  flyTime: 0, //飞行时间(单位:秒)
  rotation: { pitch: -30, yaw: 0 },
})
//示例
F1.SetRoomBoxFocus("1286", {
  distance: 100, //距离(单位:米)
  flyTime: 0, //飞行时间(单位:秒)
  rotation: { pitch: -30, yaw: 0 },
})
~~~

### 成员函数：GetRoomBoxLocation(roomId: string)

**功能：** 获取色块中心点坐标。

**入参：**

~~~javascript
GetRoomBoxLocation(roomId: string)
~~~

**出参：**

~~~json
{
  "type": 0,
  "guid": "ee807a20-b4b2-11f0-ae6d-0f544291500e",
  "success": true,
  "result": {
	"center": [
	  119.954575883946627,
	  31.784122373081662,
	  0.02011726793945312
	]
  },
  "message": ""
}
~~~

**示例：**

~~~javascript
GetRoomBoxLocation(roomId: string)
//示例:
F1.GetRoomBoxLocation("1286")
~~~

### 成员函数：GetRoomBoxList()

**功能：** 获取房间列表。

**入参：**

~~~javascript
GetRoomBoxList()
~~~

**出参：**

~~~json
{
	"type": 0,
	"guid": "3aea0900-b4b2-11f0-ae6d-0f544291500e",
	"success": true,
	"result": {
		"roomInfo": [
			{
				"roomId": "1286",
				"spaceCode": "CZSD1-A6-F2-R1",
				"baseColor": {
					"r": 0,
					"g": 0.00030352699104696512,
					"b": 0,
					"a": 1
				},
				"highlightColor": {
					"r": 1,
					"g": 0,
					"b": 0,
					"a": 0
				},
				"visible": true
			},
			{
				"roomId": "1287",
				"spaceCode": "CZSD1-A6-F2-R2",
				"baseColor": {
					"r": 1,
					"g": 1,
					"b": 0,
					"a": 1
				},
				"highlightColor": {
					"r": 1,
					"g": 0,
					"b": 0,
					"a": 1
				},
				"visible": true
			},
			{
				"roomId": "1288",
				"spaceCode": "CZSD1-A6-F2-R3",
				"baseColor": {
					"r": 1,
					"g": 1,
					"b": 0,
					"a": 1
				},
				"highlightColor": {
					"r": 1,
					"g": 0,
					"b": 0,
					"a": 1
				},
				"visible": true
			},
			{
				"roomId": "1289",
				"spaceCode": "CZSD1-A6-F2-R4",
				"baseColor": {
					"r": 1,
					"g": 1,
					"b": 0,
					"a": 1
				},
				"highlightColor": {
					"r": 1,
					"g": 0,
					"b": 0,
					"a": 1
				},
				"visible": true
			},
			{
				"roomId": "1290",
				"spaceCode": "CZSD1-A6-F2-R5",
				"baseColor": {
					"r": 1,
					"g": 1,
					"b": 0,
					"a": 1
				},
				"highlightColor": {
					"r": 1,
					"g": 0,
					"b": 0,
					"a": 1
				},
				"visible": true
			},
			{
				"roomId": "1291",
				"spaceCode": "CZSD1-A6-F2-R6",
				"baseColor": {
					"r": 1,
					"g": 1,
					"b": 0,
					"a": 1
				},
				"highlightColor": {
					"r": 1,
					"g": 0,
					"b": 0,
					"a": 1
				},
				"visible": true
			},
			{
				"roomId": "1292",
				"spaceCode": "CZSD1-A6-F2-R7",
				"baseColor": {
					"r": 1,
					"g": 1,
					"b": 0,
					"a": 1
				},
				"highlightColor": {
					"r": 1,
					"g": 0,
					"b": 0,
					"a": 1
				},
				"visible": true
			},
			{
				"roomId": "1293",
				"spaceCode": "CZSD1-A6-F2-R8",
				"baseColor": {
					"r": 1,
					"g": 1,
					"b": 0,
					"a": 1
				},
				"highlightColor": {
					"r": 1,
					"g": 0,
					"b": 0,
					"a": 1
				},
				"visible": true
			},
			{
				"roomId": "1294",
				"spaceCode": "CZSD1-A6-F2-R9",
				"baseColor": {
					"r": 1,
					"g": 1,
					"b": 0,
					"a": 1
				},
				"highlightColor": {
					"r": 1,
					"g": 0,
					"b": 0,
					"a": 1
				},
				"visible": true
			},
			{
				"roomId": "1295",
				"spaceCode": "CZSD1-A6-F2-R10",
				"baseColor": {
					"r": 1,
					"g": 1,
					"b": 0,
					"a": 1
				},
				"highlightColor": {
					"r": 1,
					"g": 0,
					"b": 0,
					"a": 1
				},
				"visible": true
			}
		]
	},
	"message": ""
}
~~~

**示例：**

~~~javascript
GetRoomBoxList()
//示例:
F1.GetRoomBoxList()
~~~

---

### 交互事件

~~~json
//房间划入事件
{"type":1,"event_name":"onRoomBoxHover","args":{"fid":"229"}}
//房间划出事件
{"type":1,"event_name":"onRoomBoxHover","args":{"fid":"229"}}
//房间选中事件
{"type":1,"event_name":"onRoomBoxClick","args":{"fid":"214"}}
//房间取消选中事件
{"type":1,"event_name":"onRoomBoxUnclick","args":{"fid":"214"}}
~~~


