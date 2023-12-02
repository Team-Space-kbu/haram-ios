//
//  RequestBookLoanStatusResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/08/07.
//

import Foundation

struct RequestBookLoanStatusResponse: Decodable {
  let keepBooks: KeepBookInfo
  let relateBooks: RelatedBookInfo
}

struct RelatedBookInfo: Decodable {
  let display: Int
  let relatedBooks: [RelatedBook]
}

struct RelatedBook: Decodable {
  let path: Int
  let image: String
  let title: String
}

struct KeepBookInfo: Decodable {
  let display: Int
  let keepBooks: [KeepBook]
}

struct KeepBook: Decodable {
  let register: String
  let number: String
  let holdingInstitution: String
  let loanStatus: String
  let returnDate: String
}
