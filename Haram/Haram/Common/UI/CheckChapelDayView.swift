//
//  CheckChapelDayView.swift
//  Haram
//
//  Created by 이건준 on 1/18/24.
//

import UIKit

import SnapKit
import Then

struct CheckChapelDayViewModel {
  let regulatedDay: String
  let chapelDay: String
}

/// 홈 메인에서 특정 시간대에 채플 일 수를 확인할 수 있는 뷰
final class CheckChapelDayView: UIView {
  
  private let dayImageView = UIImageView(image: UIImage(resource: .bibleCheck)).then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 20
    $0.contentMode = .scaleAspectFill
  }
  
  private let regulatedCheckChapelLabelView = CheckChapelLabelView(type: .regulated)
  private let chapelCheckChapelLabelView = CheckChapelLabelView(type: .chapel)
  
  private let containerView = UIStackView().then {
    $0.axis = .horizontal
    $0.distribution = .equalSpacing
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 350.5 - 337, left: .zero, bottom: 454.5 - 442, right: .zero)
  }
  
  private let verticalLineView = UIView().then {
    $0.backgroundColor = .white
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    
    skeletonCornerRadius = 10
    
    backgroundColor = .hex3B8686
    layer.masksToBounds = true
    layer.cornerRadius = 10
    
    _ = [dayImageView, containerView].map { addSubview($0) }
    _ = [regulatedCheckChapelLabelView, verticalLineView, chapelCheckChapelLabelView].map { containerView.addArrangedSubview($0) }
    
    dayImageView.snp.makeConstraints {
      $0.size.equalTo(40)
      $0.leading.equalToSuperview().inset(34 - 15)
      $0.centerY.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.directionalVerticalEdges.equalToSuperview()
      $0.leading.equalTo(dayImageView.snp.trailing).offset(105 - 15 - 40 - 19)
      $0.trailing.equalToSuperview().inset(105 - 15 - 40 - 19)
    }
    
    verticalLineView.snp.makeConstraints {
      $0.width.equalTo(1)
      $0.directionalVerticalEdges.equalToSuperview().inset(350.5 - 337)
    }
  }
  
  func configureUI(with model: CheckChapelDayViewModel) {
    regulatedCheckChapelLabelView.configureUI(with: model.regulatedDay)
    chapelCheckChapelLabelView.configureUI(with: model.chapelDay)
  }
}

enum ChapelCheckType {
  case regulated
  case chapel
  
  var text: String {
    switch self {
    case .regulated:
      return "규정일수"
    case .chapel:
      return "채플이수"
    }
  }
}

final class CheckChapelLabelView: UIView {
  
  private let type: ChapelCheckType
  
  private let titleLabel = UILabel().then {
    $0.font = .bold20
    $0.textColor = .white
    $0.text = "규정일수"
  }
  
  private let dayLabel = UILabel().then {
    $0.font = .regular16
    $0.textColor = .white
    $0.text = "53일"
  }
  
  init(type: ChapelCheckType) {
    self.type = type
    super.init(frame: .zero)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    _ = [titleLabel, dayLabel].map { addSubview($0) }
    titleLabel.snp.makeConstraints {
      $0.directionalHorizontalEdges.top.equalToSuperview()
    }
    
    dayLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom)
      $0.leading.bottom.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }
    
    titleLabel.text = type.text
  }
  
  func configureUI(with model: String) {
    dayLabel.text = model + "일"
  }
}
