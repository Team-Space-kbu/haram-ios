//
//  InquireEmptyClassDetailResponse.swift
//  Haram
//
//  Created by 이건준 on 10/13/24.
//

import Foundation

struct InquireEmptyClassDetailResponse: Decodable {
  let subject: String
  let startTime: String
  let endTime: String
  let lectureNum: String
  let profName: String
  let lectureDay: String
  let classRoomName: String
  let lectureFile: String
}
