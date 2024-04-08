//
//  NetworkManager.swift
//  Haram
//
//  Created by 이건준 on 3/17/24.
//

import UIKit
import Network

final class NetworkManager {
  static let shared = NetworkManager()
  private let queue = DispatchQueue.global()
  private let monitor: NWPathMonitor
  public private(set) var isConnected: Bool = false
  public private(set) var connectionType: ConnectionType = .unknown
  
  // 연결타입
  enum ConnectionType {
    case wifi
    case cellular
    case ethernet
    case unknown
  }
  
  // monotior 초기화
  private init() {
    monitor = NWPathMonitor()
  }
  
  // Network Monitoring 시작
  public func startMonitoring() {
    monitor.start(queue: queue)
    monitor.pathUpdateHandler = { [weak self] path in
      
      self?.isConnected = path.status == .satisfied
      self?.getConnectionType(path)
      
      if self?.isConnected == true {
        NotificationCenter.default.post(name: .refreshWhenNetworkConnected, object: nil)
      } 
    }
  }
  
  // Network Monitoring 종료
  public func stopMonitoring() {
    monitor.cancel()
  }
  
  // Network 연결 타입
  private func getConnectionType(_ path: NWPath) {
    if path.usesInterfaceType(.wifi) {
      connectionType = .wifi
    } else if path.usesInterfaceType(.cellular) {
      connectionType = .cellular
    } else if path.usesInterfaceType(.wiredEthernet) {
      connectionType = .ethernet
    } else {
      connectionType = .unknown
    }
  }
}
