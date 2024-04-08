//
//  InquireNoticeInfoRequest.swift
//  Haram
//
//  Created by 이건준 on 2/20/24.
//

import Foundation

struct InquireNoticeTypeInfoRequest: Encodable {
  let type: NoticeType
  let page: Int
}

enum NoticeType: String, Codable, CaseIterable {
  case student = "student"
  case scholarship = "scholarship"
  case chapel = "chapel"
  case lms = "lms"
  case ainavi = "ainavi"
  case library = "library"
  case job = "job"
  case jobStudent = "job-student"
  case jobChurch = "job-church"
  
  var title: String? {
    switch self {
    case .student:
      return "학사/취창업"
    case .scholarship:
      return "장학/등록금"
    case .chapel:
      return "신앙/채플"
    case .lms:
      return "LMS공지"
    case .library:
      return "도서관"
    case .ainavi:
      return "AI NAVI"
    default:
      return nil
    }
  }
  
  static var noticeCategoryList: [Self] = [.student, .scholarship, .chapel, .lms, .library, .ainavi]
}
