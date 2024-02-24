//
//  BoardDetailHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/09/20.
//

import UIKit

import SnapKit
import Then

struct BoardDetailHeaderViewModel {
  let boardTitle: String
  let boardContent: String
  let boardDate: Date
  let boardAuthorName: String
  let boardImageCollectionViewCellModel: [BoardImageCollectionViewCellModel]
}

final class BoardDetailHeaderView: UICollectionReusableView {
  
  static let identifier = "BoardDetailHeaderView"
  
  private var boardImageCollectionViewCellModel: [BoardImageCollectionViewCellModel] = [] {
    didSet {
      boardImageCollectionView.reloadData()
    }
  }
   
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .clear
    $0.spacing = 6
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 22, left: 15, bottom: 27.5, right: 15)
  }

  private let postingTitleLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .black
    $0.numberOfLines = 0
  }
  
  private let postingAuthorNameLabel = UILabel().then {
    $0.font = .bold14
    $0.textColor = .black
  }
  
  private let postingDateLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .black
  }
  
  private let postingDescriptionLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .black
    $0.numberOfLines = 0
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .hexD8D8DA
  }
  
  private lazy var boardImageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
    $0.scrollDirection = .horizontal
    $0.minimumLineSpacing = 0
  }).then {
    $0.delegate = self
    $0.dataSource = self
    $0.register(BoardImageCollectionViewCell.self, forCellWithReuseIdentifier: BoardImageCollectionViewCell.identifier)
    $0.isPagingEnabled = true
    $0.showsHorizontalScrollIndicator = false
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    postingTitleLabel.text = nil
    postingDescriptionLabel.text = nil
    postingAuthorNameLabel.text = nil
    postingDateLabel.text = nil
  }
  
  private func configureUI() {
    _ = [containerView, lineView].map { addSubview($0) }
    _ = [postingTitleLabel, postingAuthorNameLabel, postingDateLabel, postingDescriptionLabel].map { containerView.addArrangedSubview($0) }
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    lineView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.top.equalTo(containerView.snp.bottom)
      $0.directionalHorizontalEdges.equalToSuperview()
    }

    containerView.setCustomSpacing(222 - 162 - 38, after: postingDateLabel)
    containerView.setCustomSpacing(397 - 222 - 157, after: postingDescriptionLabel)
  }
  
  func configureUI(with model: BoardDetailHeaderViewModel?) {
    guard let model = model else { return }
    postingTitleLabel.text = model.boardTitle
    postingDescriptionLabel.addLineSpacing(lineSpacing: 2, string: model.boardContent)
    postingAuthorNameLabel.text = model.boardAuthorName
    postingDateLabel.text = DateformatterFactory.dateWithHypen.string(from: model.boardDate)
    
    if !model.boardImageCollectionViewCellModel.isEmpty {
      containerView.addArrangedSubview(boardImageCollectionView)
      boardImageCollectionView.snp.makeConstraints {
        $0.height.equalTo(188)
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
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoardImageCollectionViewCell.identifier, for: indexPath) as? BoardImageCollectionViewCell ?? BoardImageCollectionViewCell()
    cell.configureUI(with: boardImageCollectionViewCellModel[indexPath.row])
    return cell
  }
}

extension BoardDetailHeaderView: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 188)
  }
}
