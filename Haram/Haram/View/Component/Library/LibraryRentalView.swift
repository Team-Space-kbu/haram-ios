//
//  LibraryRentalView.swift
//  Haram
//
//  Created by 이건준 on 2023/09/07.
//

import UIKit

import SnapKit
import SkeletonView
import Then

// MARK: - LibraryRentalView

final class LibraryRentalView: UIView {
  
  private let registerLabel = UILabel().then {
    $0.font = .bold14
    $0.textColor = .black
  }
  
  private let numberLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .black
  }
  
  private let holdingInstitutionLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .black
  }
  
  private let loanStatusLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .black
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    isSkeletonable = true
    [registerLabel, numberLabel, holdingInstitutionLabel, loanStatusLabel].forEach {
//      $0.isSkeletonable = true
      addSubview($0)
    }
    
    numberLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(15)
      $0.centerY.equalToSuperview()
    }
    
    registerLabel.snp.makeConstraints {
      $0.bottom.equalTo(numberLabel.snp.top).offset(-1)
      $0.leading.equalToSuperview().inset(15)
      $0.trailing.lessThanOrEqualTo(loanStatusLabel.snp.leading)
    }
    
    holdingInstitutionLabel.snp.makeConstraints {
      $0.top.equalTo(numberLabel.snp.bottom).offset(1)
      $0.leading.equalTo(numberLabel)
      $0.trailing.lessThanOrEqualTo(loanStatusLabel.snp.leading)
    }
    
    loanStatusLabel.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(14)
      $0.centerY.equalToSuperview()
    }
  }
  
  func configureUI(with model: LibraryRentalViewModel) {
    registerLabel.text = model.register
    numberLabel.text = "청구기호 : \(model.number)"
    holdingInstitutionLabel.text = "소장처 : \(model.holdingInstitution)"
    loanStatusLabel.text = model.loanStatus
  }
}
