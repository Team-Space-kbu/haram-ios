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

struct MileagePayInfo: Codable {
  let adjustPoints: String
  let availabilityPoint: String
  let paymentsCount: String
}

struct MileageDetail: Decodable {
  let changeDate: String
  let saleDate: String
  let status: String
  let point: String
  let etc: String
}
