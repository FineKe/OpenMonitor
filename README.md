# OpenMonitor

![OpenMonitor](https://github.com/yourusername/OpenMonitor/raw/main/Resources/logo.png)

OpenMonitor是一个轻量级的macOS系统监控工具，可在状态栏中显示实时网络速度、内存和磁盘使用情况。

## 功能特点

- **网络监控**：实时显示上传和下载速度
- **系统资源监控**：显示内存和磁盘使用百分比
- **轻量高效**：占用极少系统资源
- **紧凑显示**：优化的状态栏设计，占用最小空间
- **平滑数据**：通过移动平均值计算提供更稳定的显示

## 截图

![状态栏截图](https://github.com/yourusername/OpenMonitor/raw/main/Resources/screenshot.png)

## 系统要求

- macOS 11.0 (Big Sur) 或更高版本
- 支持Apple Silicon和Intel处理器

## 安装

### 方法1：下载编译好的应用

1. 从[Releases](https://github.com/yourusername/OpenMonitor/releases)页面下载最新版本
2. 将OpenMonitor.app拖到Applications文件夹
3. 双击启动应用

### 方法2：从源码编译

1. 克隆仓库
   ```bash
   git clone https://github.com/yourusername/OpenMonitor.git
   cd OpenMonitor
   ```

2. 使用Xcode打开项目
   ```bash
   open OpenMonitor.xcodeproj
   ```

3. 在Xcode中构建和运行应用（⌘+R）

## 使用说明

### 启动应用

- 应用启动后会自动在状态栏显示监控数据
- 无需额外配置，即开即用

### 状态栏显示说明

- **↑**：当前上传速度 (KB/s或MB/s)
- **↓**：当前下载速度 (KB/s或MB/s)
- **M**：内存使用百分比
- **D**：磁盘使用百分比

### 退出应用

- 点击状态栏图标，选择"退出"选项

## 技术实现

OpenMonitor使用以下技术实现各项功能：

### 网络监控

- 通过`getifaddrs`API获取网络接口数据
- 监控en0（通常为Wi-Fi）和en1（通常为以太网）接口
- 使用移动平均算法平滑网络速度波动

### 内存监控

- 使用Darwin API中的`host_statistics64`获取内存使用情况
- 计算活跃和有线内存占总物理内存的百分比

### 磁盘监控

- 使用`volumeAvailableCapacity`和`volumeTotalCapacity`计算磁盘使用率
- 监控主目录所在的磁盘卷

### UI实现

- 使用自定义NSView绘制状态栏显示
- 直接使用Core Graphics实现高效绘制
- 采用固定坐标系统确保显示稳定性

## 项目结构

```
OpenMonitor/
├── OpenMonitor/              # 源代码目录
│   ├── OpenMonitorApp.swift  # 应用入口和UI代码
│   ├── OpenMonitor.swift     # 网络监控核心实现
│   ├── Info.plist            # 应用配置
│   └── Assets.xcassets       # 资源文件
└── OpenMonitor.xcodeproj/    # Xcode项目文件
```

## 贡献指南

欢迎贡献代码、报告问题或提出功能建议！

1. Fork 这个仓库
2. 创建您的特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交您的更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 开启一个Pull Request

## 许可证

本项目采用 MIT 许可证 - 详情见 [LICENSE](LICENSE) 文件

## 鸣谢

- 感谢所有开源社区的贡献者
- 图标设计：[设计师名称]
- 灵感来源：[相关项目]

---

Made with ❤️ 

*OpenMonitor - 简洁高效的系统监控工具* 