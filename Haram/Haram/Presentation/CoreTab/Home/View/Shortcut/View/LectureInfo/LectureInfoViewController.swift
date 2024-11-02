//
//  LectureInfoViewController.swift
//  Haram
//
//  Created by 이건준 on 10/12/24.
//

import UIKit

import SkeletonView

final class LectureInfoViewController: ViewController, BackButtonHandler {
  let viewModel: LectureInfoViewModel
  let viewHolder: LectureInfoViewHolder = LectureInfoViewHolder()
  
  init(viewModel: LectureInfoViewModel) {
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
    viewHolder.lectureListView.dataSource = self
    viewHolder.lectureListView.delegate = self
    setupBackButton()
  }
  
  override func bind() {
    super.bind()
    let input = LectureInfoViewModel.Input(viewDidLoad: .just(()))
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
    
    viewHolder.lectureListView.rx.itemSelected
      .withUnretained(self)
      .map { $0.viewModel.output.lectureList.value[$1.row] }
      .subscribe(with: self) { owner, selectedLecture in
        let vc = PDFViewController(pdfURL: URL(string: selectedLecture.pdfFile))
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = selectedLecture.title
        owner.navigationController?.pushViewController(vc, animated: true)
      }
      .disposed(by: disposeBag)
  }
  
  // MARK: - Action
  
  @objc func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

extension LectureInfoViewController: SkeletonCollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
}

