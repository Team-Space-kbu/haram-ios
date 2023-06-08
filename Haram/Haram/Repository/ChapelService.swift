//
//  ChapelService.swift
//  Haram
//
//  Created by 이건준 on 2023/06/04.
//

import RxSwift

final class ChapelService {
  
  static let shared = ChapelService()
  
  private let service: BaseService
  
  private init() { self.service = ApiService() }
  
}

extension ChapelService {
  func inquireChapelList(request: InquireChapelListRequest) -> Observable<[InquireChapelListResponse]> {
    service.request(router: ChapelRouter.inquireChapelList(request), type: [InquireChapelListResponse].self)
  }
  
  func inquireChapelInfo(request: InquireChapelListRequest) -> Observable<InquireChapelInfoResponse> {
    service.request(router: ChapelRouter.inquireChapelInfo(request), type: InquireChapelInfoResponse.self)
  }
}

