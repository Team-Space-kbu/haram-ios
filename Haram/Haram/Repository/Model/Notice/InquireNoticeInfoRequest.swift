//
//  InquireNoticeInfoRequest.swift
//  Haram
//
//  Created by 이건준 on 2/20/24.
//

import Foundation

struct InquireNoticeInfoRequest: Encodable {
  let noticeType: NoticeType
  let page: Int
}

enum NoticeType: String, Codable {
  case student
  case scholarship
  case chapel
  case lms
  case ainavi
  case library
  case job
  case jobStudent
  case jobChurch
  
  enum CodingKeys: String, CodingKey {
    case student, scholarship, chapel, lms, ainavi, library, job
    case jobStudent = "job-student"
    case jobChurch = "job-church"
  }
  
//  var title: String {
//    switch self {
//    case .haramNotice:
//      return "하람공지"
//    case .student:
//      return "학사/취창업"
//    case .scholarship:
//      return "장학/등록금"
//    case .chapel:
//      return "신앙/채플"
//    case .lms:
//      return "LMS공지"
//    case .library:
//      return "도서관"
//    case .ainavi:
//      return "AI NAVI"
//    }
//  }
}
