//
//  BoardDetailTopView.swift
//  Haram
//
//  Created by 이건준 on 2023/09/20.
//

import UIKit

import RxSwift
import SkeletonView
import SnapKit
import Then

struct BoardDetailHeaderViewModel {
  let boardSeq: Int
  let boardTitle: String
  let boardContent: String
  let boardDate: Date
  let boardAuthorName: String
  let isUpdatable: Bool
}

final class BoardDetailTopView: UIView {
  private let disposeBag = DisposeBag()
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .clear
    $0.spacing = 7
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 22, left: 15, bottom: .zero, right: 15)
    $0.isSkeletonable = true
  }
  
  let postingTitleLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.isSkeletonable = true
    $0.skeletonTextNumberOfLines = 1
  }
  
  let postingInfoView = PostingInfoView()
  
  let postingDescriptionLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.isSkeletonable = true
    $0.skeletonTextNumberOfLines = 3
  }
  
  lazy var boardImageCollectionView = AutoSizingCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
    $0.scrollDirection = .horizontal
    $0.minimumLineSpacing = 0
  }).then {
    $0.register(BoardImageCollectionViewCell.self)
    $0.isPagingEnabled = true
    $0.showsHorizontalScrollIndicator = false
    $0.isSkeletonable = true
  }
  
  let pageControl = UIPageControl().then {
    $0.currentPage = 0
    $0.pageIndicatorTintColor = .systemGray2
    $0.currentPageIndicatorTintColor = UIColor.hex79BD9A
    $0.isSkeletonable = true
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func pageControlValueChanged(currentPage: Int) {
    boardImageCollectionView.isPagingEnabled = false
    boardImageCollectionView.scrollToItem(at: .init(row: currentPage, section: 0), at: .left, animated: true)
    boardImageCollectionView.isPagingEnabled = true
  }
  
  private func bind() {
    pageControl.rx.controlEvent(.valueChanged)
      .subscribe(with: self) { owner,  _ in
        owner.pageControlValueChanged(currentPage: owner.pageControl.currentPage)
      }
      .disposed(by: disposeBag)
  }
  
  private func configureUI() {
    isSkeletonable = true
    containerView.isSkeletonable = true
    
    _ = [postingTitleLabel, postingInfoView, postingDescriptionLabel].map { $0.isSkeletonable = true }
    
    _ = [containerView].map { addSubview($0) }
    _ = [postingTitleLabel, postingInfoView, postingDescriptionLabel, boardImageCollectionView, pageControl].map { containerView.addArrangedSubview($0) }
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    boardImageCollectionView.snp.makeConstraints {
      $0.height.equalTo(188)
    }
    
    containerView.setCustomSpacing(222 - 162 - 38, after: postingInfoView)
    containerView.setCustomSpacing(397 - 222 - 157, after: postingDescriptionLabel)
  }
}

extension BoardDetailTopView {
  
  final class PostingInfoView: UIView {
    
    private let postingAuthorAndDateLabel = UILabel().then {
      $0.font = .regular14
      $0.textColor = .black
    }
    
    let boardDeleteButton = UIButton(configuration: .haramLabelButton(title: "삭제", font: .regular14, forgroundColor: .black)).then {
      $0.sizeToFit()
    }
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      configureUI()
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
      _ = [postingAuthorAndDateLabel, boardDeleteButton].map { addSubview($0) }
      
      boardDeleteButton.snp.makeConstraints {
        $0.directionalVerticalEdges.trailing.equalToSuperview()
      }
      
      postingAuthorAndDateLabel.snp.makeConstraints {
        $0.directionalVerticalEdges.leading.equalToSuperview()
        $0.trailing.lessThanOrEqualTo(boardDeleteButton.snp.leading)
      }
    }
    
    func configureUI(isUpdatable: Bool, content: String) {
      postingAuthorAndDateLabel.text = content
      boardDeleteButton.isHidden = !isUpdatable
    }
  }
}
