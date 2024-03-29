//
//  StudyReservationViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/18.
//

import UIKit

import SnapKit
import SkeletonView
import Then

final class StudyReservationViewController: BaseViewController {
  
  private let viewModel: StudyReservationViewModelType
  
  private var selectedDateModel: [SelectedDayCollectionViewCellModel] = [] {
    didSet {
      selectedDayCollectionView.reloadData()
    }
  }
  
  private var selectedTimeModel: [SelectedTimeCollectionViewCellModel] = [] {
    didSet {
      selectedTimeCollectionView.reloadData()
    }
  }
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
    $0.showsVerticalScrollIndicator = false
    $0.isSkeletonable = true
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 16
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: .zero, left: 15, bottom: 4, right: 15)
    $0.isSkeletonable = true
  }
  
  private let studyRoomInfoView = StudyRoomInfoView()
  
  private let selectedDayLabel = UILabel().then {
    $0.text = "날짜선택"
    $0.font = .bold18
    $0.textColor = .black
    $0.isSkeletonable = true
  }
  
  private let selectedDayCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.scrollDirection = .vertical
      $0.minimumInteritemSpacing = 18
    }).then {
      $0.backgroundColor = .white
      $0.isScrollEnabled = false
      $0.register(SelectedDayCollectionViewCell.self, forCellWithReuseIdentifier: SelectedDayCollectionViewCell.identifier)
      $0.isSkeletonable = true
    }
  
  private let selectedTimeLabel = UILabel().then {
    $0.text = "시간선택"
    $0.font = .bold18
    $0.textColor = .black
    $0.isSkeletonable = true
  }
  
  private let selectedTimeCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: LeftAlignedCollectionViewFlowLayout().then {
      $0.sectionInset = UIEdgeInsets(top: .zero, left: .zero, bottom: 19, right: .zero)
      $0.minimumInteritemSpacing = 15
      $0.minimumLineSpacing = 6
    }).then {
      $0.isScrollEnabled = false
      $0.backgroundColor = .white
      $0.register(SelectedTimeCollectionViewCell.self, forCellWithReuseIdentifier: SelectedTimeCollectionViewCell.identifier)
      $0.register(SelectedTimeCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SelectedTimeCollectionHeaderView.identifier)
      $0.allowsMultipleSelection = true
      $0.isSkeletonable = true
      $0.isScrollEnabled = false
      $0.showsVerticalScrollIndicator = false
    }
  
  private let reservationInfoLabel = UILabel().then {
    $0.text = "예약자정보"
    $0.font = .bold18
    $0.textColor = .black
    $0.isSkeletonable = true
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
      attributes: [.foregroundColor: UIColor.hex9F9FA4]
    )
    $0.isSkeletonable = true
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
      attributes: [.foregroundColor: UIColor.hex9F9FA4]
    )
    $0.isSkeletonable = true
    $0.keyboardType = .phonePad
  }
  
  private let reservationButton = HaramButton(type: .cancel).then {
    $0.setTitleText(title: "예약하기")
    $0.isSkeletonable = true
  }
  
  private let tapGesture = UITapGestureRecognizer(target: StudyReservationViewController.self, action: nil).then {
    $0.numberOfTapsRequired = 1
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  private let panGesture = UIPanGestureRecognizer(target: StudyReservationViewController.self, action: nil).then {
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  init(viewModel: StudyReservationViewModelType) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    removeNotifications()
  }
  
  override func bind() {
    super.bind()
    
    reservationButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.viewModel.reservationButtonTapped.onNext(())
      }
      .disposed(by: disposeBag)
    
    viewModel.studyRoomInfoViewModel
      .drive(with: self) { owner, model in
        owner.studyRoomInfoView.configureUI(with: model)
      }
      .disposed(by: disposeBag)
    
    viewModel.selectedDayCollectionViewCellModel
      .drive(rx.selectedDateModel)
      .disposed(by: disposeBag)
    
    viewModel.selectedTimeCollectionViewCellModel
      .drive(with: self) { owner, model in
        owner.selectedTimeModel = model
      }
      .disposed(by: disposeBag)
    
    viewModel.selectedPolicyModel
      .drive(with: self) { owner, models in
        models.forEach { model in
          let checkView = TermsOfUseCheckView()
          checkView.configureUI(with: model)
          owner.containerView.insertArrangedSubview(checkView, at: 1)
        }
      }
      .disposed(by: disposeBag)
    
    phoneNumberTextField.rx.text.orEmpty
      .filter { $0 != "전화번호" }
      .subscribe(with: self) { owner, phoneNum in
        owner.viewModel.whichReservationPhoneNumber.onNext(phoneNum)
      }
      .disposed(by: disposeBag)
    
    viewModel.isReservationButtonActivated
      .drive(with: self) { owner, isActivated in
        owner.reservationButton.isEnabled = isActivated
        owner.reservationButton.setupButtonType(type: isActivated ? .apply : .cancel )
      }
      .disposed(by: disposeBag)
    
    viewModel.successRothemReservation
      .emit(with: self) { owner, _ in
        let vc = owner.navigationController?.viewControllers[1]
        owner.navigationController?.popToViewController(vc!, animated: true)
      }
      .disposed(by: disposeBag)
    
    tapGesture.rx.event
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.view.endEditing(true)
      }
      .disposed(by: disposeBag)
    
    panGesture.rx.event
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.view.endEditing(true)
      }
      .disposed(by: disposeBag)
    
    viewModel.isLoading
      .filter { !$0 }
      .drive(with: self) { owner, _ in
        owner.view.hideSkeleton()
      }
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    /// Configure NavigationBar
    title = "예약하기"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: Constants.backButton),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
    
    /// Set Delegate & DataSource
    selectedDayCollectionView.delegate = self
    selectedDayCollectionView.dataSource = self
    selectedTimeCollectionView.delegate = self
    selectedTimeCollectionView.dataSource = self
    
    /// Set Gesture
    _ = [tapGesture, panGesture].map { view.addGestureRecognizer($0) }
    panGesture.delegate = self
    
    registerNotifications()
    
    /// Configure Skeleton
    view.isSkeletonable = true
    let skeletonAnimation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .topLeftBottomRight)

    let graient = SkeletonGradient(baseColor: .skeletonDefault)
    view.showAnimatedGradientSkeleton(
      usingGradient: graient,
      animation: skeletonAnimation,
      transition: .none
    )
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
    }
    
    selectedDayLabel.snp.makeConstraints {
      $0.height.equalTo(22 + 16)
    }
    
    selectedDayCollectionView.snp.makeConstraints {
      $0.height.equalTo(69)
    }
    
    selectedTimeLabel.snp.makeConstraints {
      $0.height.equalTo(22 + 16)
    }
    
    selectedTimeCollectionView.snp.makeConstraints {
//      $0.height.equalTo(131 + 33 + 6 + 33 + 6)
      $0.height.equalTo(131 + 6 + 33 + 6 + 33 + 6 + 33 + 10)
    }
    
    nameTextField.snp.makeConstraints {
      $0.height.equalTo(40)
    }
    
    phoneNumberTextField.snp.makeConstraints {
      $0.height.equalTo(40)
    }
    
    reservationButton.snp.makeConstraints {
      $0.height.equalTo(49)
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
      return selectedDateModel.count
    }
    if section == 0 {
      return selectedTimeModel.filter { $0.meridiem == .am }.count
    }
    return selectedTimeModel.filter { $0.meridiem == .pm }.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == selectedTimeCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedTimeCollectionViewCell.identifier, for: indexPath) as? SelectedTimeCollectionViewCell ?? SelectedTimeCollectionViewCell()
      cell.configureUI(with: indexPath.section == 0 ? selectedTimeModel.filter { $0.meridiem == .am }[indexPath.row] : selectedTimeModel.filter { $0.meridiem == .pm }[indexPath.row])
      return cell
    }
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedDayCollectionViewCell.identifier, for: indexPath) as? SelectedDayCollectionViewCell ?? SelectedDayCollectionViewCell()
    cell.configureUI(with: selectedDateModel[indexPath.row])
    
    /// 이용가능한 날짜가 존재한다면 맨 처음 셀을 선택
    if let row = selectedDateModel.firstIndex(where: { $0.isAvailable }) {
      collectionView.selectItem(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: .left)
    }
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
    if collectionView == selectedDayCollectionView {
      viewModel.whichCalendarSeq.onNext(selectedDateModel[indexPath.row].calendarSeq)
    } else if collectionView == selectedTimeCollectionView {
      if indexPath.section == 0 {
        let isSelected = selectedTimeModel[indexPath.row].isTimeSelected
        let timeSeq = selectedTimeModel[indexPath.row].timeSeq
        isSelected ? viewModel.deSelectTimeSeq.onNext(timeSeq) : viewModel.selectTimeSeq.onNext(timeSeq)
      } else if indexPath.section == 1 {
        let amCount = selectedTimeModel.filter { $0.meridiem == .am }.count
        let isSelected = selectedTimeModel[indexPath.row + amCount].isTimeSelected
        let timeSeq = selectedTimeModel[indexPath.row + amCount].timeSeq
        isSelected ? viewModel.deSelectTimeSeq.onNext(timeSeq) : viewModel.selectTimeSeq.onNext(timeSeq)
      }
    }
  }
}

// MARK: - SkeletonViewDataSource
extension StudyReservationViewController: SkeletonCollectionViewDataSource {
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
    if skeletonView == selectedDayCollectionView {
      return SelectedDayCollectionViewCell.identifier
    }
    return SelectedTimeCollectionViewCell.identifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    if skeletonView == selectedDayCollectionView {
      return skeletonView.dequeueReusableCell(withReuseIdentifier: SelectedDayCollectionViewCell.identifier, for: indexPath) as? SelectedDayCollectionViewCell
    }
    return skeletonView.dequeueReusableCell(withReuseIdentifier: SelectedTimeCollectionViewCell.identifier, for: indexPath) as? SelectedTimeCollectionViewCell
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if skeletonView == selectedDayCollectionView {
      return 5
    }
    return section == 0 ? 6 : 4
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, supplementaryViewIdentifierOfKind: String, at indexPath: IndexPath) -> ReusableCellIdentifier? {
    if skeletonView == selectedTimeCollectionView {
      return SelectedTimeCollectionHeaderView.identifier
    }
    return nil
  }
  
  func numSections(in collectionSkeletonView: UICollectionView) -> Int {
    if collectionSkeletonView == selectedTimeCollectionView {
      return 2
    }
    return 1
  }
}

// MARK: - UIGestureRecognizerDelegate

extension StudyReservationViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}

extension StudyReservationViewController: KeyboardResponder {
  public var targetView: UIView {
    view
  }
}
