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

enum ReportTitleType: String, Encodable {
  case inappropriateBOARD = "INAPPROPRIATE_BOARD"
  case abuseBelittling = "ABUSE_BELITTLING"
  case pornography = "PORNOGRAPHY"
  case commercialAdvertisement = "COMMERCIAL_ADVERTISEMENT"
  case outflowImpersonation = "OUTFLOW_IMPERSONATION"
  case paperingFishing = "PAPERING_FISHING"
  case disparagementOfPoliticians = "DISPARAGEMENT_OF_POLITICIANS"
  case illegalFilming = "ILLEGAL_FILMING"
}

enum ReportType: String, Encodable {
  case boardComment = "BOARD_COMMENT"
  case board = "BOARD"
}
