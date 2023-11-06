//
//  InquireAffiliatedListResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/08/29.
//

import Foundation

struct InquireAffiliatedResponse: Decodable {
  let id: Int
  let affiliatedName: String
  let tag: String
  let affiliatedImageURL: URL?
  let description: String
  let affiliatedAddress: String
  let xCoordinate: String
  let yCoordinate: String
  let createDate: String?
  let updateDate: String?
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let affiliatedImageString = (try values.decodeIfPresent(String.self, forKey: .affiliatedImageURL)) ?? ""
    
    self.id = (try values.decodeIfPresent(Int.self, forKey: .id)) ?? -1
    self.affiliatedName = (try values.decodeIfPresent(String.self, forKey: .affiliatedName)) ?? ""
    self.tag = (try values.decodeIfPresent(String.self, forKey: .tag)) ?? ""
    self.affiliatedImageURL = URL(string: affiliatedImageString)
    self.description = (try values.decodeIfPresent(String.self, forKey: .description)) ?? ""
    self.affiliatedAddress = (try values.decodeIfPresent(String.self, forKey: .affiliatedAddress)) ?? ""
    self.xCoordinate = (try values.decodeIfPresent(String.self, forKey: .xCoordinate)) ?? ""
    self.yCoordinate = (try values.decodeIfPresent(String.self, forKey: .yCoordinate)) ?? ""
    self.createDate = (try values.decodeIfPresent(String.self, forKey: .createDate))
    self.updateDate = (try values.decodeIfPresent(String.self, forKey: .updateDate))
  }
  
  enum CodingKeys: String, CodingKey {
    case id, tag, description
    case xCoordinate = "x_coordinate"
    case yCoordinate = "y_coordinate"
    case createDate = "create_date"
    case updateDate = "update_date"
    case affiliatedImageURL = "image"
    case affiliatedAddress = "address"
    case affiliatedName = "businessName"
  }
}
