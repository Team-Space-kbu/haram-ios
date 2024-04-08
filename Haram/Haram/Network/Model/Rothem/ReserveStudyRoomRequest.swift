//
//  ReserveStudyRoomRequest.swift
//  Haram
//
//  Created by 이건준 on 11/22/23.
//

import Foundation

struct ReserveStudyRoomRequest: Encodable {
  let userName: String
  let phoneNum: String
  let calendarSeq: Int
  let reservationPolicyRequests: [ReservationPolicyRequest]
  let timeRequests: [TimeRequest]
}

struct ReservationPolicyRequest: Encodable {
  let policySeq: Int
  let policyAgreeYn: String
}

struct TimeRequest: Encodable {
  let timeSeq: Int
}
