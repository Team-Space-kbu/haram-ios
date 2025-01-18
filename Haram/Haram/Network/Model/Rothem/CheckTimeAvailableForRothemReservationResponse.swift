//
//  CheckTimeAvailableForRothemReservationResponse.swift
//  Haram
//
//  Created by 이건준 on 11/19/23.
//

import Foundation

struct CheckTimeAvailableForRothemReservationResponse: Decodable {
  let roomResponse: ReservationRoomResponse
  let policyResponses: [PolicyResponse]
  let calendarResponses: [CalendarResponse]
}

struct ReservationRoomResponse: Decodable {
  let roomSeq: Int
  let thumbnailPath: String
  let roomName: String
  let roomExplanation: String
  let location: String
  let peopleCount: Int
  let createdBy: String
  let createdAt: String
  let modifiedBy: String
  let modifiedAt: String
  let sortNum: Int
}

struct PolicyResponse: Decodable {
  let policySeq: Int
  let title: String?
  let content: String?
  let isRequired: Bool?
  let createdBy: String
  let createdAt: String
  let modifiedBy: String
  let modifiedAt: String
}

struct CalendarResponse: Decodable {
  let calendarSeq: Int
  let day: Day
  let year: String
  let month: String
  let date: String
  let isAvailable: Bool
  let times: [Time]?
}

struct Time: Decodable {
  let timeSeq: Int
  let hour: String
  let minute: String
  let meridiem: Meridiem
  let isReserved: Bool
}

enum Meridiem: String, Decodable {
  case am
  case pm
}
