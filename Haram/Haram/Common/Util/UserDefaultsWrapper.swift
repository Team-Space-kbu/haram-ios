//
//  UserDefaultsWrapper.swift
//  Haram
//
//  Created by 이건준 on 2023/05/14.
//

import Foundation

@propertyWrapper
struct UserDefaultsWrapper<T: Codable> {
    
  private let key: String
  
  init(key: String) {
    self.key = key
  }
  
  var wrappedValue: T? {
    get {
      guard let data = UserDefaults.standard.object(forKey: self.key) as? Data,
            let decodedData = try? JSONDecoder().decode(T.self, from: data) else {
        return nil
      }
      return decodedData
    }
    set {
      guard let data = try? JSONEncoder().encode(newValue)
      else {
        UserDefaults.standard.removeObject(forKey: key)
        return
      }
      UserDefaults.standard.setValue(data, forKey: key)
    }
  }
}
