//
//  NoticeViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/28.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import SkeletonView
import Then

final class NoticeViewController: BaseViewController {
  
  // MARK: - Property
  
  private let viewModel: NoticeViewModel
  
  // MARK: - UI Components
  
  private let scrollView = UIScrollView().then {
    $0.alwaysBounceVertical = true
    $0.backgroundColor = .clear
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
    $0.isSkeletonable = true
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 20
    $0.alignment = .fill
    $0.distribution = .fill
    $0.isSkeletonable = true
  }
  
  private let noticeCategoryView = NoticeCollectionHeaderView()
  private let noticeListView = NoticeListView()
  
  // MARK: - Initializations
  
  init(viewModel: NoticeViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  override func bind() {
    super.bind()
    
    let input = NoticeViewModel.Input(
      viewDidLoad: .just(()),
      viewWillAppear: self.rx.methodInvoked(#selector(UIViewController.viewWillAppear)).map { _ in Void() }, 
      didTapBackButton: navigationItem.leftBarButtonItem!.rx.tap.asObservable(), 
      didTapNoticeCell: noticeListView.noticeCollectionView.rx.itemSelected.asObservable(), 
      didTapCategoryCell: noticeCategoryView.categoryCollectionView.rx.itemSelected.asObservable()
    )
    let output = viewModel.transform(input: input)
    
    Observable.combineLatest(
      output.noticeModelRelay,
      output.noticeTagModelRelay
    )
    .subscribe(with: self) { owner, result in
      let (noticeModel, noticeTagModel) = result
      owner.noticeListView.configureUI(with: noticeModel)
      owner.noticeCategoryView.configureUI(with: noticeTagModel)  
      owner.view.hideSkeleton()
    }
    .disposed(by: disposeBag)
    
    output.errorMessageRelay
      .asSignal(onErrorSignalWith: .empty())
      .emit(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요.", viewController: owner) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          }
        }
      }
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "공지사항"
    setupBackButton()
    setupSkeletonView()
    
    noticeListView.noticeCollectionView.delegate = self
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    
    let subViews = [noticeCategoryView, noticeListView]
    containerView.addArrangedDividerSubViews(subViews, thickness: 10)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
  }
}

extension NoticeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView == noticeListView.noticeCollectionView {
      return .init(width: collectionView.frame.width, height: 92)
    }
    return .zero
  }
  
  func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
    if collectionView == noticeListView.noticeCollectionView {
      let cell = collectionView.cellForItem(at: indexPath) as? NoticeCollectionViewCell ?? NoticeCollectionViewCell()
      cell.setHighlighted(isHighlighted: true)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
    if collectionView == noticeListView.noticeCollectionView {
      let cell = collectionView.cellForItem(at: indexPath) as? NoticeCollectionViewCell ?? NoticeCollectionViewCell()
      cell.setHighlighted(isHighlighted: false)
    }
  }
}

extension NoticeViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}
