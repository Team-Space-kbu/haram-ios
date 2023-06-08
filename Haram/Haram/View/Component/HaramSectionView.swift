////
////  HaramSectionView.swift
////  Haram
////
////  Created by 이건준 on 2023/04/09.
////
//
//import UIKit
//
//import SnapKit
//import Then
//
//final class HaramSectionView: UIView {
//
//  private let homeNoticeView = HomeNoticeView()
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
//    addSubview(verticalStackView)
//    verticalStackView.snp.makeConstraints {
//      $0.directionalEdges.equalToSuperview()
//    }
//
//    [homeNoticeView].forEach { verticalStackView.addArrangedSubview($0) }
//    homeNoticeView.snp.makeConstraints {
//      $0.height.equalTo(35)
//    }
//  }
//}
