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
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .hexD6D4D6
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    addSubview(containerView)
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
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
    registerLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview().inset(15)
    }
    
    numberLabel.snp.makeConstraints {
      $0.top.equalTo(registerLabel.snp.bottom).offset(1)
      $0.leading.equalTo(registerLabel)
    }
    
    holdingInstitutionLabel.snp.makeConstraints {
      $0.top.equalTo(numberLabel.snp.bottom).offset(1)
      $0.leading.equalTo(numberLabel)
      $0.bottom.equalToSuperview()
    }
  }
  
  func configureUI(with model: LibraryRentalViewModel) {
    registerLabel.text = model.register
    numberLabel.text = "청구기호 : \(model.number)"
    holdingInstitutionLabel.text = "소장처 : \(model.holdingInstitution)"
    loanStatusLabel.text = model.loanStatus
  }
}
