//
//  MoreCategoryViewController.swift
//  Haram
//
//  Created by 이건준 on 3/13/24.
//

import UIKit

import RxSwift
import SnapKit
import SkeletonView
import Then

final class MoreCategoryViewController: BaseViewController {
  
  private let viewModel: SelectedCategoryNoticeViewModelType
  private let noticeType: NoticeType
  
  private var noticeModel: [NoticeCollectionViewCellModel] = []
  
  private lazy var noticeCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.scrollDirection = .vertical
      $0.minimumLineSpacing = 20
    }
  ).then {
    $0.backgroundColor = .white
    $0.register(NoticeCollectionViewCell.self, forCellWithReuseIdentifier: NoticeCollectionViewCell.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.showsVerticalScrollIndicator = true
    $0.contentInsetAdjustmentBehavior = .always
    $0.isSkeletonable = true
    $0.contentInset = .init(top: 20, left: .zero, bottom: 15, right: .zero)
  }
  
  init(noticeType: NoticeType, viewModel: SelectedCategoryNoticeViewModelType = SelectedCategoryNoticeViewModel()) {
    self.viewModel = viewModel
    self.noticeType = noticeType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    viewModel.noticeType.onNext(noticeType)
    
    viewModel.noticeCollectionViewCellModel
      .drive(with: self) { owner, noticeModel in
        owner.noticeModel = noticeModel
        
        owner.view.hideSkeleton()
        owner.noticeCollectionView.reloadData()
      }
      .disposed(by: disposeBag)
    
    noticeCollectionView.rx.didScroll
      .subscribe(with: self) { owner, _ in
        let offSetY = owner.noticeCollectionView.contentOffset.y
        let contentHeight = owner.noticeCollectionView.contentSize.height
        
        if offSetY > (contentHeight - owner.noticeCollectionView.frame.size.height - 92 * 3) {
          owner.viewModel.fetchMoreDatas.onNext(())
        }
      }
      .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요.", viewController: owner) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
            owner.navigationController?.popViewController(animated: true)
          }
        }
      }
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()
    setupBackButton()
    setupSkeletonView()
    navigationController?.interactivePopGestureRecognizer?.delegate = self
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(noticeCollectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    noticeCollectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
}

extension MoreCategoryViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let vc = NoticeDetailViewController(type: noticeType, path: noticeModel[indexPath.row].path)
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
    
    if collectionView == noticeCollectionView {
      let cell = collectionView.cellForItem(at: indexPath) as? NoticeCollectionViewCell ?? NoticeCollectionViewCell()
      cell.setHighlighted(isHighlighted: true)
//      let pressedDownTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//      UIView.transition(with: cell, duration: 0.1) {
//        cell.alpha = 0.5
//        cell.transform = pressedDownTransform
//      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
    
    if collectionView == noticeCollectionView {
      let cell = collectionView.cellForItem(at: indexPath) as? NoticeCollectionViewCell ?? NoticeCollectionViewCell()
      cell.setHighlighted(isHighlighted: false)
//      let originalTransform = CGAffineTransform(scaleX: 1, y: 1)
//      UIView.transition(with: cell, duration: 0.1) {
//        cell.alpha = 1
//        cell.transform = .identity
//      }
    }
  }
}

extension MoreCategoryViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return noticeModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoticeCollectionViewCell.identifier, for: indexPath) as? NoticeCollectionViewCell ?? NoticeCollectionViewCell()
    cell.configureUI(with: noticeModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    CGSize(width: collectionView.frame.width - 30, height: 92)
  }
  
  
}

extension MoreCategoryViewController: BackButtonHandler {
  func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

extension MoreCategoryViewController: SkeletonCollectionViewDataSource {
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
    NoticeCollectionViewCell.identifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    skeletonView.dequeueReusableCell(withReuseIdentifier: NoticeCollectionViewCell.identifier, for: indexPath) as? NoticeCollectionViewCell
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    10
  }
}

extension MoreCategoryViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}
