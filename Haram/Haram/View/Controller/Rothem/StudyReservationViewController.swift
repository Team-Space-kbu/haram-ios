//
//  StudyReservationViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/18.
//

import UIKit

import SnapKit
import Then

final class StudyReservationViewController: BaseViewController {
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
    $0.showsVerticalScrollIndicator = false
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 16
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: .zero, left: 15, bottom: 4, right: 15)
  }
  
  private let studyRoomInfoView = StudyRoomInfoView()
  
  private let selectedDayLabel = UILabel().then {
    $0.text = "날짜선택"
    $0.font = .bold18
    $0.textColor = .black
  }
  
  private lazy var selectedDayCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.scrollDirection = .vertical
      $0.minimumInteritemSpacing = 18
    }).then {
      $0.backgroundColor = .white
      $0.isScrollEnabled = false
      $0.delegate = self
      $0.dataSource = self
      $0.register(SelectedDayCollectionViewCell.self, forCellWithReuseIdentifier: SelectedDayCollectionViewCell.identifier)
    }
  
  private let selectedTimeLabel = UILabel().then {
    $0.text = "시간선택"
    $0.font = .bold18
    $0.textColor = .black
  }
  
  private lazy var selectedTimeCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: LeftAlignedCollectionViewFlowLayout().then {
      $0.sectionInset = UIEdgeInsets(top: .zero, left: .zero, bottom: 19, right: .zero)
      $0.minimumInteritemSpacing = 15
    }).then {
      $0.isScrollEnabled = false
      $0.backgroundColor = .white
      $0.delegate = self
      $0.dataSource = self
      $0.register(SelectedTimeCollectionViewCell.self, forCellWithReuseIdentifier: SelectedTimeCollectionViewCell.identifier)
      $0.register(SelectedTimeCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SelectedTimeCollectionHeaderView.identifier)
    }
  
  private let reservationInfoLabel = UILabel().then {
    $0.text = "예약자정보"
    $0.font = .bold18
    $0.textColor = .black
  }
  
  private let nameTextField = UITextField().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.hexD0D0D0.cgColor
    $0.backgroundColor = .hexF5F5F5
    $0.leftViewMode = .always
    $0.leftView = UIView(frame: .init(x: .zero, y: .zero, width: 20, height: .zero))
    $0.attributedPlaceholder = NSAttributedString(
      string: "이름",
      attributes: [.foregroundColor: UIColor.black]
    )
  }
  
  private let phoneNumberTextField = UITextField().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.hexD0D0D0.cgColor
    $0.backgroundColor = .hexF5F5F5
    $0.leftViewMode = .always
    $0.leftView = UIView(frame: .init(x: .zero, y: .zero, width: 20, height: .zero))
    $0.attributedPlaceholder = NSAttributedString(
      string: "전화번호",
      attributes: [.foregroundColor: UIColor.black]
    )
  }
  
  private let reservationButton = UIButton().then {
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .hex79BD9A
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.titleLabel?.font = .bold22
    $0.setTitle("예약하기", for: .normal)
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "예약하기"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "back"),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
    
    studyRoomInfoView.configureUI(with: .init(roomImageURL: nil, roomName: "스터디룸1", roomDescription: "안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요"))
  }
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    [studyRoomInfoView, selectedDayLabel, selectedDayCollectionView, selectedTimeLabel, selectedTimeCollectionView, reservationInfoLabel, nameTextField, phoneNumberTextField, reservationButton].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    scrollView.snp.makeConstraints {
      $0.directionalVerticalEdges.width.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.width.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    studyRoomInfoView.snp.makeConstraints {
      $0.height.equalTo(98)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
    }
    
    selectedDayLabel.snp.makeConstraints {
      $0.height.equalTo(22 + 16)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
    }
    
    selectedDayCollectionView.snp.makeConstraints {
      $0.height.equalTo(69)
      //      $0.leading.equalToSuperview()
      //      $0.trailing.lessThanOrEqualToSuperview()
    }
    
    selectedTimeLabel.snp.makeConstraints {
      $0.height.equalTo(22 + 16)
    }
    
    selectedTimeCollectionView.snp.makeConstraints {
      $0.height.equalTo(131)
    }
    
    nameTextField.snp.makeConstraints {
      $0.height.equalTo(40)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
    }
    
    phoneNumberTextField.snp.makeConstraints {
      $0.height.equalTo(40)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
    }
    
    reservationButton.snp.makeConstraints {
      $0.height.equalTo(49)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
    }
    
    containerView.setCustomSpacing(26, after: selectedDayCollectionView)
    containerView.setCustomSpacing(26, after: selectedTimeCollectionView)
    containerView.setCustomSpacing(89 - 15 - 49, after: phoneNumberTextField)
  }
}

extension StudyReservationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    if collectionView == selectedDayCollectionView {
      return 1
    }
    return 2
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == selectedDayCollectionView {
      return 5
    }
    return 4
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == selectedTimeCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedTimeCollectionViewCell.identifier, for: indexPath) as? SelectedTimeCollectionViewCell ?? SelectedTimeCollectionViewCell()
      cell.configureUI(with: .init(time: "10:00"))
      return cell
    }
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedDayCollectionViewCell.identifier, for: indexPath) as? SelectedDayCollectionViewCell ?? SelectedDayCollectionViewCell()
    cell.configureUI(with: .init(title: "월요일", day: "01"))
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if collectionView == selectedTimeCollectionView {
      let header = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: SelectedTimeCollectionHeaderView.identifier,
        for: indexPath
      ) as? SelectedTimeCollectionHeaderView ?? SelectedTimeCollectionHeaderView()
      header.configureUI(with: indexPath.section == 0 ? "오전" : "오후")
      return header
    }
    return UICollectionReusableView()
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    if collectionView == selectedTimeCollectionView {
      return CGSize(width: collectionView.frame.width - 30, height: 17 + 6)
    }
    return .zero
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView == selectedDayCollectionView {
      return CGSize(width: (collectionView.frame.width - (18 * 4) - 30) / 5, height: 69)
    }
    return CGSize(width: 64, height: 33)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedDayCollectionViewCell.identifier, for: indexPath) as? SelectedDayCollectionViewCell ?? SelectedDayCollectionViewCell()
    
  }
  
  //  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
  //    if collectionView == selectedDayCollectionView {
  //      return 18
  //    }
  //    return 15
  //  }
}
