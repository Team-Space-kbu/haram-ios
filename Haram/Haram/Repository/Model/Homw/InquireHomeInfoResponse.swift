//
//  InquireHomeInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/06/08.
//

import Foundation

struct InquireHomeInfoResponse: Codable {
  let banner: MainBanner
  let kokkoks: Kokkoks
  let notice: Notice
}

struct MainBanner: Codable {
  let index: Int
  let banners: [SubBanner]
}

struct SubBanner: Codable {
  let title: String
  let content: String
  let filePath: String
  let department: String
}

struct Kokkoks: Codable {
  let index: Int
  let kbuNews: [KbuNews]
}

struct KbuNews: Codable {
  let title: String
  let filePath: String
}

struct Notice: Codable {
  let index: Int
  let notice: [SubNotice]
}

struct SubNotice: Codable {
  let title: String
  let content: String
}
