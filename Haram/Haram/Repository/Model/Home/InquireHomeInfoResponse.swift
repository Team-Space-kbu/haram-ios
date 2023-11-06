//
//  InquireHomeInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/06/08.
//

import Foundation

struct InquireHomeInfoResponse: Decodable {
  let homes: [HomeShortcut]
  let banner: MainBanner
  let kokkoks: Kokkoks
  let notice: Notice
  let bottomBars: [BottomBar]
}

struct BottomBar: Decodable {
  let createdAt: String
  let modifiedAt: String?
  let iconSeq: Int
  let iconName: String
  let iconFilePath: String
  let uiType: String
}

struct HomeShortcut: Decodable {
  let createdAt: String
  let modifiedAt: String?
  let iconSeq: Int
  let iconName: String
  let iconFilePath: String
  let uiType: String
}

struct MainBanner: Decodable {
  let index: Int
  let banners: [SubBanner]
}

struct SubBanner: Decodable {
  let title: String
  let content: String
  let filePath: String
  let department: String
}

struct Kokkoks: Decodable {
  let index: Int
  let kbuNews: [KbuNews]
}

struct KbuNews: Decodable {
  let title: String
  let filePath: String
}

struct Notice: Decodable {
  let index: Int
  let notices: [SubNotice]
}

struct SubNotice: Decodable {
  let title: String
  let content: String
}
