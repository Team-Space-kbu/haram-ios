//
//  RequestBookInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/06/07.
//

import Foundation

struct RequestBookInfoResponse: Codable {
  let bookInfoRes: BookInfoRes
  let bookKeep: [BookKeep]
}

struct BookInfoRes: Codable {
  let title: String
  let image: String
  let isbn: String
  let number: String
  let ddc: String
  let author: String
  let discount: String
  let publisher: String
  let pubdate: String
  let description: String
}

struct BookKeep: Codable {
  let register: String
  let number: String
  let holdingInstitution: String
  let loanStatus: String
  let returnDate: String
}
