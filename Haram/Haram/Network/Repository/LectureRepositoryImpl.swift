//
//  LectureRepositoryImpl.swift
//  Haram
//
//  Created by 이건준 on 10/13/24.
//

import RxSwift

protocol LectureRepository {
  func inquireEmptyClassBuilding() -> Single<[String]>
  func inquireEmptyClassList(classRoom: String) -> Single<[String]>
  func inquireEmptyClassDetail(classRoom: String) -> Single<[InquireEmptyClassDetailResponse]>
  func inquireCoursePlanList() -> Single<[InquireCoursePlanListResponse]>
  func inquireCoursePlanDetail(course: String) -> Single<[InquireEmptyClassDetailResponse]>
}

final class LectureRepositoryImpl {
  
  private let service: BaseService
  
  init(service: BaseService = ApiService.shared) {
    self.service = service
  }
  
}

extension LectureRepositoryImpl: LectureRepository {
  func inquireEmptyClassBuilding() -> RxSwift.Single<[String]> {
    service.betarequest(router: LectureRouter.inquireEmptyClassBuilding, type: [String].self)
  }
  
  func inquireEmptyClassList(classRoom: String) -> RxSwift.Single<[String]> {
    service.betarequest(router: LectureRouter.inquireEmptyClassList(classRoom), type: [String].self)
  }
  
  func inquireEmptyClassDetail(classRoom: String) -> RxSwift.Single<[InquireEmptyClassDetailResponse]> {
    service.betarequest(router: LectureRouter.inquireEmptyClassDetail(classRoom), type: [InquireEmptyClassDetailResponse].self)
  }
  
  func inquireCoursePlanList() -> RxSwift.Single<[InquireCoursePlanListResponse]> {
    service.betarequest(router: LectureRouter.inquireCoursePlanList, type: [InquireCoursePlanListResponse].self)
  }
  
  func inquireCoursePlanDetail(course: String) -> RxSwift.Single<[InquireEmptyClassDetailResponse]> {
    service.betarequest(router: LectureRouter.inquireCoursePlanDetail(course), type: [InquireEmptyClassDetailResponse].self)
  }
}

