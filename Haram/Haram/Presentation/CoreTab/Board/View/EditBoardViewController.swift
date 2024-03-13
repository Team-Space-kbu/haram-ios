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
  
  private lazy var editBoardBottomSheet = EditBoardBottomSheetViewController().then {
    $0.delegate = self
  }
  
  private lazy var photoPicker = UIImagePickerController().then {
    $0.delegate = self
    $0.sourceType = .photoLibrary
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
  
  init(categorySeq: Int, viewModel: EditBoardViewModelType = EditBoardViewModel()) {
    self.viewModel = viewModel
    self.categorySeq = categorySeq
    super.init(nibName: nil, bundle: nil)
  }
  
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    titleTextView.text = Constants.titlePlaceholder
    contentTextView.text = Constants.contentPlaceholder
    
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
        if owner.titleTextView.text.trimmingCharacters(in: .whitespacesAndNewlines) == Constants.titlePlaceholder &&
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
          owner.titleTextView.text = Constants.titlePlaceholder
          owner.titleTextView.textColor = .hexD0D0D0
        }
        
        owner.updateTextViewHeightAutomatically(textView: owner.titleTextView)
      }
      .disposed(by: disposeBag)
    
    titleTextView.rx.text.orEmpty
    //      .skip(1)
      .filter { $0 != Constants.titlePlaceholder }
      .asDriver(onErrorDriveWith: .empty())
      .drive(with: self){ owner, text in
        owner.updateTextViewHeightAutomatically(textView: owner.titleTextView)
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
        
        owner.updateTextViewHeightAutomatically(textView: owner.contentTextView, height: 209)
      }
      .disposed(by: disposeBag)
    
    navigationItem.rightBarButtonItem!.rx.tap
      .subscribe(with: self) { owner, _ in
        let title = owner.titleTextView.text!
        let content = owner.contentTextView.text!

        owner.viewModel.createBoard(categorySeq: owner.categorySeq, title: title, contents: content, isAnonymous: false)
      }
      .disposed(by: disposeBag)
    
    
    contentTextView.rx.text.orEmpty
    //      .skip(1)
      .filter { $0 != Constants.contentPlaceholder }
      .asDriver(onErrorDriveWith: .empty())
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
    
    viewModel.successUploadImage
      .emit(with: self) { owner, result in
        let (_, image) = result
        owner.imageModel.append(image)
        owner.editBoardCollectionView.reloadData()
        //        owner.imageModel.append()
      }
      .disposed(by: disposeBag)
    
    viewModel.successCreateBoard
      .emit(with: self) { owner, _ in
        NotificationCenter.default.post(name: .refreshBoardList, object: nil)
        owner.navigationController?.popViewController(animated: true)
      }
      .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        AlertManager.showAlert(title: error.description!, viewController: owner, confirmHandler: nil)
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
  
  //  private func presentPicker() {
  //    var config = PHPickerConfiguration()
  //    config.selectionLimit = 8
  //    config.filter = .images
  //    config.selection = .ordered
  //
  //    let picker = PHPickerViewController(configuration: config)
  ////    picker.delegate = self
  //    present(picker, animated: true)
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
        .full: FloatingPanelLayoutAnchor(fractionalInset: 0.6, edge: .bottom, referenceGuide: .safeArea),
        .half: FloatingPanelLayoutAnchor(absoluteInset: 198 - Device.bottomInset, edge: .bottom, referenceGuide: .superview),
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
  func didTappedSelectedMenu() {
    //    presentPicker()
    present(photoPicker, animated: true)
  }
  
  func whichSelectedImages(with itemProviders: [NSItemProvider]) {
    // 만약 itemProvider에서 UIImage로 로드가 가능하다면?
    
  }
  
  func didTappedAnonymousMenu() {
    
  }
  
  func whichSelectedImage(with image: UIImage) {
    //    if imageModel.count < 8 { // 이미지 삽입 최대 갯수 8개제한
    //      imageModel.append(image)
    //      editBoardCollectionView.reloadData()
    //    }
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

//extension EditBoardViewController: PHPickerViewControllerDelegate {
//  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//    picker.dismiss(animated: true)
//
//    // 만들어준 itemProviders에 Picker로 선택한 이미지정보를 전달
//    let itemProviders = results.map(\.itemProvider)
//
//    // 만약에 삽입한 이미지 갯수가 최대갯수인 8개를 넘어선 경우
//    if itemProviders.count + imageModel.count > 8 {
//      AlertManager.showAlert(title: "이미지 등록은 최대 8개입니다.", viewController: self, confirmHandler: nil)
//      return
//    }
//
//    for itemProvider in itemProviders {
//      if itemProvider.canLoadObject(ofClass: UIImage.self) {
//        // 로드 핸들러를 통해 UIImage를 처리해 줍시다.
//        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
//
//          guard let self = self,
//                let image = image as? UIImage else { return }
//
//          if let assetIdentifier = results.first?.assetIdentifier,
//             let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject {
//            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: nil) { data, _, _, _ in
//              if let imageData = data, let assetFileName = asset.value(forKey: "filename") as? String {
//                print("파일이름 \(assetFileName)")
//              }
//            }
//          }
//
//          //          self.viewModel.uploadImage(image: image, type: .board)
//        }
//      }
//    }
//  }
//}

extension EditBoardViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    guard let selectedImage = info[.originalImage] as? UIImage else { return }
    
    // 이미지 파일명 가져오기
    if let imageURL = info[.imageURL] as? URL {
      let fileName = imageURL.lastPathComponent
      print("Selected image file name: \(fileName)")
      
      // 선택된 이미지를 업로드
      viewModel.uploadImage(image: selectedImage, type: .board, fileName: fileName)
    }
    
    picker.dismiss(animated: true)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true) {
      self.dismiss(animated: true)
    }
  }
}
