//
//  LibraryDetailInfoView.swift
//  Haram
//
//  Created by 이건준 on 2023/06/07.
//

import UIKit

import SnapKit
import SkeletonView
import Then

enum LibraryDetailInfoViewType: CaseIterable {
  case author
  case publisher
  case publishDate
  case discount
  
  var title: String {
    switch self {
    case .author:
      return "저자"
    case .publisher:
      return "출판사"
    case .publishDate:
      return "출간일"
    case .discount:
      return "판매가격"
    }
  }
}

struct LibraryInfoViewModel {
  let title: String
  let content: String
}

final class LibraryInfoView: UIView {
  
  private let titleLabel = UILabel().then {
    $0.textColor = .hex9F9FA4
    $0.font = .regular14
    $0.textAlignment = .center
  }
  
  private let contentLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .bold18
    $0.numberOfLines = 3
    $0.textAlignment = .center
    $0.lineBreakMode = .byTruncatingTail
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
    [titleLabel, contentLabel].forEach {
      $0.isSkeletonable = true
      addSubview($0)
    }
    titleLabel.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(18)
    }
    
    contentLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(8)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
  }
  
  func configureUI(with model: LibraryInfoViewModel) {
    titleLabel.text = model.title
    contentLabel.text = model.content.trimmingCharacters(in: .whitespacesAndNewlines)
//    model.content.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}

final class LibraryDetailInfoView: UIView {
  
  private let containerView = UIStackView().then {
    $0.axis = .horizontal
//    $0.distribution = .equalSpacing
    $0.spacing = 3
    $0.alignment = .top
  }
  
  private let authorInfoView = LibraryInfoView()
  private let publisherInfoView = LibraryInfoView()
  private let pubDateInfoView = LibraryInfoView()
  private let discountInfoView = LibraryInfoView()
  
  private lazy var lineView = UIView().then {
    $0.backgroundColor = .hexD8D8DA
  }
  
  private lazy var lineView1 = UIView().then {
    $0.backgroundColor = .hexD8D8DA
  }
  
  private lazy var lineView2 = UIView().then {
    $0.backgroundColor = .hexD8D8DA
  }
  
  private lazy var lineView3 = UIView().then {
    $0.backgroundColor = .hexD8D8DA
  }
  
  private lazy var lineView4 = UIView().then {
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
    isSkeletonable = true
    addSubview(containerView)
    [authorInfoView, lineView, publisherInfoView, lineView1, pubDateInfoView, lineView2, discountInfoView].forEach {
      $0.isSkeletonable = true
      containerView.addArrangedSubview($0)
    }
    
    [authorInfoView, publisherInfoView, pubDateInfoView, discountInfoView].forEach {
      $0.snp.makeConstraints {
        $0.width.equalTo((UIScreen.main.bounds.width - 3 - 60) / 4)
      }
    }
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    [lineView, lineView1, lineView2].forEach {
      $0.snp.makeConstraints {
        $0.width.equalTo(1)
//        $0.height.equalTo(47.5)
        $0.centerY.height.equalToSuperview()
//        $0.directionalVerticalEdges.equalToSuperview()
      }
    }
  }
  
  func configureUI(with model: [LibraryInfoViewModel]) {
    guard LibraryDetailInfoViewType.allCases.count == model.count else { return }
    
    [authorInfoView, publisherInfoView, pubDateInfoView, discountInfoView].enumerated().forEach { index, vw in
      
      vw.configureUI(with: .init(
        title: LibraryDetailInfoViewType.allCases[index].title,
        content: model[index].content
      ))
    }
  }
}
