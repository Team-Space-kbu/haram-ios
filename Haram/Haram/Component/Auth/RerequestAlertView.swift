//
//  RerequestAlertView.swift
//  Haram
//
//  Created by 이건준 on 10/18/23.
//

import UIKit

import RxSwift
import SnapKit
import Then

protocol RerequestAlertViewDelegate: AnyObject {
  func didTappedRequestAuthCode()
}

final class RerequestAlertView: UIView {
  
  private let disposeBag = DisposeBag()
  weak var delegate: RerequestAlertViewDelegate?
  
  private let alertLabel = UILabel().then {
    $0.textColor = .hex545E6A
    $0.font = .regular14
    $0.text = "이메일이 도착하지 않았나요?"
  }
  
  private let reRequestButton = UIButton().then {
    let attributedTitle = NSAttributedString(
      string: "재요청하기",
      attributes: [.font: UIFont.regular14, .foregroundColor: UIColor.hex2F80ED]
    )
    $0.setAttributedTitle(attributedTitle, for: .normal)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func bind() {
    reRequestButton.rx.tap
      .throttle(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedRequestAuthCode()
      }
      .disposed(by: disposeBag)
  }
  
  private func configureUI() {
    [alertLabel, reRequestButton].forEach { addSubview($0) }
    alertLabel.snp.makeConstraints {
      $0.leading.directionalVerticalEdges.equalToSuperview()
    }
    
    reRequestButton.snp.makeConstraints {
      $0.leading.equalTo(alertLabel.snp.trailing).offset(6)
      $0.directionalVerticalEdges.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }
  }
}
