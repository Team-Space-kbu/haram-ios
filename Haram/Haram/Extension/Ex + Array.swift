//
//  Ex + Array.swift
//  Haram
//
//  Created by 이건준 on 10/17/23.
//

import Foundation

extension Array where Element == InquireChapterToBibleResponse {
  var toStringWithWhiteSpace: String {
    return self.enumerated().reduce("") { acc, item -> String in
        return acc + ((item.offset != self.count - 1) ? "\(item.element.verse) \(item.element.content) " : "\(item.element.verse) \(item.element.content)")
    }
  }
}
