//
//  NetStatus.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/12.
//

import Foundation
import Network

// https://www.appcoda.com.tw/network-framework/
// 網路連線狀態
final class NetStatus {
    // MARK: Lifecycle

    private init() {}

    deinit {
        stopMonitoring()
    }

    // MARK: Internal

    static let shared = NetStatus()

    /// 開始監控網路變化
    var didStartMonitoringHandler: (() -> Void)?

    /// 停止監控網路變化
    var didStopMonitoringHandler: (() -> Void)?

    /// 網路狀態出現變更
    var netStatusChangeHandler: (() -> Void)?

    /// 是否連線到網路介面
    var isConnected: Bool {
        guard let monitor = monitor else { return false }
        return monitor.currentPath.status == .satisfied
    }

    /// 目前的網路介面類型(無線網路、行動網路、乙太網路)
    var interfaceType: NWInterface.InterfaceType? {
        guard let monitor = monitor else { return nil }

        return monitor.currentPath.availableInterfaces.filter {
            monitor.currentPath.usesInterfaceType($0.type)
        }.first?.type
    }

    /// 所有可用的網路介面類型
    var availableInterfacesTypes: [NWInterface.InterfaceType]? {
        guard let monitor = monitor else { return nil }
        return monitor.currentPath.availableInterfaces.map { $0.type }
    }

    /// 行動網路 = 昂貴的
    var isExpensive: Bool {
        return monitor?.currentPath.isExpensive ?? false
    }

    // MARK: Private

    /// Network 框架透過 NWPathMonitor 類別來觀察網路變化
    private var monitor: NWPathMonitor?

    /// 是否正在觀察網路狀態的變化
    private var isMonitoring = false

    func startMonitoring() {
        guard !isMonitoring else { return }

        monitor = NWPathMonitor()
        // 觀察網路狀態變化需要在背景執行緒中執行，不可以在主執行緒中執行
        let queue = DispatchQueue(label: "NetStatusQueue")
        monitor?.start(queue: queue)

        // 在任何網路狀態變化時通知它的呼叫器
        monitor?.pathUpdateHandler = { _ in
            self.netStatusChangeHandler?()
        }

        isMonitoring = true
        didStartMonitoringHandler?()
    }

    func stopMonitoring() {
        guard isMonitoring, let monitor = monitor else { return }
        monitor.cancel()
        self.monitor = nil
        isMonitoring = false
        didStopMonitoringHandler?()
    }
}
