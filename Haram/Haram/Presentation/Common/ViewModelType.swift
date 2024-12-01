//
//  ViewModelType.swift
//  Haram
//
//  Created by 이건준 on 10/7/24.
//

import RxSwift

protocol ViewModelType {
  associatedtype Input
  associatedtype Output
  associatedtype Dependency
  associatedtype Payload
  
  @discardableResult
  func transform(input: Input) -> Output
}
