//
//  APIEventLogger.swift
//  Haram
//
//  Created by 이건준 on 2023/08/03.
//

import Foundation

import Alamofire

final class APIEventLogger: EventMonitor {
  //1
  let queue = DispatchQueue(label: "com.Jun.Haram")
  //2
  func requestDidFinish(_ request: Request) {
    LogHelper.log("⭐️Reqeust LOG", level: .debug)
    LogHelper.log(request.description, level: .debug)
    LogHelper.log("Body: " + (request.request?.httpBody?.toPrettyPrintedString ?? ""), level: .debug)
  }
  //3
  func request<Value>(
    _ request: DataRequest,
    didParseResponse response: DataResponse<Value, AFError>
  ) {
    LogHelper.log("⭐️RESPONSE LOG", level: .debug)
    LogHelper.log("URL: " + (request.request?.url?.absoluteString ?? "") + "\n"
                  + "Result: " + "\(response.result)" + "\n"
                  + "StatusCode: " + "\(response.response?.statusCode ?? 0)" + "\n"
                  + "Data: \(response.data?.toPrettyPrintedString ?? "")", level: .debug)
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
