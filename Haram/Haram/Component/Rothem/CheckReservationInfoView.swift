//
//  CheckReservationInfoView.swift
//  Haram
//
//  Created by 이건준 on 2023/08/18.
//

import UIKit

import RxSwift
import SnapKit
import Then

protocol CheckReservationInfoViewDelegate: AnyObject {
  func didTappedButton()
}

final class CheckReservationInfoView: UIView {
  
  // MARK: - Properties
  
  weak var delegate: CheckReservationInfoViewDelegate?
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private let titleLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .bold18
    $0.text = "예약된 정보확인하기"
  }
  
  private let descriptionLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .regular14
    $0.text = "예정된 예약정보를 확인하고 미리 준비하세요"
    $0.numberOfLines = 0
  }
  
  private let checkReservationButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "예약확인", contentInsets: .init(top: 4, leading: 15, bottom: 4, trailing: 15))
  }
  
  // MARK: - Initializations
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  private func configureUI() {
    [titleLabel, descriptionLabel, checkReservationButton].forEach { addSubview($0) }
    titleLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
    }
    
    descriptionLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(2)
      $0.leading.bottom.equalToSuperview()
    }
    
    checkReservationButton.snp.makeConstraints {
      $0.leading.greaterThanOrEqualTo(descriptionLabel.snp.trailing)
      $0.trailing.centerY.equalToSuperview()
      $0.height.equalTo(25)
    }
  }
  
  private func bind() {
    checkReservationButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedButton()
      }
      .disposed(by: disposeBag)
  }
}
