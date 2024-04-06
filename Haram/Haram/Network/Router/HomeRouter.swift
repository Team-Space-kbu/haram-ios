//
//  HomeRouter.swift
//  Haram
//
//  Created by 이건준 on 2023/06/08.
//

import Alamofire

enum HomeRouter {
  case inquireHomeInfo
  case inquireAffiliatedList
  case inquireAffiliatedDetail(Int)
  case inquireBannerInfo(Int)
}

extension HomeRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireHomeInfo, .inquireAffiliatedList, .inquireBannerInfo, .inquireAffiliatedDetail:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireHomeInfo:
      return "/v1/homes"
    case .inquireAffiliatedList:
      return "/v1/partners"
    case let .inquireBannerInfo(bannerSeq):
      return "/v1/banners/notices/\(bannerSeq)"
    case let .inquireAffiliatedDetail(id):
      return "/v1/partners/\(id)"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireHomeInfo, .inquireAffiliatedList, .inquireBannerInfo, .inquireAffiliatedDetail:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireHomeInfo, .inquireAffiliatedList, .inquireBannerInfo, .inquireAffiliatedDetail:
      return .withAccessToken
    }
  }
}

