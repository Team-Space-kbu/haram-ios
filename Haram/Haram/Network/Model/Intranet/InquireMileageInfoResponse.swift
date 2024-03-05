//
//  InquireMileageInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 11/10/23.
//

import Foundation

struct InquireMileageInfoResponse: Decodable {
  let mileagePayInfo: MileagePayInfo
  let mileageDetails: [MileageDetail]
}

struct MileagePayInfo: Decodable {
  let adjustPoints: String
  let availabilityPoint: String
  let paymentsCount: String
}

struct MileageDetail: Decodable {
  let changeDate: String
  let saleDate: String
  let status: String
  let point: Int
  let etc: String
  let type: MileageDetailType
}

enum MileageDetailType: String, Decodable {
  case cafe = "CAFE"
  case gym = "GYM"
  case mart = "MART"
  case bookStore = "BOOKSTORE"
  case copyRoom = "COPYROOM"
  case student = "STUDENT"
  case etc = "ETC"
}
