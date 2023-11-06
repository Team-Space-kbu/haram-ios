//
//  InquireAllRoomInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/08/18.
//

import Foundation

struct InquireAllRoomInfoResponse: Decodable {
  let id: Int
  let explanation: String
  let availablePersonnel: Int
  let isReserved: Bool
  let environment: String
  let expiredTime: String?
}
