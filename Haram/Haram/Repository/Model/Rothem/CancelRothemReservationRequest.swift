//
//  CancelRothemReservationRequest.swift
//  Haram
//
//  Created by 이건준 on 11/28/23.
//

import Foundation

struct CancelRothemReservationRequest: Encodable {
  let reservationSeq: Int
  let userID: String
   
  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case reservationSeq
  }
}
