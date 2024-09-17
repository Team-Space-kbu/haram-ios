//
//  BoardDetailViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/09/20.
//

import UIKit

import RxSwift
import RxCocoa
import SkeletonView
import SnapKit
import Then

final class BoardDetailViewController: BaseViewController {
  
  // MARK: - Property
  
  private let viewModel: BoardDetailViewModel
  private var items: [UIAction] {
    return ReportTitleType.allCases.map { reportType in
      UIAction(
        title: reportType.title,
        handler: { [unowned self] _ in
          AlertManager.showAlert(title: reportType.title, message: "신고 사유에 맞지 않은 신고를 했을경우 신고가 처리되지 않을 수 있습니다", viewController: self, confirmHandler: {
            self.tapReportButton.onNext(reportType)
          }, cancelHandler: nil)
        })
    }
  }
  
  private let tapBannedButton = PublishSubject<Void>()
  private let tapReportButton = PublishSubject<ReportTitleType>()
  private let tapDeleteCommentButton = PublishSubject<IndexPath>()
  private let tapDeleteBoardButton = PublishSubject<Void>()
  
  // MARK: - UI Component
  
  private lazy var commentInputView = CommentInputView(writeableAnonymous: viewModel.writeableAnonymous).then {
    $0.isSkeletonable = true
  }
  
  private lazy var boardDetailCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sec, env -> NSCollectionLayoutSection? in
    guard let self = self else { return nil }
    return type(of: self).createCollectionViewLayout(sec: sec)
  }).then {
    $0.register(BoardDetailCollectionViewCell.self)
    $0.register(BoardDetailHeaderView.self, of: UICollectionView.elementKindSectionHeader)
    $0.register(BoardDetailCommentHeaderView.self, of: UICollectionView.elementKindSectionHeader)
    $0.dataSource = self
    $0.delegate = self
    $0.alwaysBounceVertical = true
    $0.isSkeletonable = true
  }
  
  private lazy var interaction = UIContextMenuInteraction(delegate: self)
  
  // MARK: - Initializations
  init(viewModel: BoardDetailViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerNotifications()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeNotifications()
  }
  
  // MARK: - Configurations
  
  override func setupStyles() {
    super.setupStyles()
    
    /// Set NavigationBar
    setupBackButton()
    setupRightBarButtonItem()
    
    setupSkeletonView()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(boardDetailCollectionView)
    if viewModel.writeableComment {
      view.addSubview(commentInputView)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    if viewModel.writeableComment {
      boardDetailCollectionView.snp.makeConstraints {
        $0.top.directionalHorizontalEdges.equalToSuperview()
      }
      
      commentInputView.snp.makeConstraints {
        $0.top.equalTo(boardDetailCollectionView.snp.bottom)
        $0.directionalHorizontalEdges.equalToSuperview()
        $0.height.greaterThanOrEqualTo(Device.isNotch ? 91 - 20 : 91 - 20 - 15)
        $0.bottom.equalToSuperview()
      }
    } else {
      boardDetailCollectionView.snp.makeConstraints {
        $0.directionalEdges.equalToSuperview()
      }
    }
  }
  
  override func bind() {
    super.bind()
    let input = BoardDetailViewModel.Input(
      viewDidLoad: .just(()),
      didTapBackButton: navigationItem.leftBarButtonItem!.rx.tap.asObservable(),
      didTapDeleteBoardButton: tapDeleteBoardButton.asObservable(),
      didTapDeleteCommentButton: tapDeleteCommentButton.asObservable(),
      didTapSendButton: commentInputView.sendButton.rx.tap.asObservable(),
      didEditComment: commentInputView.commentTextView.rx.text.orEmpty.asObservable(),
      didTapBannedButton: tapBannedButton.asObservable(),
      didTapReportButton: tapReportButton.asObservable(),
      didTapAnonymousButton: commentInputView.checkBoxControl.rx.controlEvent(.touchUpInside).asObservable()
    )
    let output = viewModel.transform(input: input)
    
    output.reloadBoardData
      .subscribe(with: self) { owner, _ in
        owner.view.hideSkeleton()
        owner.boardDetailCollectionView.reloadData()
      }
      .disposed(by: disposeBag)
    
    output.isAnonymous
      .bind(to: commentInputView.checkBoxControl.rx.isChecked)
      .disposed(by: disposeBag)
    
    output.errorMessage
      .subscribe(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요.", viewController: owner) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          }
        } else if error == .retryError {
          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요.", viewController: owner) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          }
        } else if error == .internalServerError || error == .alreadyReportBoard {
          AlertManager.showAlert(title: "Space 알림", message: error.description!, viewController: owner, confirmHandler: nil)
        }
      }
      .disposed(by: disposeBag)
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
  
  private func setupRightBarButtonItem() {
    let button = UIButton().then {
      $0.setImage(UIImage(resource: .ellipsisVertical).withRenderingMode(.alwaysOriginal), for: .normal)
      $0.showsMenuAsPrimaryAction = true
    }
    
    let reportMenu = UIMenu(title: "신고", children: items)
    let banAction = UIAction(
      title: "차단",
      handler: { [unowned self] _ in
        AlertManager.showAlert(title: "이 작성자의 게시물이\n목록에 노출되지 않으며,\n다시 해제하실 수 없습니다.", viewController: self, confirmHandler: {
          self.tapBannedButton.onNext(())
        }, cancelHandler: nil)
      })
    
    let mainMenu = UIMenu(children: [reportMenu, banAction])
    button.menu = mainMenu
    
    let rightBarButtonItem = UIBarButtonItem(customView: button)
    button.addInteraction(interaction)
    
    navigationItem.rightBarButtonItem = rightBarButtonItem
  }
}

// MARK: - UICollectionDataSource

extension BoardDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return viewModel.writeableComment ? 2 : 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard section == 1 else { return 0 }
    return viewModel.commentModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard indexPath.section == 1 else { return UICollectionViewCell() }
    let cell = collectionView.dequeueReusableCell(BoardDetailCollectionViewCell.self, for: indexPath) ?? BoardDetailCollectionViewCell()
    cell.configureUI(with: viewModel.commentModel[indexPath.row])
    cell.commentAuthorInfoView.boardDeleteButton.rx.tap
      .compactMap { [weak collectionView] in
        collectionView?.indexPath(for: cell)
      }
      .bind(to: tapDeleteCommentButton)
      .disposed(by: disposeBag)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if indexPath.section == 0 {
      let header = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: BoardDetailHeaderView.reuseIdentifier,
        for: indexPath
      ) as? BoardDetailHeaderView ?? BoardDetailHeaderView()
      header.configureUI(with: viewModel.boardModel.first)
      header.postingInfoView.boardDeleteButton.rx.tap
        .bind(to: tapDeleteBoardButton)
        .disposed(by: disposeBag)
      header.delegate = self
      return header
    }
    let header = collectionView.dequeueReusableSupplementaryView(
      ofKind: kind,
      withReuseIdentifier: BoardDetailCommentHeaderView.reuseIdentifier,
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

// MARK: - Keyboard Notifications
extension BoardDetailViewController {
  @objc
  private func refreshWhenNetworkConnected() {
    //    viewModel.inquireBoardDetail(categorySeq: categorySeq, boardSeq: boardSeq)
  }
}

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
    
    NotificationCenter.default.addObserver(self, selector: #selector(refreshWhenNetworkConnected), name: .refreshWhenNetworkConnected, object: nil)
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

extension BoardDetailViewController: SkeletonCollectionViewDataSource, SkeletonCollectionViewDelegate {
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
    guard indexPath.section == 1 else { return "" }
    return BoardDetailCollectionViewCell.reuseIdentifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard section == 1 else { return 0 }
    return 10
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    guard indexPath.section == 1 else { return nil }
    let cell = skeletonView.dequeueReusableCell(BoardDetailCollectionViewCell.self, for: indexPath) ?? BoardDetailCollectionViewCell()
    cell.configureUI(with: .init(comment: "안녕하세요, 스켈레톤을 위한 목데이터입니다.", createdAt: "2023/11/10", isUpdatable: false, commentSeq: 0))
    return cell
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, supplementaryViewIdentifierOfKind: String, at indexPath: IndexPath) -> ReusableCellIdentifier? {
    if indexPath.section == 0 {
      return BoardDetailHeaderView.reuseIdentifier
    } else  {
      return BoardDetailCommentHeaderView.reuseIdentifier
    }
  }
  
  func numSections(in collectionSkeletonView: UICollectionView) -> Int {
    2
  }
}

extension BoardDetailViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0 {
      // 위에서 아래로 스크롤하는 경우
      view.endEditing(true)
    }
  }
}

extension BoardDetailViewController: BoardDetailHeaderViewDelegate {
  func didTappedBoardImage(url: URL?) {
    let modal = ZoomImageViewController(zoomImageURL: url)
    modal.modalPresentationStyle = .fullScreen
    present(modal, animated: true)
  }
}

extension BoardDetailViewController: UIContextMenuInteractionDelegate {
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
    return UIContextMenuConfiguration(actionProvider:  { [unowned self] suggestedActions in
      let menu = UIMenu(
        title: "메뉴1",
        children: self.items
      )
      
      return menu
    })
  }
}
