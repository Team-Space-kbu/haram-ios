//
//  BoardDetailViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/09/20.
//

import UIKit

import SnapKit
import Then

final class BoardDetailViewController: BaseViewController, BackButtonHandler {
  
  // MARK: - Property
  
  private let viewModel: BoardDetailViewModelType
  private let boardSeq: Int
  private let categorySeq: Int
  
  // MARK: - UI Models
  
  private var cellModel: [BoardDetailCollectionViewCellModel] = [] {
    didSet {
      boardDetailCollectionView.reloadSections([1])
    }
  }
  
  private var boardModel: [BoardDetailHeaderViewModel] = [] {
    didSet {
      boardDetailCollectionView.reloadSections([0])
    }
  }
  
  // MARK: - Gesture
  
  private let tapGesture = UITapGestureRecognizer(target: BoardDetailViewController.self, action: nil).then {
    $0.numberOfTapsRequired = 1
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  private let panGesture = UIPanGestureRecognizer(target: RegisterViewController.self, action: nil).then {
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  // MARK: - UI Component
  
  private let commentInputView = CommentInputView()
  
  private lazy var boardDetailCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sec, env -> NSCollectionLayoutSection? in
    guard let self = self else { return nil }
    return type(of: self).createCollectionViewLayout(sec: sec)
  }).then {
    $0.register(BoardDetailCollectionViewCell.self, forCellWithReuseIdentifier: BoardDetailCollectionViewCell.identifier)
    $0.register(BoardDetailHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BoardDetailHeaderView.identifier)
    $0.register(BoardDetailCommentHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BoardDetailCommentHeaderView.identifier)
    $0.dataSource = self
    $0.alwaysBounceVertical = true
  }
  
  // MARK: - Initializations
  init(categorySeq: Int, boardSeq: Int, viewModel: BoardDetailViewModelType = BoardDetailViewModel()) {
    self.viewModel = viewModel
    self.boardSeq = boardSeq
    self.categorySeq = categorySeq
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    LogHelper.log(#function, level: .debug)
    removeNotifications()
  }
  
  // MARK: - Configurations
  
  override func setupStyles() {
    super.setupStyles()
    
    /// Set NavigationBar
    title = "게시판"
    setupBackButton()
    
    /// Set GestureRecognizer
    view.addGestureRecognizer(tapGesture)
    view.addGestureRecognizer(panGesture)
    
    /// Set Delegate
    commentInputView.delegate = self
    panGesture.delegate = self
    registerNotifications()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    _ = [boardDetailCollectionView, commentInputView].map { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    boardDetailCollectionView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
    }
    
    commentInputView.snp.makeConstraints {
      $0.top.equalTo(boardDetailCollectionView.snp.bottom)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.height.greaterThanOrEqualTo(91 - 20)
      $0.bottom.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    
    viewModel.inquireBoardDetail(categorySeq: categorySeq, boardSeq: boardSeq)
    
    viewModel.boardInfoModel
      .drive(rx.boardModel)
      .disposed(by: disposeBag)
    
    viewModel.boardCommentModel
      .drive(rx.cellModel)
      .disposed(by: disposeBag)
    
    tapGesture.rx.event
      .subscribe(with: self) { owner, _ in
        owner.view.endEditing(true)
      }
      .disposed(by: disposeBag)
    
    panGesture.rx.event
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.view.endEditing(true)
      }
      .disposed(by: disposeBag)
    
    viewModel.successCreateComment
      .emit(with: self) { owner, result in
        let (comment, createdAt) = result
        owner.boardDetailCollectionView.performBatchUpdates {
          owner.cellModel.insert(.init(
            comment: comment,
            createdAt: createdAt
          ), at: owner.cellModel.count)
          owner.boardDetailCollectionView.insertItems(at: [IndexPath(item: owner.cellModel.count - 1, section: 1)])
        }
      }
      .disposed(by: disposeBag)
  }
  
  // MARK: - Action Function
  
  @objc func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
  // MARK: - UICompositonalLayout Function
  
  static private func createCollectionViewLayout(sec: Int) -> NSCollectionLayoutSection? {
    let item = NSCollectionLayoutItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .estimated(35 + 3 + 18 + 16 + 1)
      )
    )
    
    let verticalGroup = NSCollectionLayoutGroup.vertical(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .estimated(35 + 3 + 18 + 16 + 1)
      ),
      subitems: [item]
    )
    
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .estimated(18 + 3 + 18 + 16 + 18 + 18)
      ),
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top
    )

    let section = NSCollectionLayoutSection(group: verticalGroup)
    if sec == 1 {
      section.contentInsets = NSDirectionalEdgeInsets(top: .zero, leading: 16, bottom: 16, trailing: 16)
    }
    section.interGroupSpacing = 16
    section.boundarySupplementaryItems = [header]
    return section
  }
}

// MARK: - UICollectionDataSource

extension BoardDetailViewController: UICollectionViewDataSource {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 2
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard section == 1 else { return 0 }
    return cellModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard indexPath.section == 1 else { return UICollectionViewCell() }
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoardDetailCollectionViewCell.identifier, for: indexPath) as? BoardDetailCollectionViewCell ?? BoardDetailCollectionViewCell()
    cell.configureUI(with: cellModel[indexPath.row])
    if cellModel.count - 1 == indexPath.row { // 마지막 댓글이라면 라인 삭제
      cell.removeLineView()
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if indexPath.section == 0 {
      let header = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: BoardDetailHeaderView.identifier,
        for: indexPath
      ) as? BoardDetailHeaderView ?? BoardDetailHeaderView()
      header.configureUI(with: boardModel.first)
      return header
    }
    let header = collectionView.dequeueReusableSupplementaryView(
      ofKind: kind,
      withReuseIdentifier: BoardDetailCommentHeaderView.identifier,
      for: indexPath
    ) as? BoardDetailCommentHeaderView ?? BoardDetailCommentHeaderView()
    return header
    
  }
  
}

// MARK: - UIGestureRecognizerDelegate

extension BoardDetailViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}

extension BoardDetailViewController: CommentInputViewDelegate {
  func writeComment(_ comment: String) {
    viewModel.createComment(boardComment: comment, categorySeq: categorySeq, boardSeq: boardSeq)
  }
}

// MARK: - Keyboard Notifications

extension BoardDetailViewController {
  func registerNotifications() {
    NotificationCenter.default.addObserver(
      self, selector: #selector(keyboardWillShow(_:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )

    NotificationCenter.default.addObserver(
      self, selector: #selector(keyboardWillHide(_:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }

  func removeNotifications() {
    NotificationCenter.default.removeObserver(self)
  }

  @objc
  func keyboardWillShow(_ sender: Notification) {
    guard let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
      return
    }

    let keyboardHeight = keyboardSize.height

    commentInputView.snp.updateConstraints {
      $0.bottom.equalToSuperview().inset(keyboardHeight)
    }

    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }

  @objc
  func keyboardWillHide(_ sender: Notification) {

    commentInputView.snp.updateConstraints {
      $0.bottom.equalToSuperview()
    }
    
    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }
}
