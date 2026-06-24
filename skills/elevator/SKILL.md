---
name: elevator
description: 电梯管理模块。提供电梯对象创建、样式更新、显示隐藏、高度设置、高亮控制、window 显示控制与交互事件能力。当在 3D 场景中添加或更新电梯并配置其外观样式，控制电梯的升降运动、显隐状态和高亮效果，为电梯绑定信息弹窗，或需要监听电梯的鼠标交互事件时，使用该工具。

version: "1.0.0"
valid_until: "2026-12-24"
metadata:
  version: 1.0.0
  tags: [cimapi, hospital, elevator, scene, interaction]
---

# App.HimElevator - 电梯管理
> 本对象通过 new App.HimElevator(...) 创建后，使用 App.Scene.Add(...) 挂载到场景中生效。

## 概述

App.HimElevator 提供以下能力：

- 创建电梯对象并挂载到场景
- 配置井道样式与轿厢样式
- 绑定 window（链接、尺寸、偏移、初始状态）
- 更新电梯样式参数
- 控制电梯显示/隐藏
- 设置电梯目标高度与运动时间
- 控制电梯高亮
- 控制 window 显示/隐藏
- 监听移入、移出、选中、取消选中事件

---

### 创建对象 new App.HimElevator(object)

**功能：** 创建电梯对象，并通过 App.Scene.Add 挂载到场景。

**入参：**

| 参数 | 类型 | 必填 | 参数说明 |
| --- | --- | --- | --- |
| coord | array | 是 | 坐标点 lng,lat |
| elevatorShaft | object | 是 | 电梯井相关属性 |
| elevatorShaft.width | string | 是 | 电梯井宽度（单位米） |
| elevatorShaft.long | string | 是 | 电梯井进深（单位米） |
| elevatorShaft.color | string | 是 | 电梯井水晶体颜色 HEXA |
| elevatorShaft.luminous | string | 是 | 电梯井自发光强度（0-1） |
| elevator | object | 是 | 电梯相关属性 |
| elevator.color | string | 是 | 电梯井水晶体颜色 HEXA |
| elevator.luminous | string | 是 | 电梯水晶体状态自发光强度 |
| elevator.crystal | boolean | 是 | true: 水晶体模式；false: 实体模型模式 |
| window | object | 是 | window 相关属性 |
| window.url | string | 是 | window 链接 |
| window.size | array | 是 | [500,350]，window 长、宽（单位像素） |
| window.offset | array | 是 | [100,200]，window 左上角相对模型中心点偏移（单位像素） |
| window.displayOnly | boolean | 是 | true 同时只显示一个 window，展开一个自动关闭上一个 |
| window.initialState | string | 是 | window 初始状态，show 或 hide |

**示例：**

~~~javascript
const elevator = new App.HimElevator({
	coord: [119.95510673416909, 31.78151179696328, 0],
	elevatorShaft: {
		top_z: "110",
		width: "3",
		length: "4",
		crystalcolor: "ff4900ff",
		luminous: "0.2"
	},
	elevator: {
		color: "ff4900ff",
		luminous: "0.2",
		crystal: "true"
	},
	window: {
		url: "http://wdpapi.51aes.com/doc-static/images/static/echarts.html",
		size: [500, 350],
		offset: [0, 0],
		displayOnly: "true",
		initialState: "show"
	},
	rotator: { pitch: 0, yaw: 30, roll: 0 }
});

const res = await App.Scene.Add(elevator, {
	calculateCoordZ: {
		coordZRef: "surface",
		coordZOffset: 50
	}
});
~~~


---

### 衍生方法

#### 1. elevator.Update(object)

**功能：** 更新电梯样式参数。

**示例：**

~~~javascript
elevator.Update({
	elevatorShaft: {
		top_z: "110",
		width: "3",
		length: "4",
		crystalcolor: "ff4900ff",
		luminous: "0.2"
	},
	elevator: {
		color: "ff4900ff",
		luminous: "0.2",
		crystal: "true"
	},
	window: {
		url: "http://wdpapi.51aes.com/doc-static/images/static/echarts.html",
		size: [500, 350],
		offset: [0, 0],
		displayOnly: "true",
		initialState: "show"
	},
	rotator: { pitch: 0, yaw: 30, roll: 0 }
});
~~~

#### 2. elevator.SetVisible(object)

**功能：** 控制电梯显示/隐藏。

~~~javascript
elevator.SetVisible({
	visible: "true"
});
~~~

#### 3. elevator.SetHeight(object)

**功能：** 设置电梯目标高度与运动时间。

~~~javascript
elevator.SetHeight({
	height: "65",
	time: 3
});
~~~

#### 4. elevator.SetHighlight(object)

**功能：** 控制电梯高亮。

~~~javascript
elevator.SetHighlight({
	color: "ff00ff66",
	highlight: true
});
~~~

#### 5. elevator.SetWindowVisible(object)

**功能：** 控制 window 显示/隐藏。
~~~javascript
elevator.SetWindowVisible({
	visible: true,
	unique: true
});
~~~

---

### 交互事件

**功能：** 监听划入、划出、选中、取消选中事件。

**事件样例：**

~~~json
// 划入事件
{
	"type": 1,
	"event_name": "onElevatorHover",
	"args": {
		"eid": "-9151314259490715999"
	}
}

// 划出事件
{
	"type": 1,
	"event_name": "onElevatorUnhover",
	"args": {
		"eid": "-9151314259490715999"
	}
}

// 选中事件
{
	"type": 1,
	"event_name": "onElevatorClick",
	"args": {
		"eid": "-9151314259490715999"
	}
}

// 取消选中事件
{
	"type": 1,
	"event_name": "onElevatorUnclick",
	"args": {
		"eid": "-9151314259490715999"
	}
}
~~~


