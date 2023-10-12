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

    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: Constants.backButton),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
    studyRoomDetailView.configureUI(with: .init(
      roomTitle: title ?? "",
      roomDestination: "일립관6층, 로뎀",
      roomDescription: """
    그룹학습실은 한국성서대학교 학생이라면
    누구나 대관해서 공부나 팀프로젝트, 개인프로젝트, 과제 등등
    학습을 위해서라면 언제든 대관을 해드립니다!


    Q1. 운영시간은 어떻게 되나요?
    A1. 매주 월~금 09:00 ~ 17:20까지 운영하고 있습니다.
           (채플 및 점심시간인 12:00 ~ 13:30에는 운영하지 않습니다.)


    Q2. 대관할 때는 무엇이 필요한가요??
    A2. 학생증만 들고오시면 됩니다. 다만 취식물 반입은 금지입니다!!


    Q3. 들어갈 수 있는 인원이 제한이 있나요??
    A3. 현재는 코로나로 인한 5인 이상 집합금지라서 최대 4인으로 제한을 두고 있습니다.
           하지만 평소에는 대관하시는 방의 크기에 따라 인원수가 제한됩니다.
           아래의 사진을 참고하시면 될 것 같습니다.
    """
    ))
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
      $0.height.equalTo(UIScreen.main.bounds.height / 2)
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
