//
//  StudyRoomDetailViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/19.
//

import UIKit

import SnapKit
import Then

final class StudyRoomDetailViewController: BaseViewController {
  private let studyRoomImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.image = UIImage(named: "studyRoom")
  }
  
  private lazy var studyRoomDetailView = StudyRoomDetailView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.maskedCorners = CACornerMask(
      arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner
    )
    $0.delegate = self
    $0.backgroundColor = .white
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "스터디룸1"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "back"),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
    studyRoomDetailView.configureUI(with: .init(roomTitle: "스터디룸1", roomDestination: "일립관6층, 로뎀", roomDescription: "안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요"))
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
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.equalToSuperview().inset(42)
      $0.height.equalTo(469)
    }

    
    studyRoomImageView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.equalTo(studyRoomDetailView.snp.top).offset(40)
    }
  }
}

extension StudyRoomDetailViewController: StudyRoomDetailViewDelegate {
  func didTappedReservationButton() {
    let vc = StudyReservationViewController()
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
}
