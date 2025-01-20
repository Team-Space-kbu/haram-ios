//
//  CourseListViewController.swift
//  Haram
//
//  Created by 이건준 on 10/12/24.
//

import UIKit

import SkeletonView

final class CourseListViewController: ViewController {
  let viewModel: CourseListViewModel
  let viewHolder: CourseListViewHolder = CourseListViewHolder()
  
  init(viewModel: CourseListViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    viewHolderConfigure()
    viewHolder.lectureListView.dataSource = self
    setupBackButton()
  }
  
  override func bind() {
    super.bind()
    let input = CourseListViewModel.Input(
      viewDidLoad: .just(()),
      didTapBackButton: navigationItem.leftBarButtonItem!.rx.tap.asObservable(),
      didTapLectureCell: viewHolder.lectureListView.rx.itemSelected.asObservable()
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
          owner.viewHolder.lectureListView.reloadData()
        }
      }
      .disposed(by: disposeBag)
    
    viewHolder.lectureListView.rx.setDelegate(self).disposed(by: disposeBag)
    output.errorMessage
      .subscribe(with: self) { owner, error in
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

extension CourseListViewController {
  private func bindNotificationCenter(input: CourseListViewModel.Input) {
    NotificationCenter.default.rx.notification(.refreshWhenNetworkConnected)
      .map { _ in Void() }
      .bind(to: input.didConnectNetwork)
      .disposed(by: disposeBag)
  }
}

extension CourseListViewController: SkeletonCollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    viewModel.output.lectureList.value.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(LectureInfoCollectionViewCell.self, for: indexPath) ?? LectureInfoCollectionViewCell()
    let model = viewModel.output.lectureList.value[indexPath.row]
    cell.configureUI(with: .init(boardSeq: 0, title: model.title, subTitle: model.professorName, boardType: model.types))
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    .init(width: collectionView.frame.width, height: 92)
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
    LectureInfoCollectionViewCell.reuseIdentifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    4
  }
  
  func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
    if collectionView == viewHolder.lectureListView {
      let cell = collectionView.cellForItem(at: indexPath) as? LectureInfoCollectionViewCell ?? LectureInfoCollectionViewCell()
      cell.setHighlighted(isHighlighted: true)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
    if collectionView == viewHolder.lectureListView {
      let cell = collectionView.cellForItem(at: indexPath) as? LectureInfoCollectionViewCell ?? LectureInfoCollectionViewCell()
      cell.setHighlighted(isHighlighted: false)
    }
  }
}

