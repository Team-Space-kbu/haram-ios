//
//  CampusBuildingListViewController.swift
//  Haram
//
//  Created by 이건준 on 10/7/24.
//

import UIKit

import SkeletonView

final class CampusBuildingListViewController: ViewController {
  let viewModel: CampusBuildingListViewModel
  let viewHolder: CampusBuildingListViewHolder = CampusBuildingListViewHolder()
  
  init(viewModel: CampusBuildingListViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "빈강의실 찾기"
    
    viewHolderConfigure()
    viewHolder.classListView.alertListView.delegate = self
    viewHolder.alertInfoListView.alertListView.delegate = self
    viewHolder.classListView.alertListView.dataSource = self
    viewHolder.alertInfoListView.alertListView.dataSource = self
    setupBackButton()
  }
  
  override func bind() {
    super.bind()
    let input = CampusBuildingListViewModel.Input(
      viewDidLoad: .just(()),
      didTapClassRoom: viewHolder.classListView.alertListView.rx.itemSelected.asObservable(), 
      didTapBackButton: navigationItem.leftBarButtonItem!.rx.tap.asObservable()
    )
    bindNotificationCenter(input: input)
    
    let output = viewModel.transform(input: input)
    output.isLoading
      .asDriver(onErrorJustReturn: true)
      .drive(with: self) { owner, isLoading in
        if isLoading {
          owner.setupSkeletonView()
        } else {
          owner.view.hideSkeleton()
          owner.viewHolder.classListView.alertListView.reloadData()
        }
      }
      .disposed(by: disposeBag)
    
    output.errorMessage
      .asSignal(onErrorSignalWith: .empty())
      .emit(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(message: .networkUnavailable, actions: [
            DefaultAlertButton {
              guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
              if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
              }
            }
          ])
        }
      }
      .disposed(by: disposeBag)
  }
}

extension CampusBuildingListViewController {
  private func bindNotificationCenter(input: CampusBuildingListViewModel.Input) {
    NotificationCenter.default.rx.notification(.refreshWhenNetworkConnected)
      .map { _ in Void() }
      .bind(to: input.didConnectNetwork)
      .disposed(by: disposeBag)
  }
}

extension CampusBuildingListViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView == viewHolder.classListView.alertListView {
      return .init(width: collectionView.frame.width, height: 46)
    } else if collectionView == viewHolder.alertInfoListView.alertListView {
      return .init(width: collectionView.frame.width, height: 41)
    }
    return .zero
  }
  
  func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) else { return }
    cell.animateView(alpha: 0.5, scale: 0.9, duration: 0.1, completion: {})
  }
  
  func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) else { return }
    cell.animateView(alpha: 1, scale: 1, duration: 0.1, completion: {})
  }
}

extension CampusBuildingListViewController: SkeletonCollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == viewHolder.classListView.alertListView {
      let cell = collectionView.dequeueReusableCell(ClassCollectionViewCell.self, for: indexPath) ?? ClassCollectionViewCell()
      cell.configureUI(title: viewModel.output.classModel.value[indexPath.row].rawValue)
      return cell
    } else if collectionView == viewHolder.alertInfoListView.alertListView {
      let cell = collectionView.dequeueReusableCell(AlertInfoViewCell.self, for: indexPath) ?? AlertInfoViewCell()
      cell.configureUI(with: viewModel.output.alertInfoModel.value[indexPath.row])
      return cell
    }
    return UICollectionViewCell()
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == viewHolder.classListView.alertListView {
      return viewModel.output.classModel.value.count
    } else if collectionView == viewHolder.alertInfoListView.alertListView {
      return viewModel.output.alertInfoModel.value.count
    }
    return 0
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
    if skeletonView == viewHolder.classListView.alertListView {
      return ClassCollectionViewCell.reuseIdentifier
    } else if skeletonView == viewHolder.alertInfoListView.alertListView {
      return AlertInfoViewCell.reuseIdentifier
    }
    return ""
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    4
  }
  
}
