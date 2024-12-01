//
//  BoardDetailHeaderView.swift
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
  let boardImageCollectionViewCellModel: [BoardImageCollectionViewCellModel]
  let isUpdatable: Bool
}

protocol BoardDetailHeaderViewDelegate: AnyObject {
  func didTappedBoardImage(url: URL?)
}

final class BoardDetailHeaderView: UICollectionReusableView, ReusableView {
  
  weak var delegate: BoardDetailHeaderViewDelegate?

  private let disposeBag = DisposeBag()
  private let currentBannerPage = PublishSubject<Int>()
  
  private var boardSeq: Int?
  
  private var boardImageCollectionViewCellModel: [BoardImageCollectionViewCellModel] = [] {
    didSet {
      boardImageCollectionView.reloadData()
      pageControl.numberOfPages = boardImageCollectionViewCellModel.count
    }
  }
   
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .clear
    $0.spacing = 6
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 22, left: 15, bottom: 27.5, right: 15)
    $0.isSkeletonable = true
  }

  private let postingTitleLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.isSkeletonable = true
    $0.skeletonTextNumberOfLines = 1
  }
  
  let postingInfoView = PostingInfoView()
  
  private let postingDescriptionLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.isSkeletonable = true
    $0.skeletonTextNumberOfLines = 3
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .hexD8D8DA
    $0.isSkeletonable = true
  }
  
  private lazy var boardImageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
    $0.scrollDirection = .horizontal
    $0.minimumLineSpacing = 0
  }).then {
    $0.delegate = self
    $0.dataSource = self
    $0.register(BoardImageCollectionViewCell.self)
    $0.isPagingEnabled = true
    $0.showsHorizontalScrollIndicator = false
    $0.isSkeletonable = true
  }
  
  private let pageControl = UIPageControl().then {
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
  
  override func prepareForReuse() {
    super.prepareForReuse()
    postingTitleLabel.text = nil
    postingDescriptionLabel.text = nil
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
    
    currentBannerPage
      .asDriver(onErrorDriveWith: .empty())
      .drive(pageControl.rx.currentPage)
      .disposed(by: disposeBag)
    
//    postingInfoView.boardDeleteButton.rx.tap
//      .subscribe(with: self) { owner, _ in
//        owner.postingInfoView.boardDeleteButton.showAnimation {
//          owner.delegate?.didTappedDeleteButton(boardSeq: owner.boardSeq!)
//        }
//      }
//      .disposed(by: disposeBag)
  }
  
  private func configureUI() {
    isSkeletonable = true
    containerView.isSkeletonable = true
    
    _ = [postingTitleLabel, postingInfoView, postingDescriptionLabel].map { $0.isSkeletonable = true }
    
    _ = [containerView, lineView].map { addSubview($0) }
    _ = [postingTitleLabel, postingInfoView, postingDescriptionLabel].map { containerView.addArrangedSubview($0) }
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    lineView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.top.equalTo(containerView.snp.bottom)
      $0.directionalHorizontalEdges.equalToSuperview()
    }

    containerView.setCustomSpacing(222 - 162 - 38, after: postingInfoView)
    containerView.setCustomSpacing(397 - 222 - 157, after: postingDescriptionLabel)
  }
  
  func configureUI(with model: BoardDetailHeaderViewModel?) {
    guard let model = model else { return }
    postingTitleLabel.text = model.boardTitle
    postingDescriptionLabel.addLineSpacing(lineSpacing: 2, string: model.boardContent)
    postingInfoView.configureUI(with: (model.isUpdatable, DateformatterFactory.dateWithSlash.string(from: model.boardDate) + " | " + model.boardAuthorName))
    boardSeq = model.boardSeq
    
    if !model.boardImageCollectionViewCellModel.isEmpty {
      [boardImageCollectionView, pageControl].forEach { containerView.addArrangedSubview($0) }
      
      boardImageCollectionView.snp.makeConstraints {
        $0.height.equalTo(188)
      }
      
      pageControl.snp.makeConstraints {
        $0.height.equalTo(20)
      }
      
      boardImageCollectionViewCellModel = model.boardImageCollectionViewCellModel
    }
  }
}

extension BoardDetailHeaderView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    boardImageCollectionViewCellModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(BoardImageCollectionViewCell.self, for: indexPath) ?? BoardImageCollectionViewCell()
    cell.configureUI(with: boardImageCollectionViewCellModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let model = boardImageCollectionViewCellModel[indexPath.row]
    delegate?.didTappedBoardImage(url: model.imageURL)
  }
}

extension BoardDetailHeaderView: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 188)
  }
}

extension BoardDetailHeaderView: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard scrollView == boardImageCollectionView else { return }
    let contentOffset = scrollView.contentOffset
    let bannerIndex = Int(max(0, round(contentOffset.x / scrollView.bounds.width)))
    
    self.currentBannerPage.onNext(bannerIndex)
  }
}

extension BoardDetailHeaderView {
  
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
    
    func configureUI(with model: (isUpdatable: Bool, content: String)) {
      postingAuthorAndDateLabel.text = model.content
      boardDeleteButton.isHidden = !model.isUpdatable
    }
  }
}
