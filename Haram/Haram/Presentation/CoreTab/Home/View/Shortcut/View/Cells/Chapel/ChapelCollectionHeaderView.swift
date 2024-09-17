//
//  ChapelCollectionHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/05/07.
//

import UIKit

import SnapKit
import SkeletonView
import Then

struct ChapelCollectionHeaderViewModel {
  let chapelDayViewModel: String
  let chapelInfoViewModel: ChapelInfoViewModel
}

final class ChapelCollectionHeaderView: UICollectionReusableView, ReusableView {
  
  private let containerStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 20
    $0.alignment = .center
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .hexD8D8DA
  }
  
  private let lineView1 = UIView().then {
    $0.backgroundColor = .hexD8D8DA
  }
  
  private let chapelDayView = ChapelDayView()
  
  private let chapelInfoView = ChapelInfoView()
  
  private let chapelAlertView = IntranetAlertView(type: .chapel)
  
  private let sectionTitleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .bold22
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
    isSkeletonable = true
    containerStackView.isSkeletonable = true
    
    addSubview(containerStackView)
    [chapelDayView, lineView, chapelInfoView, lineView1, chapelAlertView, sectionTitleLabel].forEach {
      $0.isSkeletonable = true
      containerStackView.addArrangedSubview($0)
    }
    
    containerStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(59)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    chapelDayView.snp.makeConstraints {
      $0.height.equalTo(82)
    }
    
    chapelInfoView.snp.makeConstraints {
      $0.height.equalTo(46)
    }
    
    lineView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.directionalHorizontalEdges.equalToSuperview()
    }
    
    lineView1.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.directionalHorizontalEdges.equalToSuperview()
    }
    
    sectionTitleLabel.snp.makeConstraints {
      $0.leading.equalToSuperview()
    }
    
    chapelAlertView.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(45)
    }
    
    containerStackView.setCustomSpacing(72, after: chapelDayView)
  }
  
  func configureUI(with model: ChapelCollectionHeaderViewModel?) {
    guard let model = model else { return }
    chapelDayView.configureUI(with: model.chapelDayViewModel)
    chapelInfoView.configureUI(with: .init(
      regulateDays: model.chapelInfoViewModel.regulateDays,
      remainDays: model.chapelInfoViewModel.remainDays,
      lateDays: model.chapelInfoViewModel.lateDays, 
      completionDays: model.chapelInfoViewModel.completionDays
    ))
  }
}
