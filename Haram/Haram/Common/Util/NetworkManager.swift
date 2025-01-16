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
  
  public private(set) var isConnected: Bool = true {
    didSet {
      if oldValue != isConnected {
        if isConnected {
          NotificationCenter.default.post(name: .refreshWhenNetworkConnected, object: nil)
        }
      }
    }
  }
  public private(set) var connectionType: ConnectionType = .unknown
  
  private init() {
    monitor = NWPathMonitor()
  }
  
  public func startMonitoring() {
    monitor.pathUpdateHandler = { [weak self] path in
      guard let self = self else { return }
      
      let currentStatus = path.status == .satisfied
      self.getConnectionType(path)
      
      if currentStatus {
        self.isInternetAvailable { isInternetAvailable in
          self.isConnected = isInternetAvailable
        }
      } else {
        self.isConnected = false
      }
    }
    monitor.start(queue: queue)
  }
  
  public func stopMonitoring() {
    monitor.cancel()
  }
}

extension NetworkManager {
  enum ConnectionType {
    case wifi
    case cellular
    case ethernet
    case unknown
  }
  
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
  
  private func isInternetAvailable(completion: @escaping (Bool) -> Void) {
    let url = URL(string: "https://www.google.com")!
    var request = URLRequest(url: url)
    request.timeoutInterval = 5.0 // 타임아웃 설정
    
    let task = URLSession.shared.dataTask(with: request) { _, response, _ in
      if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
        completion(true)
      } else {
        completion(false)
      }
    }
    task.resume()
  }
}
