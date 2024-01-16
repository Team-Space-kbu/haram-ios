////
////  CompositionRoot.swift
////  Haram
////
////  Created by 이건준 on 1/3/24.
////
//
//import Foundation
////메모리를 효율적으로 쓰기위해서 di를 할껀데 이를 하기위해서 의존성을 관리해주는 CompositionRoot를 만들어준다
//
//struct AppDependency {
//  let homeCoordinator: HomeCoordinator
//  let boardCoordinator: BoardCoordinator
//  let moreCoordinator: MoreCoordinator
//}
//
//extension AppDependency{
//    static func resolve() -> AppDependency {
//        
////        let stockRepository:StockRepository = StockRepositoryImpl()
////        
////        let stockListControllerFactory:() -> StockListController = {
////            let usecase = StockUseCase(stockRepository: stockRepository)
////            let viewModel = StockListViewModel(usecase: usecase)
////            return .init(dependency: .init(viewModel: viewModel))
////        }
////        
////        let stockDetailControllerFactory: (Stock) -> StockDetailController = { stock in
////            
////            let usecase: StockDetailUseCase = .init(stockRepository: stockRepository)
////            let viewModel: StockDetailViewModel = .init(usecase: usecase)
////            
////            return .init(dependency: .init(stock: stock, viewModel: viewModel))
////        }
////        
////        let selectDateControllerFactory: () -> SelectDateController = {
////            .init()
////        }
////        
////        let mainCoordinator:MainCoordinator = .init(dependency: .init(stockListControllerFactory: stockListControllerFactory, stockDetailControllerFactory: stockDetailControllerFactory, selectDateControllerFactory: selectDateControllerFactory))
//        
//      let homeControllerFactory: () -> HomeViewController = {
//        let service = ApiService.shared
//        let homeRepository = HomeRepositoryImpl(service: service)
//        let viewModel = HomeViewModel(homeRepository: homeRepository)
//        return .init(viewModel: viewModel)
//      }
//      
//      let mileageControllerFactory: () -> MileageViewController = {
//        let service = ApiService.shared
//        let intranetRepository = IntranetRepositoryImpl(service: service)
//        let viewModel = MileageViewModel(intranetRepository: intranetRepository)
//        return .init(viewModel: viewModel)
//      }
//      
//      let chapelControllerFactory: () -> ChapelViewController = {
//        let service = ApiService.shared
//        let intranetRepository = IntranetRepositoryImpl(service: service)
//        let viewModel = ChapelViewModel(intranetRepository: intranetRepository)
//        return .init(viewModel: viewModel)
//      }
//      
//      let noticeControllerFactory: () -> NoticeViewController = {
//        let service = ApiService.shared
//        let viewModel = NoticeViewModel()
//        return .init(viewModel: viewModel)
//      }
//      
//      let libraryControllerFactory: () -> LibraryViewController = {
//        let service = ApiService.shared
//        let libraryRepostory = LibraryRepositoryImpl(service: service)
//        let viewModel = LibraryViewModel(libraryRepostory: libraryRepostory)
//        return .init(viewModel: viewModel)
//      }
//      
//      let affilicatedControllerFactory: () -> AffiliatedViewController = {
//        return .init()
//      }
//      
//      let scheduleControllerFactory: () -> ScheduleViewController = {
//        let service = ApiService.shared
//        let intranetRepository = IntranetRepositoryImpl(service: service)
//        let viewModel = ScheduleViewModel(intranetRepository: intranetRepository)
//        return .init(viewModel: viewModel)
//      }
//      
//      let rothemControllerFactory: () -> RothemRoomListViewController = {
//        let service = ApiService.shared
//        let rothemRepository = RothemRepositoryImpl(service: service)
//        let viewModel = RothemRoomListViewModel(rothemRepository: rothemRepository)
//        return .init(viewModel: viewModel)
//      }
//      
//      let homeCoordinator: HomeCoordinator = .init(dependency: .init(homeControllerFactory: homeControllerFactory, mileageControllerFactory: mileageControllerFactory, chapelControllerFactory: chapelControllerFactory, noticeControllerFactory: noticeControllerFactory, libraryControllerFactory: libraryControllerFactory, affilicatedControllerFactory: affilicatedControllerFactory, scheduleControllerFactory: scheduleControllerFactory, rothemControllerFactory: rothemControllerFactory))
//      
//      let boardCoordinator = BoardCoordinator()
//      let moreCoordinator = MoreCoordinator()
//      
//      return .init(homeCoordinator: homeCoordinator, boardCoordinator: boardCoordinator, moreCoordinator: moreCoordinator)
//        
//    }
//}
//
