---
name: device
description: >
  附属设备管理工具（App.HimAttachedDevice）。提供附属设备模板创建、附属设备管理、删除附属设备、删除模板与获取附属设备列表能力。当需要为主模型创建可复用的附属设备模板、将模板中的附属设备批量应用到其他模型对象，或删除指定模型的附属设备或清理模板的场景时，使用该工具。

metadata:
  version: 1.4.0
  tags: [cimapi, hospital, attached-device, management, scene]
---

# 附属设备管理

## 概述

- 创建模板
- 附属设备管理
- 删除附属设备
- 删除模板
- 获取附属设备列表

---

### 创建模板：new App.HimAttachedDevice(object)

**功能：** 创建一个通用模板，用以将通用的摆放方式复制到其他模型对象上

**入参：**

| 参数 | 类型 | 必填 | 参数说明 |
| --- | --- | --- | --- |
| eidOfParentModel | object | 是 | 主模型对象 |
| Childs | array | 是 | 附属模型信息 |
| Childs.childName | string | 是 | 附属模型命名，可自定义 |
| Childs.location | string | 是 | 附属模型相对主模型的位置 |
| Childs.rotator | object | 是 | 附属模型相对主模型的转角 |
| Childs.rotator.pitch | string | 是 | 附属模型相对主模型的转角-仰俯角 |
| Childs.rotator.yaw | string | 是 | 附属模型相对主模型的转角-偏航角 |
| Childs.rotator.roll | string | 是 | 附属模型相对主模型的转角-滚动角 |
| scale3d | object | 是 | 附属模型的缩放倍数 |
| seedId | string | 是 | 附属模型的seedid daas中获取 |

**示例：**

~~~javascript
const Template = new App.HimAttachedDevice({
	"attachedEid":"-9151314258980702150", //主模型的对象/eid
	"devices":[
		{
			"name":"m1",
			"location": [3, 0, 0], //相对于主模型的位置
			"rotator": [0,0,0],
			"scale": [1, 1, 1],
			"show": true,
			"seedId": "9e96ab6d7874cd770780393d4ed73a7", //从Daas中获取
		},
		{
			"name":"m2",
			"location": [0, 3, 0], //相对于主模型的位置
			"rotator": [0,30,0],
			"scale": [1, 1, 1],
			"show": true,
			"seedId": "dcefe9fcf9161de62cbf55eee9f6400d", //从Daas中获取
		}
	]
});

const res = await App.Scene.Add(Template);
console.log(res);
~~~

---

### 衍生方法

#### 1.Create(object)

**功能：** 创建附属设备模板的实例，用以将模板中的附属设备状态应用到其他模型对象上

**示例：**

~~~javascript
Template.Create([
	{
		attachedEid: "-9151314259056988129", //主模型EID
		attachedDevicelist: [
			{ name: 'm1', show: false }, //附属模型状态
			{ name: 'm2', show: true }
		]
	},
	{
		attachedEid: "-9151314259056988129",
		attachedDevicelist: [
			{ name: 'm1', show: false }, //附属模型状态
			{ name: 'm2', show: true }
		]
	}
])
~~~

#### 2.managementChildsModel(object)

**功能：** 用于删除附属设备

**示例：**

~~~javascript
Template.managementChildsModel({
	Template:["-9151314259056988129", "-9151314259056988128" ] //通过主模型eid删除它的附属设备，甚至可删除该模板下所有的附属设备
})
~~~

#### 3.Delete()

**功能：** 删除附属设备模板

**示例：**

~~~javascript
Template.Delete()
~~~

#### 4.GetAll()

**功能：** 获取所有附属设备模板的eid列表

**示例：**

~~~javascript
Template.GetAll()
~~~


