//
//  InquireChapelListResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/06/04.
//

import Foundation

struct InquireChapelListResponse: Decodable {
  let attendance: String
  let weekDays: String
  let attendanceDays: String
  let type: String
}
