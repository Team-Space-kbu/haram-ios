//
//  InquireBoardlistResponse.swift
//  Haram
//
//  Created by 이건준 on 10/14/23.
//

import Foundation

struct InquireBoardlistResponse: Decodable {
  let boardSeq: Int
  let boardTitle: String
  let userID: String
  let boardContent: String
  let boardType: String
  let files: String?
  
  enum CodingKeys: String, CodingKey {
    case boardSeq, boardTitle, boardContent, boardType, files
    case userID = "userId"
  }
}

/// 게시글에 대한 타입
enum BoardType: String, CaseIterable, Decodable {
  case STUDENT_COUNCIL
  case CLUB
  case DEPARTMENT
  case FREE
  case SECRET
  case WORRIES
  case INFORMATION
  case DATING
  case STUDY
  
  var title: String {
    switch self {
    case .STUDENT_COUNCIL:
      return "총학공지사항"
    case .CLUB:
      return "동아리게시판"
    case .DEPARTMENT:
      return "학과게시판"
    case .FREE:
      return "자유게시판"
    case .SECRET:
      return "비밀게시판"
    case .WORRIES:
      return "고민게시판"
    case .INFORMATION:
      return "정보게시판"
    case .DATING:
      return "연애게시판"
    case .STUDY:
      return "스터디게시판"
    }
  }
  
  static let headerTitle = "학교게시판"
  
  var imageName: String {
    switch self {
    case .STUDENT_COUNCIL:
      return "noticeBlack"
    case .CLUB:
      return "clubBlue"
    case .DEPARTMENT:
      return "departmentRed"
    case .FREE:
      return "freeGreen"
    case .SECRET:
      return "secretGreen"
    case .WORRIES:
      return "thinkYellow"
    case .INFORMATION:
      return "inforRed"
    case .DATING:
      return "dateBlack"
    case .STUDY:
      return "studyPurple"
    }
  }

}
