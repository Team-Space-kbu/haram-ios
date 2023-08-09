//
//  LibraryDetailInfoView.swift
//  Haram
//
//  Created by 이건준 on 2023/06/07.
//

import UIKit

import SnapKit
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
//    $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
  }
  
  private let contentLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .bold18
    $0.numberOfLines = 0
    $0.textAlignment = .center
    $0.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    $0.lineBreakMode = .byWordWrapping
    
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [titleLabel, contentLabel].forEach { addSubview($0) }
    titleLabel.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
    }
    
    contentLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(8)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(18)
//      $0.bottom.lessThanOrEqualToSuperview()
    }
  }
  
  func configureUI(with model: LibraryInfoViewModel) {
    titleLabel.text = model.title
    contentLabel.text = model.content
  }
}

final class LibraryDetailInfoView: UIView {
  
  private let containerView = UIStackView().then {
    $0.axis = .horizontal
    $0.distribution = .equalSpacing
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
    [containerView].forEach { addSubview($0) }
    [authorInfoView, lineView, publisherInfoView, lineView1, pubDateInfoView, lineView2, discountInfoView].forEach { containerView.addArrangedSubview($0) }
    
    containerView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.height.equalTo(47.5)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    [lineView, lineView1, lineView2].forEach {
      $0.snp.makeConstraints {
        $0.width.equalTo(1)
        $0.height.equalTo(47.5)
      }
    }
  }
  
  func configureUI(with model: [LibraryInfoViewModel]) {
    guard LibraryDetailInfoViewType.allCases.count == model.count else { return }
    
    [authorInfoView, publisherInfoView, pubDateInfoView, discountInfoView].enumerated().forEach { index, vw in
      vw.configureUI(with: .init(title: LibraryDetailInfoViewType.allCases[index].title, content: model[index].content))
    }
  }
}
