//
//  ReusableView.swift
//  Haram
//
//  Created by 이건준 on 9/18/24.
//

import UIKit

/// class 이름을 reuseIdentifier로 자동으로 만들어주는 Protocol
protocol ReusableView: AnyObject {
  static var reuseIdentifier: String { get }
}

extension ReusableView {
  static var reuseIdentifier: String {
    return String(describing: Self.self)
  }
}

// MARK: UICollectionView & UITableView 실 사용부
extension UICollectionView {
  
  /// Register UICollectionViewCell that conforms ReusableCell to UICollectionView using reuseIdentifier
  func register<T: UICollectionViewCell>(_: T.Type) where T: ReusableView {
    register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
  }
  
  func register<T: UICollectionReusableView>(_: T.Type, of kind: String) where T: ReusableView {
    register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
  }
  
  /// Get dequeueReusableCell of UICollectionViewCell that conforms ReusableCell using reuseIdentifier
  func dequeueReusableCell<T: UICollectionViewCell>(_: T.Type, for indexPath: IndexPath) -> T? where T: ReusableView {
    guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
      return nil
    }
    
    return cell
  }
}

extension UITableView {
  /// Register UITableViewCell that conforms ReusableCell to UITableView using reuseIdentifier
  func register<T: UITableViewCell>(_: T.Type) where T: ReusableView {
    register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
  }
  
  func register<T: UITableViewHeaderFooterView>(_: T.Type) where T: ReusableView {
    register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
  }
  
  /// Get dequeueReusableCell of UITableViewCell that conforms ReusableCell using reuseIdentifier
  func dequeueReusableCell<T: UITableViewCell>(_: T.Type, for indexPath: IndexPath) -> T? where T: ReusableView {
    guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
      return nil
    }
    
    return cell
  }
}

