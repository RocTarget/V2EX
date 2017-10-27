# V2EX


## 介绍

一款针对 iOS 设备的 V2EX 客户端，苦于在 iPhone 上一直没有一款称得上 **好用的** V2EX 客户端，于是有了这个项目，如果你有任何意见欢迎打开 Issue 或 PR，感谢 😊


## 截图

<img src="https://github.com/Joe0708/V2EX/raw/master/Screenshot/home.png" width="210"><img src="https://github.com/Joe0708/V2EX/raw/master/Screenshot/node.png" width="210"> <img src="https://github.com/Joe0708/V2EX/raw/master/Screenshot/more.png" width="210"><img src="https://github.com/Joe0708/V2EX/raw/master/Screenshot/login.png" width="210">


## 功能

### 首页
1. 主题数据展示
2. 主题搜索（按权重 or 时间排序）

### 主题详情
1. 只看楼主
2. 复制链接、Safari打开、系统分享
3. 主题(主题回复) 收藏、感谢、忽略 操作
4. 查看对话
5. 主题回复，支持贴图，@单个或多个用户
6. 回复列表如果是图片链接直接解析成图片

### 节点
1. 导航节点、所有节点
2. 节点搜索

### 消息
1. 查看所有消息
2. 消息提醒
3. 删除消息
4. 快捷回复

### 更多
1. 创作新主题
2. 查看我的
     - 节点收藏
     - 主题收藏
     - 我的主题
     - 我的回复

## 要求

- iOS 9.0
- Swift Version 4.0
- Xcode 9.0 or later


## 运行

1. 克隆项目

```
git clone https://github.com/Joe0708/V2EX.git
```

2. 在项目根目录安装依赖库

```
 pod install 
```
3. 打开 `V2EX.xcworkspace` 运行


## TODO

### 首页
1. [x] 站内搜索(感谢 [SOV2EX](https://github.com/bynil/sov2ex/blob/master/API.md) 提供 API)

### 主题
1. [x] 主题回复
2. [x] 社交分享
3. [x] 查看对话
4. [x] @用户，支持@多个用户
5. [x] @用户时的文本处理（高亮、删除时如果是@直接删除整个字符串）
6. [x] 主题评论支持上传图片直接发送
8. [ ] 在查看对话视图中直接进行回复
9. [ ] 回复倒叙查看

### 节点
1. [x] 节点搜索
2. [ ] 节点详情中直接收藏节点
3. [ ] 节点详情中直接发布主题

### 消息
1. [x] 消息通知
2. [x] 删除消息
3. [x] 直接在消息列表进行快捷回复

### 更多
1. [x] 发布新主题
2. [ ] 将图片上传至图传(发布新主题时使用, 感谢 [SM.MS](https://sm.ms/doc/) 提供 API)
3. [ ] 夜间模式
4. [ ] 修改头像
5. [ ] 修改个人资料

### 其他优化
1. [ ] 注册（因验证限制，暂时不做）
2. [ ] 数据持久化，缓存
3. [ ] 适配 iPad
...


## 声明

此项目仅供学习实习，轻忽用于其他任何恶意用途，如果侵犯到您的权益，请联系我删除 joesir@foxmail.com

## License

V2EX is available under the MIT license. See the [LICENSE file](https://github.com/Joe0708/V2EX/blob/master/LICENSE) for more info.
