//
//  InquireBannerInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 4/3/24.
//

import Foundation

struct InquireBannerInfoResponse: Decodable {
  let bannerSeq: Int
  let title: String
  let content: String
  let thumbnailPath: String
  let department: String
  let bannerFileResponses: [BannerFileResponse]
  let createdBy: String
  let createdAt: String
  let modifiedBy: String
  let modifiedAt: String
}

struct BannerFileResponse: Decodable {
  let seq: Int
  let bannerSeq: Int
  let sortNum: Int
  let filePath: String
  let createdBy: String
  let createdAt: String
  let modifiedBy: String
  let modifiedAt: String
}
