//
//  InquireRothemReservationInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 11/22/23.
//

import Foundation

struct InquireRothemReservationInfoResponse: Decodable {
  let reservationSeq: Int
  let userId: String
  let phoneNum: String
  let reservationCode: String
  let reservationStatus: String
  let roomResponse: RoomResponse
  let calendarResponse: ReservationCalendar
  let timeResponses: [ReservationTime]
}

struct ReservationCalendar: Decodable {
  let calendarSeq: Int
  let day: String
  let year: String
  let month: String
  let date: String
  let isAvailable: Bool
  let weekStatus: String
}

struct ReservationTime: Decodable {
  let timeSeq: Int
  let hour: String
  let minute: String
  let meridiem: Meridiem
  let isAvailable: Bool
}

