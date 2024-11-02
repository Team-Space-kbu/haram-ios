//
//  CoursePlanViewController.swift
//  Haram
//
//  Created by 이건준 on 10/9/24.
//

import UIKit

import SkeletonView

final class CoursePlanViewController: ViewController, BackButtonHandler {
  let viewModel: CoursePlanViewModel
  let viewHolder: CoursePlanViewHolder = CoursePlanViewHolder()
  
  init(viewModel: CoursePlanViewModel = CoursePlanViewModel()) {
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
    let input = CoursePlanViewModel.Input(viewDidLoad: .just(()))
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
    
    viewHolder.majorListView.rx.itemSelected
      .withUnretained(self)
      .map { $0.viewModel.output.majorList.value[$1.row] }
      .subscribe(with: self) { owner, selectedMajor in
        let vc = LectureInfoViewController(viewModel: .init(payLoad: .init(course: selectedMajor.courseKey), lectureRepository: LectureRepositoryImpl()))
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

extension CoursePlanViewController: SkeletonCollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
}
