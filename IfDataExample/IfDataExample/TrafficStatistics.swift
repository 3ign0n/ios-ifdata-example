//
//  TrafficStatistics.swift
//  IfDataExample
//
//  Created by 3ign0n on 2020/07/12.
//

import Foundation


struct TrafficStatistics {
    var sysUpTime = ProcessInfo().systemUptime
    var ifName: String
    var inOctets: UInt64
    var outOctets: UInt64
    var inPackets: UInt64
    var outPackets: UInt64
    var baudrate: UInt64
}

struct TrafficStatisticsManager {
    
    enum IfType {
        case wifi
        case wwan
        
        var ifNamePrefix: String {
            switch self {
            case .wifi:
                // en0〜en3が読み出せるがwifi用はen0のみ。将来、これが変更になる可能性はある。
                return "en0"
            case .wwan:
                return "pdp_ip"
            }
        }
    }
    
    static func retrieveStatistics() -> [TrafficStatistics] {
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        var statistics = [TrafficStatistics]()

        defer {
            freeifaddrs(ifaddr)
        }

        guard getifaddrs(&ifaddr) == 0 else { return statistics }
        
        var ptr = ifaddr
        while (ptr != nil) {
            guard let ifa_addr = ptr!.pointee.ifa_addr else {
                ptr = ptr!.pointee.ifa_next
                continue
            }
            guard ifa_addr.pointee.sa_family == AF_LINK else {
                let ifname = String(cString: ptr!.pointee.ifa_name)

                print("\(ifname): sa_family=\(ifa_addr.pointee.sa_family)")
                ptr = ptr!.pointee.ifa_next
                continue
            }

            let ifname = String(cString: ptr!.pointee.ifa_name)
            print("\(ifname): sa_family=\(ifa_addr.pointee.sa_family)")
            
            guard let ifa_data = ptr!.pointee.ifa_data else {
                print("ifa_data pointer is null")
                ptr = ptr!.pointee.ifa_next
                continue
            }
            
            if ifname.hasPrefix(IfType.wifi.ifNamePrefix) {
                let if_data_p = ifa_data.assumingMemoryBound(to: if_data.self)
                //let if_data = unsafeBitCast(ifa_data, to: UnsafeMutablePointer<if_data>.self)
                let trafficData = TrafficStatistics(ifName: ifname, inOctets: UInt64(if_data_p .pointee.ifi_ibytes), outOctets: UInt64(if_data_p.pointee.ifi_obytes), inPackets: UInt64(if_data_p.pointee.ifi_ipackets), outPackets: UInt64(if_data_p.pointee.ifi_opackets), baudrate: UInt64(if_data_p.pointee.ifi_baudrate))
                statistics.append(trafficData)
            } else if ifname.hasPrefix(IfType.wwan.ifNamePrefix) {
                // - note: compiler warns:
                // 'unsafeBitCast' from 'UnsafeMutableRawPointer' to 'UnsafeMutablePointer<if_data>' gives a type to a raw pointer and may lead to undefined behavior
                // Use the 'assumingMemoryBound' method if the pointer is known to point to an existing value or array of type 'if_data' in memory
                let if_data = unsafeBitCast(ifa_data, to: UnsafeMutablePointer<if_data>.self)
                let trafficData = TrafficStatistics(ifName: ifname, inOctets: UInt64(if_data.pointee.ifi_ibytes), outOctets: UInt64(if_data.pointee.ifi_obytes), inPackets: UInt64(if_data.pointee.ifi_ipackets), outPackets: UInt64(if_data.pointee.ifi_opackets), baudrate: UInt64(if_data.pointee.ifi_baudrate))
                statistics.append(trafficData)
            }
        
            ptr = ptr!.pointee.ifa_next
        }
        
        print(String(describing: statistics))
        
        return statistics
    }
}
