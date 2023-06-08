//
//  ChapelCollectionHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/05/07.
//

import UIKit

import SnapKit
import Then

struct ChapelCollectionHeaderViewModel {
  let chapelDayViewModel: String
  let chapelInfoViewModel: ChapelInfoViewModel
}

final class ChapelCollectionHeaderView: UICollectionReusableView {
  
  static let identifier = "ChapelCollectionHeaderView"
  
  private let containerStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 19.5
    $0.alignment = .center
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .hex9F9FA4
  }
  
  private let lineView1 = UIView().then {
    $0.backgroundColor = .hex9F9FA4
  }
  
  private let chapelDayView = ChapelDayView()
  
  private let chapelInfoView = ChapelInfoView()
  
  private let sectionTitleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .bold
    $0.sizeToFit()
    $0.text = "채플정보"
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    addSubview(containerStackView)
    [chapelDayView, lineView, chapelInfoView, lineView1, sectionTitleLabel].forEach { containerStackView.addArrangedSubview($0) }
    
    containerStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(59)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    chapelDayView.snp.makeConstraints {
      $0.height.equalTo(82)
      $0.width.equalTo(93)
    }
    
    chapelInfoView.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalToSuperview().inset(57)
      $0.height.equalTo(46)
    }
    
    lineView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.directionalHorizontalEdges.equalToSuperview().inset(30)
    }
    
    lineView1.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.directionalHorizontalEdges.equalToSuperview().inset(30)
    }
    
    sectionTitleLabel.snp.makeConstraints {
      $0.leading.equalToSuperview()
    }
    
    containerStackView.setCustomSpacing(72, after: chapelDayView)
  }
  
  func configureUI(with model: ChapelCollectionHeaderViewModel?) {
    guard let model = model else { return }
    chapelDayView.configureUI(with: model.chapelDayViewModel)
    chapelInfoView.configureUI(with: .init(
      attendanceDays: model.chapelInfoViewModel.attendanceDays,
      remainDays: model.chapelInfoViewModel.remainDays,
      lateDays: model.chapelInfoViewModel.lateDays)
    )
  }
}
