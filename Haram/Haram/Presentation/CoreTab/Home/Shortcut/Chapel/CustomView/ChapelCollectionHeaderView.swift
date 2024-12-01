////
////  ChapelCollectionHeaderView.swift
////  Haram
////
////  Created by 이건준 on 2023/05/07.
////
//
//import UIKit
//
//import SnapKit
//import SkeletonView
//import Then
//
struct ChapelCollectionHeaderViewModel {
  let chapelDayViewModel: String
  let chapelInfoViewModel: [ChapelDetailInfoViewModel]
}
//
//final class ChapelCollectionHeaderView: UICollectionReusableView, ReusableView {
//  
//  private let containerStackView = UIStackView().then {
//    $0.axis = .vertical
//    $0.spacing = 20
//    $0.alignment = .center
//  }
//  
//  private let chapelDayView = ChapelDayView()
//  
//  private let chapelDetailInfoView = ChapelDetailInfoView()
//  
////  private let chapelAlertView = IntranetAlertView(type: .chapel)
//  
//  private let sectionTitleLabel = UILabel().then {
//    $0.textColor = .black
//    $0.font = .bold22
//    $0.text = "채플정보"
//  }
//  
//  override init(frame: CGRect) {
//    super.init(frame: frame)
//    configureUI()
//  }
//  
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//  
//  private func configureUI() {
//    isSkeletonable = true
//    containerStackView.isSkeletonable = true
//    
//    addSubview(containerStackView)
//    let subViews = [chapelDayView, chapelDetailInfoView, chapelAlertView, sectionTitleLabel]
//    containerStackView.addArrangedDividerSubViews(subViews, thickness: 10)
//    
//    subViews.forEach { $0.isSkeletonable = true }
//    
//    containerStackView.snp.makeConstraints {
//      $0.top.equalToSuperview().inset(59)
//      $0.directionalHorizontalEdges.equalToSuperview()
//      $0.bottom.lessThanOrEqualToSuperview()
//    }
//    
//    chapelDayView.snp.makeConstraints {
//      $0.height.equalTo(82)
//    }
//    
//    chapelDetailInfoView.snp.makeConstraints {
//      $0.height.equalTo(46)
//    }
//    
//    sectionTitleLabel.snp.makeConstraints {
//      $0.leading.equalToSuperview()
//    }
//    
//    chapelAlertView.snp.makeConstraints {
//      $0.directionalHorizontalEdges.equalToSuperview()
//      $0.height.equalTo(45)
//    }
//    
//    containerStackView.setCustomSpacing(72, after: chapelDayView)
//  }
//  
//  func configureUI(with model: ChapelCollectionHeaderViewModel?) {
//    guard let model = model else { return }
//    chapelDayView.configureUI(with: model.chapelDayViewModel)
////    chapelDetailInfoView.configureUI(with: .init(
////      regulateDays: model.chapelInfoViewModel.regulateDays,
////      remainDays: model.chapelInfoViewModel.remainDays,
////      lateDays: model.chapelInfoViewModel.lateDays, 
////      completionDays: model.chapelInfoViewModel.completionDays
////    ))
//  }
//}
