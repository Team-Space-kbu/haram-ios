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
  private let currentBannerPage = PublishSubject<Int>()
  private let viewModel: BoardDetailViewModel
  private var items: [UIAction] {
    return ReportTitleType.allCases.map { reportType in
      UIAction(
        title: reportType.title,
        handler: { [unowned self] _ in
          AlertManager.showAlert(title: reportType.title, message: .custom("신고 사유에 맞지 않은 신고를 했을경우 신고가 처리되지 않을 수 있습니다"), actions: [
            DestructiveAlertButton {
              self.tapReportButton.onNext(reportType)
            },
            CancelAlertButton()
          ])
        })
    }
  }
  
  private let tapBannedButton = PublishSubject<Void>()
  private let tapReportButton = PublishSubject<ReportTitleType>()
  private let tapDeleteCommentButton = PublishSubject<IndexPath>()
  
  // MARK: - UI Component
  
  private let scrollView = UIScrollView().then {
    $0.alwaysBounceVertical = true
    $0.backgroundColor = .clear
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
    $0.isSkeletonable = true
  }
  
  private let containerView = UIStackView().then {
    $0.backgroundColor = .clear
    $0.axis = .vertical
    $0.alignment = .fill
    $0.distribution = .fill
    $0.spacing = 15
    $0.isSkeletonable = true
  }
  
  private let boardDetailTopView = BoardDetailTopView()
  private let boardCommentListView = BoardCommentListView()
  
  private lazy var commentInputView = CommentInputView(writeableAnonymous: viewModel.writeableAnonymous).then {
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
    scrollView.delegate = self
    
    boardDetailTopView.boardImageCollectionView.delegate = self
    boardDetailTopView.boardImageCollectionView.dataSource = self
    
    boardCommentListView.boardDetailCollectionView.delegate = self
    boardCommentListView.boardDetailCollectionView.dataSource = self
    
    /// Set NavigationBar
    setupBackButton()
    setupRightBarButtonItem()
    
    containerView.subviews.forEach { $0.isSkeletonable = true }
    
    setupSkeletonView()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    
    let subViews = [boardDetailTopView, boardCommentListView]
    containerView.addArrangedDividerSubViews(subViews)

    if viewModel.writeableComment {
      view.addSubview(commentInputView)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    if viewModel.writeableComment {
      scrollView.snp.makeConstraints {
        $0.top.directionalHorizontalEdges.width.equalToSuperview()
      }
      
      commentInputView.snp.makeConstraints {
        $0.top.equalTo(scrollView.snp.bottom)
        $0.directionalHorizontalEdges.equalToSuperview()
        $0.height.greaterThanOrEqualTo(Device.isNotch ? 91 - 20 : 91 - 20 - 15)
        $0.bottom.equalToSuperview()
      }
    }
    
    containerView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    let input = BoardDetailViewModel.Input(
      viewDidLoad: .just(()),
      didTapBackButton: navigationItem.leftBarButtonItem!.rx.tap.asObservable(),
      didTapDeleteBoardButton: boardDetailTopView.postingInfoView.boardDeleteButton.rx.tap.asObservable(),
      didTapDeleteCommentButton: tapDeleteCommentButton.asObservable(),
      didTapSendButton: commentInputView.sendButton.rx.tap.asObservable(),
      didEditComment: commentInputView.commentTextView.rx.text.orEmpty.asObservable(),
      didTapBannedButton: tapBannedButton.asObservable(),
      didTapReportButton: tapReportButton.asObservable(),
      didTapAnonymousButton: commentInputView.checkBoxControl.rx.controlEvent(.touchUpInside).asObservable(), 
      didTapImageCell: boardDetailTopView.boardImageCollectionView.rx.itemSelected.asObservable()
    )
    bindNotificationCenter(input: input)
    
    let output = viewModel.transform(input: input)
    
    output.reloadBoardData
      .withLatestFrom(output.boardModel)
      .subscribe(with: self) { owner, model in
        owner.view.hideSkeleton()
        owner.boardDetailTopView.postingTitleLabel.text = model.boardTitle
        owner.boardDetailTopView.postingDescriptionLabel.addLineSpacing(lineSpacing: 2, string: model.boardContent)
        owner.boardDetailTopView.postingInfoView.configureUI(isUpdatable: model.isUpdatable, content: DateformatterFactory.dateWithSlash.string(from: model.boardDate) + " | " + model.boardAuthorName)
        owner.boardDetailTopView.pageControl.numberOfPages = owner.viewModel.boardImageModel.count
        owner.boardCommentListView.boardDetailCollectionView.reloadData()
        owner.boardDetailTopView.boardImageCollectionView.reloadData()
      }
      .disposed(by: disposeBag)
    
    output.isAnonymous
      .bind(to: commentInputView.checkBoxControl.rx.isChecked)
      .disposed(by: disposeBag)
    
    output.errorMessage
      .compactMap { $0 }
      .subscribe(with: self) { owner, error in
        if error == .networkError || error == .retryError {
          AlertManager.showAlert(message: .networkUnavailable, actions: [
            DefaultAlertButton {
              guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
              if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
              }
            }
          ])
        } 
        else if error == .internalServerError || error == .alreadyReportBoard {
          AlertManager.showAlert(on: owner.navigationController, message: .custom(error.description!))
        }
      }
      .disposed(by: disposeBag)
    
    currentBannerPage
      .asDriver(onErrorDriveWith: .empty())
      .drive(boardDetailTopView.pageControl.rx.currentPage)
      .disposed(by: disposeBag)
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
        AlertManager.showAlert(message: .custom("이 작성자의 게시물이\n목록에 노출되지 않으며,\n다시 해제하실 수 없습니다."), actions: [
          DestructiveAlertButton {
            self.tapBannedButton.onNext(())
          },
          CancelAlertButton()
        ])
      })
    
    let mainMenu = UIMenu(children: [reportMenu, banAction])
    button.menu = mainMenu
    
    let rightBarButtonItem = UIBarButtonItem(customView: button)
    button.addInteraction(interaction)
    
    navigationItem.rightBarButtonItem = rightBarButtonItem
  }
}

extension BoardDetailViewController {
  private func bindNotificationCenter(input: BoardDetailViewModel.Input) {
    NotificationCenter.default.rx.notification(.refreshWhenNetworkConnected)
      .map { _ in Void() }
      .bind(to: input.didConnectNetwork)
      .disposed(by: disposeBag)
  }
}

// MARK: - UICollectionDataSource

extension BoardDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == boardDetailTopView.boardImageCollectionView {
      return viewModel.boardImageModel.count
    } else if collectionView == boardCommentListView.boardDetailCollectionView {
      return viewModel.commentModel.count
    }
    return .zero
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == boardDetailTopView.boardImageCollectionView {
      let cell = collectionView.dequeueReusableCell(BoardImageCollectionViewCell.self, for: indexPath) ?? BoardImageCollectionViewCell()
      cell.configureUI(with: viewModel.boardImageModel[indexPath.row])
      return cell
    } else if collectionView == boardCommentListView.boardDetailCollectionView {
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
    return UICollectionViewCell()
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView == boardDetailTopView.boardImageCollectionView {
      return CGSize(width: collectionView.frame.width, height: 188)
    }
    return .zero
  }
}

// MARK: - UIGestureRecognizerDelegate

extension BoardDetailViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
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
    if skeletonView == boardDetailTopView.boardImageCollectionView {
      return BoardImageCollectionViewCell.reuseIdentifier
    } else if skeletonView == boardCommentListView.boardDetailCollectionView {
      return BoardDetailCollectionViewCell.reuseIdentifier
    }
    return ""
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    3
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    if skeletonView == boardCommentListView.boardDetailCollectionView {
      let cell = skeletonView.dequeueReusableCell(BoardDetailCollectionViewCell.self, for: indexPath) ?? BoardDetailCollectionViewCell()
      cell.configureUI(with: .init(comment: "안녕하세요, 스켈레톤을 위한 목데이터입니다.", createdAt: "2023/11/10", isUpdatable: false, commentSeq: 0))
      return cell
    } else if skeletonView == boardDetailTopView.boardImageCollectionView {
      let cell = skeletonView.dequeueReusableCell(BoardImageCollectionViewCell.self, for: indexPath) ?? BoardImageCollectionViewCell()
      return cell
    }
    return nil
  }
}

extension BoardDetailViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0 {
      // 위에서 아래로 스크롤하는 경우
      view.endEditing(true)
    }
    
    guard scrollView == boardDetailTopView.boardImageCollectionView else { return }
    let contentOffset = scrollView.contentOffset
    let bannerIndex = Int(max(0, round(contentOffset.x / scrollView.bounds.width)))
    
    self.currentBannerPage.onNext(bannerIndex)
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
