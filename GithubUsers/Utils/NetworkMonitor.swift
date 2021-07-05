//
//  NetwrokMonitor.swift
//  GithubUsers
//
//  Created by Manpreet on 05/07/2021.
//

import Foundation
import SystemConfiguration

class NetworkMonitor {
    private var monitoringTimer: Timer?
    private var lastConnectionStatus: Bool = false
    
    // MARK: - Monitoring
    
    public func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        if flags.isEmpty {
            return false
        }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)

        return (isReachable && !needsConnection)
    }
    
    public func startMonitoringNetworkConnection() {
        self.lastConnectionStatus = self.isConnectedToNetwork()
        self.monitoringTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true) {
            timer in
            
            let newConnectionStatus = self.isConnectedToNetwork()
            if newConnectionStatus != self.lastConnectionStatus {
                self.lastConnectionStatus = newConnectionStatus
                
                let notificationCenter: NotificationCenter = .default
                notificationCenter.post(name: .networkConnectionChanged,
                                        object: self.lastConnectionStatus)
            }
          }
    }
    
    public func stopMonitoringNetworkConnection() {
        if let timer = self.monitoringTimer {
            timer.invalidate()
            self.monitoringTimer = nil
        }
    }
}
