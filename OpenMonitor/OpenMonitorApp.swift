import SwiftUI
import AppKit
import Foundation

// Add required imports for memory monitoring
import Darwin
import IOKit

@main
struct OpenMonitorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

// 自定义视图类用于状态栏显示
class StatusBarView: NSView {
    // 网络速度
    var uploadSpeed: UInt64 = 0
    var downloadSpeed: UInt64 = 0
    
    // 系统资源使用率
    var memoryUsage: Double = 0
    var diskUsage: Double = 0
    
    // 颜色定义
    let uploadColor = NSColor.systemGreen
    let downloadColor = NSColor.systemBlue
    let memoryColor = NSColor.systemOrange
    let diskColor = NSColor.systemPurple
    
    // 字体定义
    let font = NSFont.monospacedDigitSystemFont(ofSize: 9, weight: .medium)
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    // 设置新数据并重绘
    func updateData(upload: UInt64, download: UInt64, memory: Double, disk: Double) {
        // 只有当数据发生变化时才重绘
        let dataChanged = uploadSpeed != upload || 
                          downloadSpeed != download || 
                          memoryUsage != memory || 
                          diskUsage != disk
        
        uploadSpeed = upload
        downloadSpeed = download
        memoryUsage = memory
        diskUsage = disk
        
        // 只有在数据变化时才需要重绘
        if dataChanged {
            needsDisplay = true
        }
    }
    
    override var intrinsicContentSize: NSSize {
        return NSSize(width: 60, height: 24)
    }
    
    override func layout() {
        super.layout()
        // 确保父视图(按钮)的尺寸与我们的视图保持一致
        if let button = superview as? NSButton {
            button.frame.size.width = 60
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // 准备绘制环境
        NSGraphicsContext.saveGraphicsState()
        
        // 获取当前上下文
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        // 清除背景
        context.clear(dirtyRect)
        
        // 计算实际绘制区域
        let drawingRect = bounds
        
        // 绘制上传速度
        drawUploadSpeed(in: drawingRect)
        
        // 绘制下载速度
        drawDownloadSpeed(in: drawingRect)
        
        // 绘制内存使用率
        drawMemoryUsage(in: drawingRect)
        
        // 绘制磁盘使用率
        drawDiskUsage(in: drawingRect)
        
        // 恢复绘制环境
        NSGraphicsContext.restoreGraphicsState()
    }
    
    // 绘制上传速度
    private func drawUploadSpeed(in rect: NSRect) {
        // 箭头和速度文本
        let arrowString = "↑" as NSString
        let speedString = formatSpeedSimple(uploadSpeed) as NSString
        
        // 设置绘制属性
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: uploadColor
        ]
        
        // 绘制位置 - 更紧凑的布局
        let arrowPoint = NSPoint(x: -8, y: rect.height - 12)
        let speedPoint = NSPoint(x: -5, y: rect.height - 12)
        
        // 绘制内容
        arrowString.draw(at: arrowPoint, withAttributes: attrs)
        speedString.draw(at: speedPoint, withAttributes: attrs)
    }
    
    // 绘制下载速度
    private func drawDownloadSpeed(in rect: NSRect) {
        // 箭头和速度文本
        let arrowString = "↓" as NSString
        let speedString = formatSpeedSimple(downloadSpeed) as NSString
        
        // 设置绘制属性
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: downloadColor
        ]
        
        // 绘制位置 - 更紧凑的布局
        let arrowPoint = NSPoint(x: -8, y: rect.height - 20)
        let speedPoint = NSPoint(x: -5, y: rect.height - 20)
        
        // 绘制内容
        arrowString.draw(at: arrowPoint, withAttributes: attrs)
        speedString.draw(at: speedPoint, withAttributes: attrs)
    }
    
    // 绘制内存使用率
    private func drawMemoryUsage(in rect: NSRect) {
        let labelString = "M" as NSString
        let valueString = String(format: "%d%%", Int(memoryUsage)) as NSString
        
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: memoryColor
        ]
        
        // 更紧凑的位置
        let labelPoint = NSPoint(x: 40, y: rect.height - 12)
        let valuePoint = NSPoint(x: 48, y: rect.height - 12)
        
        labelString.draw(at: labelPoint, withAttributes: attrs)
        valueString.draw(at: valuePoint, withAttributes: attrs)
    }
    
    // 绘制磁盘使用率
    private func drawDiskUsage(in rect: NSRect) {
        let labelString = "D" as NSString
        let valueString = String(format: "%d%%", Int(diskUsage)) as NSString
        
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: diskColor
        ]
        
        // 更紧凑的位置
        let labelPoint = NSPoint(x: 40, y: rect.height - 20)
        let valuePoint = NSPoint(x: 48, y: rect.height - 20)
        
        labelString.draw(at: labelPoint, withAttributes: attrs)
        valueString.draw(at: valuePoint, withAttributes: attrs)
    }
    
    // 简化的速度格式化
    private func formatSpeedSimple(_ bytes: UInt64) -> String {
        let kb = Double(bytes) / 1024.0
        if kb < 0.1 {
            return "    0KB"
        } else if kb < 1000 {
            return String(format: "%5.0fKB", kb)
        } else {
            let mb = kb / 1024.0
            return String(format: "%5.0fMB", mb)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var statusBarView: StatusBarView!
    var networkMonitor: OpenMonitor!
    var timer: Timer?
    var lastUpload: UInt64 = 0
    var lastDownload: UInt64 = 0
    
    // 保存之前的速度值作为备用
    var previousUploadSpeed: UInt64 = 0
    var previousDownloadSpeed: UInt64 = 0
    
    // 存储最近的速度值用于平滑显示
    var recentUploadSpeeds: [UInt64] = []
    var recentDownloadSpeeds: [UInt64] = []
    let maxHistoryCount = 3
    
    // 内存和磁盘使用率
    var memoryUsage: Double = 0
    var diskUsage: Double = 0
    
    // 状态栏宽度 - 更进一步减小宽度
    private let statusItemWidth: CGFloat = 60
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 初始化流量监控器
        networkMonitor = OpenMonitor()
        
        // 创建固定宽度的状态栏项，确保稳定性
        statusBarItem = NSStatusBar.system.statusItem(withLength: statusItemWidth)
        
        if let button = statusBarItem.button {
            // 配置按钮
            button.title = ""  // 清除默认标题
            button.alignment = .left
            
            // 创建自定义视图，确保其尺寸固定
            let buttonHeight = button.frame.height
            statusBarView = StatusBarView(frame: NSRect(x: 0, y: 0, width: statusItemWidth, height: buttonHeight))
            
            // 添加视图到按钮
            button.addSubview(statusBarView)
            
            // 设置按钮的关键属性
            button.imagePosition = .imageOnly
        }
        
        // 设置菜单
        setupMenu()
        
        // 开始监控
        startMonitoring()
    }
    
    func setupMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q"))
        statusBarItem.menu = menu
    }
    
    func startMonitoring() {
        // 初始值
        let (upload, download) = networkMonitor.getTrafficStats()
        lastUpload = upload
        lastDownload = download
        
        // 更新内存和磁盘使用率
        updateSystemStats()
        
        // 每秒更新一次
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateAllStats()
        }
        
        // 添加到RunLoop以获得更平滑的更新
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func updateAllStats() {
        // 更新网络状态
        updateNetworkStats()
        
        // 更新系统状态
        updateSystemStats()
    }
    
    func updateNetworkStats() {
        guard let (currentUpload, currentDownload) = try? networkMonitor.getTrafficStats() else {
            return
        }
        
        // 计算速度差值
        let uploadSpeed = currentUpload > lastUpload ? currentUpload - lastUpload : 0
        let downloadSpeed = currentDownload > lastDownload ? currentDownload - lastDownload : 0
        
        // 添加到最近速度数组中以进行平滑处理
        recentUploadSpeeds.append(uploadSpeed)
        recentDownloadSpeeds.append(downloadSpeed)
        
        // 保持数组长度
        if recentUploadSpeeds.count > maxHistoryCount {
            recentUploadSpeeds.removeFirst()
        }
        if recentDownloadSpeeds.count > maxHistoryCount {
            recentDownloadSpeeds.removeFirst()
        }
        
        // 计算平滑后的速度
        let smoothedUploadSpeed = calculateSmoothedSpeed(recentUploadSpeeds)
        let smoothedDownloadSpeed = calculateSmoothedSpeed(recentDownloadSpeeds)
        
        // 保存速度作为备用
        previousUploadSpeed = smoothedUploadSpeed
        previousDownloadSpeed = smoothedDownloadSpeed
        
        // 更新最后的值
        lastUpload = currentUpload
        lastDownload = currentDownload
        
        // 更新UI
        updateUI()
    }
    
    func calculateSmoothedSpeed(_ speeds: [UInt64]) -> UInt64 {
        if speeds.isEmpty {
            return 0
        }
        
        // 简单移动平均
        let sum = speeds.reduce(0, +)
        return UInt64(Double(sum) / Double(speeds.count))
    }
    
    func updateSystemStats() {
        // 获取内存使用率
        memoryUsage = getMemoryUsagePercentage()
        
        // 获取磁盘使用率
        diskUsage = getDiskUsagePercentage()
        
        // 更新UI
        updateUI()
    }
    
    func updateUI() {
        // 在主线程上更新UI
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 更新状态栏视图
            self.statusBarView.updateData(
                upload: self.previousUploadSpeed,
                download: self.previousDownloadSpeed,
                memory: self.memoryUsage,
                disk: self.diskUsage
            )
            
            // 确保视图的大小正确
            if let button = self.statusBarItem.button {
                // 重设按钮尺寸
                button.frame.size.width = self.statusItemWidth
                
                // 确保我们的自定义视图填满按钮
                self.statusBarView.frame = NSRect(
                    x: 0,
                    y: 0,
                    width: self.statusItemWidth,
                    height: button.frame.height
                )
                
                // 强制立即刷新显示
                self.statusBarView.display()
            }
        }
    }
    
    func getMemoryUsagePercentage() -> Double {
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        
        var pageSize: vm_size_t = 0
        let hostPort = mach_host_self()
        
        host_page_size(hostPort, &pageSize)
        
        var vmStats = vm_statistics64()
        var vmStatsSize = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.stride / MemoryLayout<Int32>.stride)
        
        let result = withUnsafeMutablePointer(to: &vmStats) { vmPointer in
            vmPointer.withMemoryRebound(to: Int32.self, capacity: Int(vmStatsSize)) { reboundPointer in
                host_statistics64(hostPort, HOST_VM_INFO64, reboundPointer, &vmStatsSize)
            }
        }
        
        if result != KERN_SUCCESS {
            return 50.0
        }
        
        let usedPages = vmStats.active_count + vmStats.wire_count
        let usedMemory = UInt64(usedPages) * UInt64(pageSize)
        
        let percentage = min(Double(usedMemory) / Double(totalMemory) * 100.0, 100.0)
        return max(percentage, 0.0)
    }
    
    func getDiskUsagePercentage() -> Double {
        do {
            let fileURL = URL(fileURLWithPath: NSHomeDirectory())
            let values = try fileURL.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey])
            
            if let totalCapacity = values.volumeTotalCapacity,
               let availableCapacity = values.volumeAvailableCapacity {
                let usedCapacity = totalCapacity - availableCapacity
                let percentage = Double(usedCapacity) / Double(totalCapacity) * 100.0
                return min(max(percentage, 0.0), 100.0)
            }
        } catch {
            print("获取磁盘信息时出错: \(error)")
        }
        
        return 50.0
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    // 清理资源
    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
    }
} 
