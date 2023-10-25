//
//  StudyRoomDetailViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/19.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class StudyRoomDetailViewController: BaseViewController {
  
  private let viewModel: StudyRoomDetailViewModelType
  
  private let studyRoomImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
  }
  
  private lazy var studyRoomDetailView = RothemRoomDetailView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.maskedCorners = CACornerMask(
      arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner
    )
    $0.delegate = self
    $0.backgroundColor = .white
  }
  
  init(viewModel: StudyRoomDetailViewModelType) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()

    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: Constants.backButton),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
    
  }
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [studyRoomImageView, studyRoomDetailView].forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    studyRoomDetailView.snp.makeConstraints {
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
      $0.height.equalTo(((UIScreen.main.bounds.height - UINavigationController().navigationBar.frame.height) / 3) * 2)
    }

    
    studyRoomImageView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.equalTo(studyRoomDetailView.snp.top).offset(40)
    }
  }
  
  override func bind() {
    super.bind()
    viewModel.rothemRoomDetailViewModel
      .drive(with: self) { owner, rothemRoomDetailViewModel in
        owner.studyRoomDetailView.configureUI(with: rothemRoomDetailViewModel)
      }
      .disposed(by: disposeBag)
    
    viewModel.rothemRoomThumbnailImage
      .compactMap { URL(string: $0) }
      .drive(with: self) { owner, thumbnailImageURL in
        owner.studyRoomImageView.kf.setImage(with: thumbnailImageURL)
      }
      .disposed(by: disposeBag)
  }
}

extension StudyRoomDetailViewController: RothemRoomDetailViewDelegate {
  func didTappedReservationButton() {
    let vc = StudyReservationViewController()
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
}
