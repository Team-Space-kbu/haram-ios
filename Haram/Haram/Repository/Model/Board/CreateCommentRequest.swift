//
//  CreateCommentRequest.swift
//  Haram
//
//  Created by 이건준 on 11/13/23.
//

import Foundation

struct CreateCommentRequest: Encodable {
  let contents: String
  let isAnonymous: Bool
}
