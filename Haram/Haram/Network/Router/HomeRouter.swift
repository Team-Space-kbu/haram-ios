//
//  HomeRouter.swift
//  Haram
//
//  Created by 이건준 on 2023/06/08.
//

import Alamofire

enum HomeRouter {
  case inquireHomeInfo
  case inquireAffiliatedModel
  case inquireAffiliatedDetail(Int)
  case inquireBannerInfo(Int)
}

extension HomeRouter: Router {
  
  var method: HTTPMethod {
    .get
  }
  
  var path: String {
    switch self {
    case .inquireHomeInfo:
      return "/v2/homes"
    case .inquireAffiliatedModel:
      return "/v1/partners"
    case let .inquireBannerInfo(bannerSeq):
      return "/v1/banners/notices/\(bannerSeq)"
    case let .inquireAffiliatedDetail(id):
      return "/v1/partners/\(id)"
    }
  }
  
  var parameters: ParameterType {
    .plain
  }
  
  var headers: HeaderType {
    .withAccessToken
  }
}

