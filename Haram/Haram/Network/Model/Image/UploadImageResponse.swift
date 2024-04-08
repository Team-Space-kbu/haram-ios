//
//  UploadImageResponse.swift
//  Haram
//
//  Created by 이건준 on 3/10/24.
//

import Foundation

struct UploadImageResponse: Codable {
  let tempFilePath: String
  let fileName: String
  let fileExt: String
  let fileSize: Double
}
