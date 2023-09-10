//
//  SearchBookRequest.swift
//  Haram
//
//  Created by 이건준 on 2023/09/10.
//

import Foundation

struct SearchBookRequest: Codable {
  let query: String
  let page: Int
  
  enum CodingKeys: String, CodingKey {
    case query = "q"
    case page = "p"
  }
}
