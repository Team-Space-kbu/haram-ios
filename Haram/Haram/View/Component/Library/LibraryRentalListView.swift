//
//  LibraryRentalListView.swift
//  Haram
//
//  Created by 이건준 on 2023/06/14.
//

import UIKit

import SnapKit
import SkeletonView
import Then

final class LibraryRentalListView: UIView {
  
  private let lineView1 = UIView().then {
    $0.backgroundColor = .hexD8D8DA
  }
  
  private let rentalInfoLabel = UILabel().then {
    $0.text = Constants.rentalInfoText
    $0.font = .bold18
    $0.textColor = .black
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .hexF2F3F5
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
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
    _ = [lineView1, rentalInfoLabel, containerView, lineView].map {
      $0.isSkeletonable = true
      addSubview($0)
    }
    
    lineView1.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(1)
    }
    
    rentalInfoLabel.snp.makeConstraints {
      $0.top.equalTo(lineView1.snp.bottom).offset(21)
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
    containerView.subviews.forEach { $0.removeFromSuperview() }
    
    if model.isEmpty {
      let emptyView = RentalEmptyView()
      emptyView.snp.makeConstraints {
        $0.height.equalTo(80)
      }
      containerView.addArrangedSubview(emptyView)
      return
    }
    
    model[0..<model.count - 1].forEach { rentalModel in
      let vw = LibraryRentalView()
      vw.configureUI(with: rentalModel)
      vw.snp.makeConstraints {
        $0.height.equalTo(307 / 4)
      }
      
      let line = UIView().then {
        $0.backgroundColor = .hexD8D8DA
      }
      
      line.snp.makeConstraints {
        $0.height.equalTo(1)
      }
      [vw, line].forEach { containerView.addArrangedSubview($0) }
    }
    
    let vw = LibraryRentalView()
    vw.configureUI(with: model[model.count - 1])
    vw.snp.makeConstraints {
      $0.height.equalTo(307 / 4)
    }
    containerView.addArrangedSubview(vw)
  }
  
  func removeLastIineView() {
    lineView.removeFromSuperview()
  }
}

// MARK: - LibraryRentalView Model

struct LibraryRentalViewModel {
  let register: String
  let number: String
  let holdingInstitution: String
  let loanStatus: String
  
  init(keepBook: KeepBook) {
    register = keepBook.register
    number = keepBook.number
    holdingInstitution = keepBook.holdingInstitution
    loanStatus = keepBook.loanStatus
  }
}

extension LibraryRentalListView {
  
  // MARK: - RentalEmptyView
  
  final class RentalEmptyView: UIView {
    
    private let alertLabel = UILabel().then {
      $0.textColor = .hex1A1E27
      $0.font = .bold18
      $0.text = Constants.alertText
    }
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      configureUI()
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
      backgroundColor = .hexF2F3F5
      layer.masksToBounds = true
      layer.cornerRadius = 10
      
      addSubview(alertLabel)
      alertLabel.snp.makeConstraints {
        $0.center.equalToSuperview()
      }
    }
  }
}

extension LibraryRentalListView {
  
  // MARK: - Constants
  
  enum Constants {
    static let alertText = "대여 가능한 정보가 없습니다."
    static let rentalInfoText = "대여정보"
  }
}
