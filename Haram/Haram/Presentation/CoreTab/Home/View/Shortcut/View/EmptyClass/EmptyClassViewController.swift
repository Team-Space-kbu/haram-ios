//
//  EmptyClassViewController.swift
//  Haram
//
//  Created by 이건준 on 10/7/24.
//

import UIKit

import SkeletonView

final class EmptyClassViewController: ViewController, BackButtonHandler {
  let viewModel: EmptyClassViewModel
  let viewHolder: EmptyClassViewHolder = EmptyClassViewHolder()
  
  init(viewModel: EmptyClassViewModel = EmptyClassViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    viewHolderConfigure()
    viewHolder.classListView.alertListView.delegate = self
    viewHolder.alertInfoListView.alertListView.delegate = self
    viewHolder.classListView.alertListView.dataSource = self
    viewHolder.alertInfoListView.alertListView.dataSource = self
    setupBackButton()
  }
  
  override func bind() {
    super.bind()
    let input = EmptyClassViewModel.Input(viewDidLoad: .just(()))
    let output = viewModel.transform(input: input)
    output.isLoading
      .subscribe(with: self) { owner, isLoading in
        if isLoading {
          owner.setupSkeletonView()
        } else {
          owner.view.hideSkeleton()
          owner.viewHolder.classListView.alertListView.reloadData()
        }
      }
      .disposed(by: disposeBag)
    
    viewHolder.classListView.alertListView.rx.itemSelected
      .withUnretained(self)
      .map { $0.viewModel.output.classModel.value[$1.row] }
      .subscribe(with: self) { owner, selectedType in
        let vc = LectureListViewController(viewModel: .init(payLoad: .init(classRoom: selectedType.rawValue)))
        vc.navigationItem.largeTitleDisplayMode = .never
        owner.navigationController?.pushViewController(vc, animated: true)
      }
      .disposed(by: disposeBag)
  }
  
  // MARK: - Action
  
  @objc func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

extension EmptyClassViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView == viewHolder.classListView.alertListView {
      return .init(width: collectionView.frame.width, height: 46)
    } else if collectionView == viewHolder.alertInfoListView.alertListView {
      return .init(width: collectionView.frame.width, height: 41)
    }
    return .zero
  }
}

extension EmptyClassViewController: SkeletonCollectionViewDataSource {
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
