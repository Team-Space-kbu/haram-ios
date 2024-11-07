//
//  LectureListViewController.swift
//  Haram
//
//  Created by 이건준 on 10/10/24.
//

import UIKit

import SkeletonView

final class LectureListViewController: ViewController, BackButtonHandler {
  let viewModel: LectureListViewModel
  let viewHolder: LectureListViewHolder = LectureListViewHolder()
  
  init(viewModel: LectureListViewModel) {
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
    viewHolder.lectureListView.dataSource = self
    viewHolder.lectureListView.delegate = self
    setupBackButton()
  }
  
  override func bind() {
    super.bind()
    let input = LectureListViewModel.Input(
      viewDidLoad: .just(()),
      didTappedLecture: viewHolder.lectureListView.rx.itemSelected.asObservable()
    )
    let output = viewModel.transform(input: input)
    output.isLoading
      .subscribe(with: self) { owner, isLoading in
        if isLoading {
          owner.setupSkeletonView()
        } else {
          owner.view.hideSkeleton()
          owner.viewHolder.lectureListView.reloadData()
        }
      }
      .disposed(by: disposeBag)
    
    output.showLectureScheduleViewController
      .subscribe(with: self) { owner, selectedClassRoom in
        let vc = LectureScheduleViewController(
          viewModel: LectureScheduleViewModel(
            payLoad: .init(classRoom: selectedClassRoom),
            dependency: .init(lectureRepository: LectureRepositoryImpl())
          )
        )
        vc.title = selectedClassRoom
        owner.navigationController?.pushViewController(vc, animated: true)
      }
      .disposed(by: disposeBag)
  }
  
  // MARK: - Action
  
  @objc func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

extension LectureListViewController: SkeletonCollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    viewModel.output.lectureList.value.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(ClassCollectionViewCell.self, for: indexPath) ?? ClassCollectionViewCell()
    cell.configureUI(title: viewModel.output.lectureList.value[indexPath.row])
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
