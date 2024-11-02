//
//  InquireHomeInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/06/08.
//

import Foundation

struct InquireHomeInfoResponse: Decodable {
  let kokkoks: [Kokkok]
  let notice: [Notice]
}

struct Kokkok: Decodable {
  let title: String
  let img: String
  let file: String
}

struct Notice: Decodable {
  let noticeSeq: Int
  let thumbnailPath: String
  let title: String
}
