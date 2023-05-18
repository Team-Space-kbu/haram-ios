//
//  BaseEntity.swift
//  Haram
//
//  Created by 이건준 on 2023/05/14.
//

import Foundation

struct BaseEntity<T>: Decodable where T: Decodable {
  let code: String
  let description: String
  let dateTime: String
  let data: T
  
  enum CodingKeys: CodingKey {
    case code, description, dateTime, data
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.code = try container.decodeIfPresent(String.self, forKey: .code) ?? ""
    self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
    self.dateTime = try container.decodeIfPresent(String.self, forKey: .dateTime) ?? ""
    self.data = try container.decode(T.self, forKey: .data)
  }
}
