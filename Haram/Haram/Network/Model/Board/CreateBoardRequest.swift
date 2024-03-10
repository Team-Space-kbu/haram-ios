//
//  CreateBoardRequest.swift
//  Haram
//
//  Created by 이건준 on 3/9/24.
//

import Foundation

struct CreateBoardRequest: Encodable {
  let title: String
  let contents: String
  let isAnonymous: Bool
  let fileRequests: [FileRequeset]
}

struct FileRequeset: Encodable {
  let tempFilePath: String
  let fileName: String
  let fileExt: String
  let fileSize: Double
  let sortNum: Int
}
