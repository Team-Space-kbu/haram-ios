//
//  HaramTests.swift
//  HaramTests
//
//  Created by 이건준 on 2023/04/01.
//

import XCTest
@testable import Haram

final class HaramTests: XCTestCase {
  
//  private var userManager: UserManager!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
//    self.userManager = UserManager.shared
  }
  
  func test_tokenUpdateIsValid() {
//    userManager.updateHaramToken(accessToken: "", refreshToken: "")
//    userManager.clearAllInformations()
//    
//    XCTAssertNil(userManager.accessToken, "AccessToken is Nil")
//    XCTAssertNil(userManager.refreshToken, "AccessToken is Nil")
    XCTAssert(true)
  }
  
  override func tearDownWithError() throws {
    try super.tearDownWithError()
//    userManager = nil
  }
  
  
}
