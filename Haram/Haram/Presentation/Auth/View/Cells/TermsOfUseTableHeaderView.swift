//
//  TermsOfUseTableHeaderView.swift
//  Haram
//
//  Created by 이건준 on 3/21/24.
//

import UIKit

import SnapKit
import Then

protocol TermsOfUseTableHeaderViewDelegate: AnyObject {
  func didTappedAllCheck(isChecked: Bool)
}

final class TermsOfUseTableHeaderView: UITableViewHeaderFooterView {
  
  static let identifier = "TermsOfUseTableHeaderView"
  weak var delegate: TermsOfUseTableHeaderViewDelegate?
  
  private let titleLabel = UILabel().then {
    $0.text = "이용약관📄"
    $0.textColor = .black
    $0.font = .bold24
  }
  
  private lazy var checkAllButton = TermsOfUseCheckView(type: .all).then {
    $0.delegate = self
  }
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    
  }
}

extension TermsOfUseTableHeaderView: TermsOfUseCheckViewDelegate {
  func didTappedAll(isChecked: Bool) {
    delegate?.didTappedAllCheck(isChecked: isChecked)
  }
  
  func didTappedCheckBox(policySeq: Int, isChecked: Bool) {
//    viewModel.checkedTermsSignUp(seq: policySeq, isChecked: isChecked)
  }
}
