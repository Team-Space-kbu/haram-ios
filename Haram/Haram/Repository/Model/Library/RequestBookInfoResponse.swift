//
//  RequestBookInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/06/07.
//

import Foundation

struct RequestBookInfoResponse: Codable {
  let bookTitle: String
  let thumbnailImage: String
  let isbn: String?
  let number: String?
  let ddc: String?
  let author: String
  let discount: String
  let publisher: String
  let pubDate: String
  let description: String
  
  enum CodingKeys: String, CodingKey {
    case thumbnailImage = "image"
    case bookTitle = "title"
    case isbn, number, ddc, author, discount, publisher, pubDate, description
  }
}

struct BookKeep: Codable {
  let register: String
  let number: String
  let holdingInstitution: String
  let loanStatus: String
  let returnDate: String
}
