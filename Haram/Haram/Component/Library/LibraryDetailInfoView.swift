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
    [titleLabel, contentLabel].forEach {
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
  }
}

final class LibraryDetailInfoView: UIView {
  
  private let containerView = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .fill
    $0.distribution = .equalSpacing
  }
  
  private let authorInfoView = LibraryInfoView()
  private let publisherInfoView = LibraryInfoView()
  private let pubDateInfoView = LibraryInfoView()
  private let discountInfoView = LibraryInfoView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    
    addSubview(containerView)
    containerView.snp.makeConstraints {
      $0.directionalVerticalEdges.equalToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
    }
    
    let subViews = [authorInfoView, publisherInfoView, pubDateInfoView, discountInfoView]
    containerView.addArrangedDividerSubViews(subViews, isVertical: true)
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
