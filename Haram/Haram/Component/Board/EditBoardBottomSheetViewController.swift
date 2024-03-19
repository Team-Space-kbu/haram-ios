//
//  EditBoardBottomSheetViewController.swift
//  Haram
//
//  Created by 이건준 on 3/5/24.
//

import UIKit

import SnapKit
import Then
import PhotosUI

protocol EditBoardBottomSheetViewDelegate: AnyObject {
  func didTappedSelectedMenu()
  func whichSelectedImage(with image: UIImage)
  func whichSelectedImages(with itemProviders: [NSItemProvider])
}

final class EditBoardBottomSheetViewController: BaseViewController {
  
  weak var delegate: EditBoardBottomSheetViewDelegate?
  
  private lazy var photoPicker = UIImagePickerController()
//    .then {
//    $0.delegate = self
//  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 30, left: 23, bottom: .zero, right: 23)
//    $0.spacing = 17
  }
  
  private let registerImageMenuView = EditBoardMenuView(type: .registerImage)
  private let registerAnonymousMenuView = EditBoardMenuView(type: .registerAnonymous)
  
  override func bind() {
    super.bind()
    
    registerImageMenuView.button.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedSelectedMenu()
//        owner.photoPicker.sourceType = .photoLibrary
//        owner.present(owner.photoPicker, animated: true)
      }
      .disposed(by: disposeBag)
    
    registerAnonymousMenuView.button.rx.tap
      .subscribe(with: self) { owner, _ in
//        owner.delegate?.didTappedAnonymousMenu()
      }
      .disposed(by: disposeBag)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(containerView)
    _ = [registerImageMenuView, registerAnonymousMenuView].map { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    _ = [registerImageMenuView, registerAnonymousMenuView].map {
      $0.snp.makeConstraints {
        $0.height.equalTo(22 + 17)
      }
    }
  }
}

extension EditBoardBottomSheetViewController {
  final class EditBoardMenuView: UIView {
    
    private let type: EditBoardMenuViewType
    
    let button = UIButton()
    
    private let editImageView = UIImageView().then {
      $0.contentMode = .scaleAspectFill
    }
    
    private let editLabel = UILabel().then {
      $0.font = .bold18
      $0.textColor = .hex1A1E27
    }
    
    private let indicatorImageView = UIImageView().then {
      $0.image = UIImage(resource: .darkIndicator)
      $0.contentMode = .scaleAspectFill
    }
    
    init(type: EditBoardMenuViewType) {
      self.type = type
      super.init(frame: .zero)
      configureUI()
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
      _ = [editImageView, editLabel, indicatorImageView, button].map { addSubview($0) }
      
      button.snp.makeConstraints {
        $0.directionalEdges.equalToSuperview()
      }
      
      editImageView.snp.makeConstraints {
        $0.leading.top.equalToSuperview()
        $0.size.equalTo(19.5)
      }
      
      editLabel.snp.makeConstraints {
        $0.centerY.equalTo(editImageView)
//        $0.top.greaterThanOrEqualToSuperview()
//        $0.bottom.lessThanOrEqualToSuperview()
        $0.leading.equalTo(editImageView.snp.trailing).offset(10)
      }
      
      indicatorImageView.snp.makeConstraints {
//        $0.top.greaterThanOrEqualToSuperview()
//        $0.bottom.lessThanOrEqualToSuperview()
        $0.leading.greaterThanOrEqualTo(editLabel.snp.trailing)
        $0.trailing.equalToSuperview()
        $0.width.equalTo(6)
        $0.height.equalTo(12)
        $0.centerY.equalTo(editImageView)
      }
      
      editImageView.image = UIImage(resource: type.imageResource)
      editLabel.text = type.title
    }
  }
  
  enum EditBoardMenuViewType {
    case registerImage
    case registerAnonymous
    
    var title: String {
      switch self {
      case .registerImage:
        return "사진등록"
      case .registerAnonymous:
        return "익명성등록"
      }
    }
    
    var imageResource: ImageResource {
      switch self {
      case .registerImage:
        return .blueRocket
      case .registerAnonymous:
        return .boardPurple
      }
    }
  }
}

//extension EditBoardBottomSheetViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//  func imagePickerController(
//    _ picker: UIImagePickerController,
//    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
//  ) {
//    guard let selectedImage = info[.originalImage] as? UIImage else { return }
//    delegate?.whichSelectedImage(with: selectedImage)
//    picker.dismiss(animated: true)
//  }
//  
//  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//    picker.dismiss(animated: true)
//  }
//}
