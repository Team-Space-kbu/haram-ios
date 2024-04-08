//
//  APIEventLogger.swift
//  Haram
//
//  Created by 이건준 on 2023/08/03.
//

import Foundation

import Alamofire

final class APIEventLogger: EventMonitor {
  
  let queue = DispatchQueue(label: "com.space.biblemon")
  
  func requestDidFinish(_ request: Request) {
    LogHelper.log("⭐️Reqeust LOG\n" + request.description + "\nBody: " + (request.request?.httpBody?.toPrettyPrintedString ?? ""), level: .info)
  }
  
  func request<Value>(
    _ request: DataRequest,
    didParseResponse response: DataResponse<Value, AFError>
  ) {
    LogHelper.log("⭐️RESPONSE LOG\n" + "URL: " + (request.request?.url?.absoluteString ?? "") + "\n"
                  + "Result: " + "\(response.result)" + "\n"
                  + "StatusCode: " + "\(response.response?.statusCode ?? 0)" + "\n"
                  + "Data: \(response.data?.toPrettyPrintedString ?? "")", level: .info)
  }
}

extension Data {
  var toPrettyPrintedString: String? {
    guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
          let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
          let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
    return prettyPrintedString as String
  }
}
