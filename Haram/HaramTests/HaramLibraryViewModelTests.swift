//
//  HaramLibraryViewModelTests.swift
//  HaramTests
//
//  Created by 이건준 on 12/17/23.
//

import XCTest
@testable import Haram

final class HaramLibraryViewModelTests: XCTestCase {
  
  private var viewModel: LibraryViewModelType!

    override func setUpWithError() throws {
      self.viewModel = LibraryViewModel()
    }

    override func tearDownWithError() throws {
      self.viewModel = nil
    }

}

//final class TestLibraryViewModel: LibraryViewModelType {
//  var newBookModel: RxCocoa.Driver<[Haram.NewLibraryCollectionViewCellModel]>
//  
//  var bestBookModel: RxCocoa.Driver<[Haram.PopularLibraryCollectionViewCellModel]>
//  
//  var rentalBookModel: RxCocoa.Driver<[Haram.RentalLibraryCollectionViewCellModel]>
//  
//  var bannerImage: RxCocoa.Signal<URL?>
//  
//  var isLoading: RxCocoa.Driver<Bool>
//  
//
//}
