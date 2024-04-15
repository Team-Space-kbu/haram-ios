//
//  ReportBoardRequest.swift
//  Haram
//
//  Created by 이건준 on 4/15/24.
//

import Foundation

struct ReportBoardRequest: Encodable {
  let reportType: ReportType
  let refSeq: Int
  let reportTitle: ReportTitleType
  let content: String
}

enum ReportTitleType: String, Encodable, CaseIterable {
  case inappropriateBoard = "INAPPROPRIATE_BOARD"
  case abuseBelittling = "ABUSE_BELITTLING"
  case pornography = "PORNOGRAPHY"
  case commercialAdvertisement = "COMMERCIAL_ADVERTISEMENT"
  case outflowImpersonation = "OUTFLOW_IMPERSONATION"
  case paperingFishing = "PAPERING_FISHING"
  case disparagementOfPoliticians = "DISPARAGEMENT_OF_POLITICIANS"
  case illegalFilming = "ILLEGAL_FILMING"
  
  var title: String {
    switch self {
    case .inappropriateBoard:
      return "게시판 성격에 부적절함"
    case .abuseBelittling:
      return "욕설/비하"
    case .pornography:
      return "음란물/불건전한 만남 및 대화"
    case .commercialAdvertisement:
      return "상업적 광고 및 판매"
    case .outflowImpersonation:
      return "유출/사칭/사기"
    case .paperingFishing:
      return "낚시/놀람/도배"
    case .disparagementOfPoliticians:
      return "정당/정치인 비하 및 선거운동"
    case .illegalFilming:
      return "불법촬영물 등의 유통"
    }
  }
}

enum ReportType: String, Encodable {
  case boardComment = "BOARD_COMMENT"
  case board = "BOARD"
}
