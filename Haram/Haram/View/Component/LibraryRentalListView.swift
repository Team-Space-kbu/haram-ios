//
//  LibraryRentalListView.swift
//  Haram
//
//  Created by 이건준 on 2023/06/14.
//

import UIKit

import SnapKit
import Then

final class LibraryRentalListView: UIView {
  
//  private let lineView1 = UIView().then {
//    $0.backgroundColor = .hexD8D8DA
//  }
  
  private let rentalInfoLabel = UILabel().then {
    $0.text = "대여정보"
    $0.font = .bold
    $0.font = .systemFont(ofSize: 18)
    $0.textColor = .black
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .hexD6D4D6
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .hexD8D8DA
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    addSubview(rentalInfoLabel)
    addSubview(containerView)
    addSubview(lineView)
    
    rentalInfoLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.top.equalTo(rentalInfoLabel.snp.bottom).offset(10)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    lineView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.top.equalTo(containerView.snp.bottom).offset(20)
      $0.bottom.equalToSuperview()
    }
  }
  
  func configureUI(with model: [LibraryRentalViewModel]) {
    model.forEach { rentalModel in
      let vw = LibraryRentalView()
      vw.configureUI(with: rentalModel)
      vw.snp.makeConstraints {
        $0.height.equalTo(307 / 4)
        $0.width.equalTo(333)
      }
      containerView.addArrangedSubview(vw)
    }
  }
}

struct LibraryRentalViewModel {
  let register: String
  let number: String
  let holdingInstitution: String
  let loanStatus: String
}

final class LibraryRentalView: UIView {
  
  private let registerLabel = UILabel().then {
    $0.font = .bold
    $0.font = .systemFont(ofSize: 14)
    $0.textColor = .black
  }
  
  private let numberLabel = UILabel().then {
    $0.font = .regular
    $0.font = .systemFont(ofSize: 14)
    $0.textColor = .black
  }
  
  private let holdingInstitutionLabel = UILabel().then {
    $0.font = .regular
    $0.font = .systemFont(ofSize: 14)
    $0.textColor = .black
  }
  
  private let loanStatusLabel = UILabel().then {
    $0.font = .bold
    $0.font = .systemFont(ofSize: 18)
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
    [registerLabel, numberLabel, holdingInstitutionLabel, loanStatusLabel].forEach { addSubview($0) }
    
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
