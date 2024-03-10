//
//  UploadImageRequest.swift
//  Haram
//
//  Created by 이건준 on 3/9/24.
//

import Foundation

struct UploadImageRequest: Encodable {
  let aggregateType: AggregateType
}

enum AggregateType: String, Encodable {
  case icon = "ICON"
  case board = "BOARD"
  case home = "HOME"
  case rothem = "ROTHEM"
}
