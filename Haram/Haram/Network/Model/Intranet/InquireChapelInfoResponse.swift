//
//  InquireChapelInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/06/06.
//

import Foundation

struct InquireChapelInfoResponse: Decodable {
  let regulateDays: String
  let attendanceDays: String
  let lateDays: String
  let confirmationDays: String
}
