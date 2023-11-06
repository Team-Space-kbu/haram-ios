//
//  InquireScheduleInfoResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/06/13.
//

import Foundation

struct InquireScheduleInfoResponse: Decodable {
  let semester: String
  let lectureNum: String
  let classRoomLocation: String
  let lectureDay: String
  let startTime: String
  let endTime: String
  let subject: String
  let classRoomName: String
}

