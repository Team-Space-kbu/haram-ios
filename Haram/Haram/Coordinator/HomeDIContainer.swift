//
//  HomeDIContainer.swift
//  Haram
//
//  Created by 이건준 on 1/3/24.
//

import Foundation

@objc public protocol ChildrenContainer {
  typealias ChildrenDependency = AnyObject
  typealias ChildrenController = AnyObject
  
  @objc optional func makeChildrenDependency() -> ChildrenDependency
  @objc optional func makeChildrenController() -> ChildrenController
}



protocol DIContainer: ChildrenContainer {
  
  associatedtype ViewModel
  associatedtype Repository
  associatedtype Controller
  
  
  func makeViewModel() -> ViewModel
  func makeRepository() -> Repository
  func makeController() -> Controller
  
}

//MARK: Dependency
final class HomeDependencyContainer: DIContainer {
  
  typealias ViewModel = HomeViewModelType
  typealias Repository = HomeRepository
  typealias Controller = HomeViewController
  
  
  private let homeApiService: BaseService
  
  
  public init(
    homeApiService: BaseService
  ) {
    self.homeApiService = homeApiService
  }
  
  deinit {
    print(#function)
  }
  
  
  public func makeViewModel() -> ViewModel {
    return HomeViewModel(homeRepository: makeRepository())
  }
  
  public func makeRepository() -> Repository {
    return HomeRepositoryImpl(service: homeApiService)
  }
  
  public func makeController() -> Controller {
    return HomeViewController(viewModel: makeViewModel())
  }
  
  
  
}
