//
//  InquireChapelDetailResponse.swift
//  Haram
//
//  Created by 이건준 on 11/5/23.
//

import Foundation

struct InquireChapelDetailResponse: Decodable {
  let date: String
  let days: String
  let dayNight: String
  let late: String
  let attendance: String
  let modiDate: String
  let modiReason: String
  let attendConfirm: String
  let chapleType: String
}
