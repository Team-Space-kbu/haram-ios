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
  
  @discardableResult
  func transform(input: Input) -> Output
}
