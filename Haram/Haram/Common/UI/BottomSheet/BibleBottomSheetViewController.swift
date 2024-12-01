//
//  BibleBottomSheetViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import UIKit

import SnapKit
import Then

protocol BibleBottomSheetViewControllerDelegate: AnyObject {
  func didTappedRevisionOfTranslation(bibleName: String)
  func didTappedChapter(chapter: String)
}

enum BibleBottomSheetViewType {
  case revisionOfTranslation([RevisionOfTranslationModel])
  case chapter([Int])
}

final class BibleBottomSheetViewController: BottomSheetViewController {
  
  weak var delegate: BibleBottomSheetViewControllerDelegate?
  
  private let type: BibleBottomSheetViewType
  
  private let bibleCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    $0.register(BibleCollectionViewCell.self)
  }
  
  init(type: BibleBottomSheetViewType) {
    self.type = type
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    /// Set CollectionView delegate & dataSource
    bibleCollectionView.delegate = self
    bibleCollectionView.dataSource = self
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    contentView.addSubview(bibleCollectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    bibleCollectionView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(Metrics.Margin.top)
      $0.directionalHorizontalEdges.equalToSuperview().inset(Metrics.Margin.horizontal)
      $0.height.equalTo(UIScreen.main.bounds.height - 200)
      $0.bottom.equalToSuperview().inset(Metrics.Margin.bottom)
    }
  }
}

extension BibleBottomSheetViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch type {
    case let .revisionOfTranslation(model):
      return model.count
    case let .chapter(model):
      return model.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch type {
      case let .revisionOfTranslation(model):
      let cell = collectionView.dequeueReusableCell(BibleCollectionViewCell.self, for: indexPath) ?? BibleCollectionViewCell()
        cell.configureUI(with: model[indexPath.row].bibleName)
        return cell
      case let .chapter(model):
        let cell = collectionView.dequeueReusableCell(BibleCollectionViewCell.self, for: indexPath) ?? BibleCollectionViewCell()
        cell.configureUI(with: "\(model[indexPath.row])장")
        return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 50)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath) as? BibleCollectionViewCell ?? BibleCollectionViewCell()
    cell.showAnimation { [weak self] in
      guard let self = self else { return }
      switch self.type {
      case let .revisionOfTranslation(model):
        self.delegate?.didTappedRevisionOfTranslation(bibleName: model[indexPath.row].bibleName)
      case let .chapter(model):
        self.delegate?.didTappedChapter(chapter: "\(model[indexPath.row])")
      }
      self.dismiss(animated: true)
    }
  }
}
