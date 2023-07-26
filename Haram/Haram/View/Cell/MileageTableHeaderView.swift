//
//  MileageTableHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/07/17.
//

import UIKit

import RxSwift
import SnapKit
import Then

struct MileageTableHeaderViewModel {
  let totalMileage: Int
}

final class MileageTableHeaderView: UITableViewHeaderFooterView {
  
  static let identifier = "MileageTableHeaderView"
  private let disposeBag = DisposeBag()
  
  private let totalMileageLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .bold
    $0.font = .systemFont(ofSize: 36)
    $0.text = "10,218원"
  }
  
  private let mileageReloadButton = MileageReloadButton()
  
  private let spendListLabel = UILabel().then {
    $0.text = "소비내역"
    $0.textColor = .black
    $0.font = .bold14
  }
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    configureUI()
//    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func bind() {
    mileageReloadButton.button.rx.tap
      .subscribe(onNext: { _ in
        print("버튼탭")
      })
      .disposed(by: disposeBag)
  }
  
  private func configureUI() {
    [totalMileageLabel, mileageReloadButton, spendListLabel].forEach { addSubview($0) }
    totalMileageLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(69.97)
      $0.leading.equalToSuperview()
    }
    
    mileageReloadButton.snp.makeConstraints {
      $0.top.equalTo(totalMileageLabel.snp.bottom).offset(14)
      $0.leading.equalToSuperview()
    }
    
    spendListLabel.snp.makeConstraints {
      $0.top.equalTo(mileageReloadButton.snp.bottom).offset(95)
      $0.leading.equalToSuperview()
      $0.bottom.equalToSuperview().inset(3)
    }
  }
  
  func configureUI(with model: MileageTableHeaderViewModel) {
    let formatter = NumberformatterFactory.decimal
    let decimalTotalMileage = formatter.string(for: model.totalMileage) ?? "0"
    totalMileageLabel.text = "\(decimalTotalMileage)원"
  }
}
