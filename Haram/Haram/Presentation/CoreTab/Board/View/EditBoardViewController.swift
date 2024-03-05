//
//  EditBoardViewController.swift
//  Haram
//
//  Created by 이건준 on 3/5/24.
//

import UIKit

import FloatingPanel
import RxSwift
import SnapKit
import Then

final class EditBoardViewController: BaseViewController, BackButtonHandler {
  
  private var imageModel: [UIImage] = []
  
  private let titlePlaceHolder = "제목을 입력해주세요"
  private let contentPlaceHolder = "내용을 입력해주세요"
  
  private lazy var editBoardBottomSheet = EditBoardBottomSheetViewController().then {
    $0.delegate = self
  }
  
  private lazy var floatingPanelVC = FloatingPanelController().then {
    let appearance = SurfaceAppearance()
    
    // Define shadows
    let shadow = SurfaceAppearance.Shadow()
    shadow.color = UIColor.black
    shadow.offset = CGSize(width: 0, height: -1)
    shadow.radius = 40
    shadow.spread = 10
    appearance.shadows = [shadow]
    
    // Define corner radius and background color
    appearance.cornerRadius = 20
    appearance.backgroundColor = .clear
    
    // Set the new appearance
    $0.contentMode = .fitToBounds
    $0.surfaceView.appearance = appearance
    $0.surfaceView.grabberHandle.isHidden = false // FloatingPanel Grabber hidden true
  }
  
  private let tapGesture = UITapGestureRecognizer(target: EditBoardViewController.self, action: nil).then {
    $0.numberOfTapsRequired = 1
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  private let panGesture = UIPanGestureRecognizer(target: RegisterViewController.self, action: nil).then {
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  private let scrollView = UIScrollView().then {
    $0.alwaysBounceVertical = true
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 10
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 20, left: 15, bottom: 15, right: 15)
  }
  
  private let boardTitleLabel = UILabel().then {
    $0.text = "게시글 제목"
    $0.font = .regular14
    $0.textColor = .black
  }
  
  private let titleTextView = UITextView().then {
    $0.textColor = .hexD0D0D0
    $0.textContainerInset = UIEdgeInsets(
      top: 10,
      left: 10,
      bottom: 10,
      right: 10
    )
    $0.font = .regular14
    $0.backgroundColor = .hexF4F4F4
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 8
    $0.layer.borderColor = UIColor.hexD0D0D0.cgColor
    $0.layer.borderWidth = 1
    $0.autocorrectionType = .no
    $0.spellCheckingType = .no
  }
  
  private let boardContentLabel = UILabel().then {
    $0.text = "게시글 내용"
    $0.font = .regular14
    $0.textColor = .black
  }
  
  private let contentTextView = UITextView().then {
    $0.textColor = .hexD0D0D0
    $0.textContainerInset = UIEdgeInsets(
      top: 10,
      left: 10,
      bottom: 10,
      right: 10
    )
    $0.font = .regular14
    $0.backgroundColor = .hexF4F4F4
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 8
    $0.layer.borderColor = UIColor.hexD0D0D0.cgColor
    $0.layer.borderWidth = 1
    $0.autocorrectionType = .no
    $0.spellCheckingType = .no
  }
  
  private lazy var editBoardCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
    $0.minimumLineSpacing = 25
    $0.minimumInteritemSpacing = 25
  }).then {
    $0.register(EditBoardCollectionViewCell.self, forCellWithReuseIdentifier: EditBoardCollectionViewCell.identifier)
    $0.isScrollEnabled = false
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
    $0.dataSource = self
    $0.delegate = self
  }
  
  override func setupStyles() {
    super.setupStyles()
    titleTextView.text = titlePlaceHolder
    contentTextView.text = contentPlaceHolder
    
    setupBackButton()
    
    navigationController?.navigationBar.tintColor = .hex2F80ED
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "작성", style: .done, target: self, action: nil)
    
    showFloatingPanel(self.floatingPanelVC)
    _ = [tapGesture, panGesture].map { view.addGestureRecognizer($0) }
    panGesture.delegate = self
  }
  
  override func bind() {
    super.bind()
    
    titleTextView.rx.didBeginEditing
      .asDriver()
      .drive(with: self) { owner, _ in
        if owner.titleTextView.text.trimmingCharacters(in: .whitespacesAndNewlines) == owner.titlePlaceHolder &&
            owner.titleTextView.textColor == .hexD0D0D0 {
          owner.titleTextView.text = ""
          owner.titleTextView.textColor = .hex545E6A
        }
      }
      .disposed(by: disposeBag)
    
    titleTextView.rx.didEndEditing
      .asDriver()
      .drive(with: self) { owner, _ in
        if owner.titleTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            owner.titleTextView.textColor == .hex545E6A {
          owner.titleTextView.text = owner.titlePlaceHolder
          owner.titleTextView.textColor = .hexD0D0D0
        }
        
        owner.updateTextViewHeightAutomatically(textView: owner.titleTextView)
      }
      .disposed(by: disposeBag)
    
    titleTextView.rx.text
      .asDriver()
      .drive(with: self){ owner, text in
        owner.updateTextViewHeightAutomatically(textView: owner.titleTextView)
      }
      .disposed(by: disposeBag)
    
    contentTextView.rx.didBeginEditing
      .asDriver()
      .drive(with: self) { owner, _ in
        if owner.contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines) == owner.contentPlaceHolder &&
            owner.contentTextView.textColor == .hexD0D0D0 {
          owner.contentTextView.text = ""
          owner.contentTextView.textColor = .hex545E6A
        }
      }
      .disposed(by: disposeBag)
    
    contentTextView.rx.didEndEditing
      .asDriver()
      .drive(with: self) { owner, _ in
        if owner.contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            owner.contentTextView.textColor == .hex545E6A {
          owner.contentTextView.text = owner.contentPlaceHolder
          owner.contentTextView.textColor = .hexD0D0D0
        }
        
        owner.updateTextViewHeightAutomatically(textView: owner.contentTextView, height: 209)
      }
      .disposed(by: disposeBag)
    
    contentTextView.rx.text
      .asDriver()
      .drive(with: self){ owner, text in
        owner.updateTextViewHeightAutomatically(textView: owner.contentTextView, height: 209)
      }
      .disposed(by: disposeBag)
    
    tapGesture.rx.event
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.view.endEditing(true)
//        owner.floatingPanelVC.move(to: .half, animated: true)
      }
      .disposed(by: disposeBag)
    
    panGesture.rx.event
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.view.endEditing(true)
//        owner.floatingPanelVC.move(to: .half, animated: true)
      }
      .disposed(by: disposeBag)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    _ = [boardTitleLabel, titleTextView, boardContentLabel, contentTextView, editBoardCollectionView].map { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    scrollView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.top.width.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    boardTitleLabel.snp.makeConstraints {
      $0.height.equalTo(18)
    }
    
    titleTextView.snp.makeConstraints {
      $0.height.equalTo(45)
    }
    
    boardContentLabel.snp.makeConstraints {
      $0.height.equalTo(18)
    }
    
    contentTextView.snp.makeConstraints {
      $0.height.equalTo(209)
    }
    
    editBoardCollectionView.snp.makeConstraints {
      $0.height.equalTo(169)
    }
  }
  
  
  // TODO: - 나중에 텍스트 뷰 높이를 제한해야한다면 height값 이용해서 조건문 추가
  private func updateTextViewHeightAutomatically(textView: UITextView, height: CGFloat = 45) {
    let size = CGSize(
      width: textView.frame.width,
      height: .infinity
    )
    let estimatedSize = textView.sizeThatFits(size)
    
    if estimatedSize.height > height {
      textView.snp.updateConstraints {
        $0.height.equalTo(estimatedSize.height)
      }
    } else {
      textView.snp.updateConstraints {
        $0.height.equalTo(height)
      }
    }
  }
  
  @objc
  func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

extension EditBoardViewController: FloatingPanelControllerDelegate {
  func showFloatingPanel(_ floatingPanelVC: FloatingPanelController) {
    DispatchQueue.main.async {
      let layout = EditBoardFloatingPanelLayout()
      floatingPanelVC.layout = layout
      floatingPanelVC.delegate = self
      floatingPanelVC.addPanel(toParent: self)
      floatingPanelVC.set(contentViewController: self.editBoardBottomSheet)
      floatingPanelVC.show()
    }
  }
}

extension EditBoardViewController {
  final class EditBoardFloatingPanelLayout: FloatingPanelLayout {
    
    var position: FloatingPanelPosition {
      return .bottom
    }
    
    var initialState: FloatingPanelState {
      return .half
    }
    
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
      return 0 // DimmedView alpha
    }
    
    var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
      return [
        .full: FloatingPanelLayoutAnchor(fractionalInset: 0.6, edge: .bottom, referenceGuide: .safeArea),
        .half: FloatingPanelLayoutAnchor(absoluteInset: 198, edge: .bottom, referenceGuide: .superview),
        .tip: FloatingPanelLayoutAnchor(fractionalInset: 0.1, edge: .bottom, referenceGuide: .safeArea)
      ]
    }
  }
}

// MARK: - UIGestureRecognizerDelegate

extension EditBoardViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}

extension EditBoardViewController: EditBoardBottomSheetViewDelegate {
  func didTappedAnonymousMenu() {
    
  }
  
  func whichSelectedImage(with image: UIImage) {
    if imageModel.count < 8 { // 이미지 삽입 최대 갯수 8개제한
      imageModel.append(image)
      editBoardCollectionView.reloadData()
    }
  }
}

extension EditBoardViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    imageModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditBoardCollectionViewCell.identifier, for: indexPath) as? EditBoardCollectionViewCell ?? EditBoardCollectionViewCell()
    cell.configureUI(with: imageModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    CGSize(width: (collectionView.frame.width - 25 * 3) / 4, height: 72)
  }
}
