//
//  RequestBookLoanStatusResponse.swift
//  Haram
//
//  Created by 이건준 on 2023/08/07.
//

import Foundation

struct RequestBookLoanStatusResponse: Codable {
  let register: String
  let number: String
  let holdingInstitution: String
  let loanStatus: String
  let returnDate: String
}
