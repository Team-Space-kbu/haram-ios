//
//  EditBoardViewController.swift
//  Haram
//
//  Created by 이건준 on 3/5/24.
//

import UIKit

import FloatingPanel
import PhotosUI
import RxSwift
import SnapKit
import Then

final class EditBoardViewController: BaseViewController, BackButtonHandler {
  
  private let viewModel: EditBoardViewModelType
  private let categorySeq: Int
  
  private var imageModel: [UIImage] = []
  private var selections = [String : PHPickerResult]()
  private var selectedAssetIdentifiers = [String]()
  private var isAnonymous = false
  
  private lazy var editBoardBottomSheet = EditBoardBottomSheetViewController().then {
    $0.delegate = self
  }
  
  private lazy var floatingPanelVC = FloatingPanelController().then {
    let appearance = SurfaceAppearance()
    
    // Define shadows
    let shadow = SurfaceAppearance.Shadow()
    shadow.color = UIColor.black
    shadow.offset = CGSize(width: 0, height: -1)
    shadow.radius = 15
    shadow.spread = 0
    shadow.opacity = 0.17
    appearance.shadows = [shadow]
    
    // Define corner radius and background color
    appearance.cornerRadius = 15
    appearance.backgroundColor = .clear
    
    // Set the new appearance
    $0.contentMode = .fitToBounds
    $0.surfaceView.appearance = appearance
    $0.surfaceView.grabberHandle.isHidden = false // FloatingPanel Grabber hidden true
  }
  
  private lazy var scrollView = UIScrollView().then {
    $0.alwaysBounceVertical = true
    $0.delegate = self
    $0.showsVerticalScrollIndicator = false
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
  
  private lazy var titleTextField = UITextField().then {
    $0.placeholder = Constants.titlePlaceholder
    $0.leftViewMode = .always
    $0.leftView = UIView(frame: .init(x: .zero, y: .zero, width: 13, height: .zero))
    $0.font = .regular14
    $0.backgroundColor = .hexF4F4F4
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 8
    $0.layer.borderColor = UIColor.hexD0D0D0.cgColor
    $0.layer.borderWidth = 1
    $0.autocorrectionType = .no
    $0.spellCheckingType = .no
    $0.delegate = self
    $0.returnKeyType = .next
  }
  
  private let boardContentLabel = UILabel().then {
    $0.text = "게시글 내용"
    $0.font = .regular14
    $0.textColor = .black
  }
  
  private let contentTextView = UITextView().then {
    $0.textColor = .hexD0D0D0
    $0.textContainerInset = UIEdgeInsets(
      top: 13,
      left: 8,
      bottom: 13,
      right: 8
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
  
  private let tapGesture = UITapGestureRecognizer(target: EditBoardViewController.self, action: nil).then {
    $0.numberOfTapsRequired = 1
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  init(categorySeq: Int, viewModel: EditBoardViewModelType = EditBoardViewModel()) {
    self.viewModel = viewModel
    self.categorySeq = categorySeq
    super.init(nibName: nil, bundle: nil)
  }
  
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    removeNotifications()
  }
  
  override func setupStyles() {
    super.setupStyles()
    registerNotifications()
    
    contentTextView.text = Constants.contentPlaceholder
    
    setupBackButton()
    
    navigationController?.navigationBar.tintColor = .hex2F80ED
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "작성", style: .done, target: self, action: nil)
    
    showFloatingPanel(self.floatingPanelVC)
    view.addGestureRecognizer(tapGesture)
  }
  
  override func bind() {
    super.bind()
    
    tapGesture.rx.event
      .subscribe(with: self) { owner, _ in
        owner.view.endEditing(true)
      }
      .disposed(by: disposeBag)
    
    contentTextView.rx.didBeginEditing
      .asDriver()
      .drive(with: self) { owner, _ in
        if owner.contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines) == Constants.contentPlaceholder &&
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
          owner.contentTextView.text = Constants.contentPlaceholder
          owner.contentTextView.textColor = .hexD0D0D0
        }
      }
      .disposed(by: disposeBag)
    
    navigationItem.rightBarButtonItem!.rx.tap
      .subscribe(with: self) { owner, _ in
        let title = owner.titleTextField.text!
        let content = owner.contentTextView.text!
        owner.view.endEditing(true)
        owner.viewModel.createBoard(categorySeq: owner.categorySeq, title: title, contents: content, isAnonymous: owner.isAnonymous)
      }
      .disposed(by: disposeBag)
    
    viewModel.successUploadImage
      .emit(with: self) { owner, result in
        let (_, image) = result
        owner.imageModel.append(image)
        owner.editBoardCollectionView.reloadData()
      }
      .disposed(by: disposeBag)
    
    viewModel.successCreateBoard
      .emit(with: self) { owner, _ in
        NotificationCenter.default.post(name: .refreshBoardList, object: nil)
        
        AlertManager.showAlert(title: "게시글작성 성공", message: "메인화면으로 이동합니다.", viewController: owner) {
          owner.navigationController?.popViewController(animated: true)
        }
      }
      .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요.", viewController: owner) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          }
          return
        }
        AlertManager.showAlert(title: "Space 알림", message: error.description!, viewController: owner, confirmHandler: nil)
      }
      .disposed(by: disposeBag)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    _ = [containerView].map { scrollView.addSubview($0) }
    _ = [boardTitleLabel, titleTextField, boardContentLabel, contentTextView, editBoardCollectionView].map { containerView.addArrangedSubview($0) }
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
    
    titleTextField.snp.makeConstraints {
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
//  private func updateTextViewHeightAutomatically(textView: UITextView, height: CGFloat = 45) {
//    let size = CGSize(
//      width: textView.frame.width,
//      height: .infinity
//    )
//    let estimatedSize = textView.sizeThatFits(size)
//    
//    if estimatedSize.height > height {
//      textView.snp.updateConstraints {
//        $0.height.equalTo(estimatedSize.height)
//      }
//    } else {
//      textView.snp.updateConstraints {
//        $0.height.equalTo(height)
//      }
//    }
//  }
  
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
        .half: FloatingPanelLayoutAnchor(absoluteInset: 198 - Device.bottomInset, edge: .bottom, referenceGuide: .superview),
        .tip: FloatingPanelLayoutAnchor(fractionalInset: 0.05, edge: .bottom, referenceGuide: .safeArea)
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
  func didTappedAnonymousMenu(isChecked: Bool) {
    self.isAnonymous = isChecked
  }
  
  func didTappedSelectedMenu() {
    presentPicker()
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

// MARK: - Constants

extension EditBoardViewController {
  enum Constants {
    static let titlePlaceholder = "제목을 입력해주세요"
    static let contentPlaceholder = "내용을 입력해주세요"
  }
}

extension EditBoardViewController: PHPickerViewControllerDelegate {
  
  private func presentPicker() {
    var config = PHPickerConfiguration(photoLibrary: .shared())
    config.selectionLimit = 8
    config.filter = .images
    config.selection = .ordered
    config.preferredAssetRepresentationMode = .current
    
    let picker = PHPickerViewController(configuration: config)
    picker.delegate = self
    present(picker, animated: true)
  }
  
  private func displayImage() {
    
    var dispatchGroup = DispatchGroup()
    var imagesDict = [String: UIImage]()
    
    for (identifier, result) in selections {
      dispatchGroup.enter()
      let itemProvider = result.itemProvider
      // 만약 itemProvider에서 UIImage로 로드가 가능하다면?
      if itemProvider.canLoadObject(ofClass: UIImage.self) {
        // 로드 핸들러를 통해 UIImage를 처리해 줍시다. (비동기적으로 동작)
        itemProvider.loadObject(ofClass: UIImage.self) { image, error in
          
          guard let image = image as? UIImage else { return }
          imagesDict[identifier] = image
          dispatchGroup.leave()
        }
      }
    }
    
    dispatchGroup.notify(queue: .global()) { [weak self] in
      guard let self = self else { return }
      var images: [(UIImage, String)] = []
      for identifier in self.selectedAssetIdentifiers {
        guard let image = imagesDict[identifier] else { return }
        images.append((image, identifier))
      }
      self.viewModel.uploadImage(images: images, type: .board)
    }
  }
  
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)
    
    // 만들어준 itemProviders에 Picker로 선택한 이미지정보를 전달
    let itemProviders = results.map(\.itemProvider)
    
    // 만약에 삽입한 이미지 갯수가 최대갯수인 8개를 넘어선 경우
    if itemProviders.count + imageModel.count > 8 {
      AlertManager.showAlert(title: "이미지 등록은 최대 8개입니다.", viewController: self, confirmHandler: nil)
      return
    }
    var newSelections = [String: PHPickerResult]()
    for result in results {
      let identifier = result.assetIdentifier!
      // ⭐️ 여기는 WWDC에서 3분 부분을 참고하세요. (Picker의 사진의 저장 방식)
      newSelections[identifier] = selections[identifier] ?? result
    }
    
    // selections에 새로 만들어진 newSelection을 넣어줍시다.
    selections = newSelections
    // Picker에서 선택한 이미지의 Identifier들을 저장 (assetIdentifier은 옵셔널 값이라서 compactMap 받음)
    // 위의 PHPickerConfiguration에서 사용하기 위해서 입니다.
    selectedAssetIdentifiers = results.compactMap { $0.assetIdentifier }
    
    if !selections.isEmpty {
      displayImage()
    }
  }
}

extension EditBoardViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0 {
      // 위에서 아래로 스크롤하는 경우
      view.endEditing(true)
    }
  }
}

extension EditBoardViewController {
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
    
    containerView.snp.updateConstraints {
      $0.bottom.lessThanOrEqualToSuperview().inset(keyboardHeight)
    }
    
    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }
  
  @objc
  func keyboardWillHide(_ sender: Notification) {
    containerView.snp.updateConstraints {
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }
}

extension EditBoardViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == titleTextField {
      contentTextView.becomeFirstResponder()
    }
    return true
  }
}
