import Foundation
import SystemConfiguration

class OpenMonitor {
    // 要监控的网络接口名称
    private let interfacesToMonitor = ["en0", "en1"]
    
    /// 获取所有监控接口的当前上传和下载流量
    func getTrafficStats() -> (UInt64, UInt64) {
        var totalUpload: UInt64 = 0
        var totalDownload: UInt64 = 0
        
        for interface in interfacesToMonitor {
            if let stats = getStatsForInterface(interface) {
                totalUpload += stats.0
                totalDownload += stats.1
            }
        }
        
        return (totalUpload, totalDownload)
    }
    
    /// 获取特定接口的网络统计数据
    private func getStatsForInterface(_ interfaceName: String) -> (UInt64, UInt64)? {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        defer { freeifaddrs(ifaddr) }
        
        var uploadBytes: UInt64 = 0
        var downloadBytes: UInt64 = 0
        
        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }
            
            let interface = ptr?.pointee
            let name = String(cString: (interface?.ifa_name)!)
            
            if name == interfaceName {
                if let data = interface?.ifa_data {
                    let networkData = data.assumingMemoryBound(to: if_data.self)
                    
                    // 获取上传字节(obytes)和下载字节(ibytes)
                    uploadBytes = UInt64(networkData.pointee.ifi_obytes)
                    downloadBytes = UInt64(networkData.pointee.ifi_ibytes)
                    break
                }
            }
        }
        
        return (uploadBytes, downloadBytes)
    }
} 