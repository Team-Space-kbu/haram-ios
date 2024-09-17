//
//  DepartmentListViewController.swift
//  Haram
//
//  Created by 이건준 on 10/9/24.
//

import UIKit

import SkeletonView

final class DepartmentListViewController: ViewController {
  let viewModel: DepartmentListViewModel
  let viewHolder: DepartmentListViewHolder = DepartmentListViewHolder()
  
  init(viewModel: DepartmentListViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "수업계획서"
    viewHolderConfigure()
    viewHolder.majorListView.dataSource = self
    viewHolder.majorListView.delegate = self
    setupBackButton()
  }
  
  override func bind() {
    super.bind()
    let input = DepartmentListViewModel.Input(
      viewDidLoad: .just(()),
      didTapBackButton: navigationItem.leftBarButtonItem!.rx.tap.asObservable(), 
      didTapMajorCell: viewHolder.majorListView.rx.itemSelected.asObservable()
    )
    let output = viewModel.transform(input: input)
    output.isLoading
      .subscribe(with: self) { owner, isLoading in
        if isLoading {
          owner.setupSkeletonView()
        } else {
          owner.view.hideSkeleton()
          owner.viewHolder.majorListView.reloadData()
        }
      }
      .disposed(by: disposeBag)
  }
}

extension DepartmentListViewController: SkeletonCollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    viewModel.output.majorList.value.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(ClassCollectionViewCell.self, for: indexPath) ?? ClassCollectionViewCell()
    cell.configureUI(title: viewModel.output.majorList.value[indexPath.row].type.rawValue)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    .init(width: collectionView.frame.width, height: 46)
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
    ClassCollectionViewCell.reuseIdentifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    4
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
