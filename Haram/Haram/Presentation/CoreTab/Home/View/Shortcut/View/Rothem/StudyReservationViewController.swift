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

final class StudyReservationViewController: BaseViewController, BackButtonHandler {
  
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
  
  private let studyRoomInfoView = StudyRoomInfoView().then {
    $0.isSkeletonable = true
  }
  
  private let selectedDayLabel = UILabel().then {
    $0.text = "날짜선택"
    $0.font = .bold18
    $0.textColor = .black
    $0.isSkeletonable = true
  }
  
  private let selectedDayCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.scrollDirection = .horizontal
      $0.minimumLineSpacing = 2
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
  
  private let nameTextField = HaramTextField(placeholder: "이름").then {
    $0.isSkeletonable = true
    $0.textField.isSkeletonable = true
  }
  
  private let phoneNumberTextField = HaramTextField(
    placeholder: "전화번호(- 없이 입력)",
    options: .errorLabel
  ).then {
    $0.textField.keyboardType = .phonePad
    $0.isSkeletonable = true
    $0.textField.isSkeletonable = true
  }
  
  private let reservationButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "예약하기", contentInsets: .zero)
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = 10
    $0.isEnabled = false
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
    removeNotification()
  }
  
  override func bind() {
    super.bind()
    
    viewModel.inquireReservationInfo()
    
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
      .asObservable()
      .take(1)
      .subscribe(with: self) { owner, models in
        models.forEach { model in
          let checkView = TermsOfUseCheckView()
          checkView.delegate = owner
          checkView.configureUI(with: model)
          owner.containerView.insertArrangedSubview(checkView, at: 1)
        }
      }
      .disposed(by: disposeBag)
    
    nameTextField.rx.text.orEmpty
      .subscribe(with: self) { owner, userName in
        owner.viewModel.whichReservationName.onNext(userName)
      }
      .disposed(by: disposeBag)
    
    phoneNumberTextField.rx.text.orEmpty
      .subscribe(with: self) { owner, phoneNum in
        owner.viewModel.whichReservationPhoneNumber.onNext(phoneNum)
      }
      .disposed(by: disposeBag)
    
    viewModel.isReservationButtonActivated
      .drive(with: self) { owner, isActivated in
        owner.reservationButton.isEnabled = isActivated
      }
      .disposed(by: disposeBag)
    
    viewModel.successRothemReservation
      .emit(with: self) { owner, _ in
        owner.phoneNumberTextField.removeError()
        NotificationCenter.default.post(name: .refreshRothemList, object: nil)
        
        AlertManager.showAlert(title: "로뎀예약알림", message: "성공적으로 예약하였습니다\n메인화면으로 이동합니다.", viewController: owner) {
          let vc = owner.navigationController?.viewControllers[1]
          owner.navigationController?.popToViewController(vc!, animated: true)
        }
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
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        if error == .maxReservationCount || error == .nonConsecutiveReservations {
          AlertManager.showAlert(title: "로뎀예약알림", message: error.description!, viewController: owner, confirmHandler: nil)
          return
        } else if error == .networkError {
          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요.", viewController: owner) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          }
          return
        }
        owner.phoneNumberTextField.setError(description: error.description!)
      }
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    /// Configure NavigationBar
    title = "예약하기"
    setupBackButton()
    
    /// Set Delegate & DataSource
    selectedDayCollectionView.delegate = self
    selectedDayCollectionView.dataSource = self
    selectedTimeCollectionView.delegate = self
    selectedTimeCollectionView.dataSource = self
    
    /// Set Gesture
    _ = [tapGesture, panGesture].map { view.addGestureRecognizer($0) }
    panGesture.delegate = self
    
    registerNotifications()
    registerNotification()
    
    setupSkeletonView()
  }
  
  @objc func didTappedBackButton() {
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
      $0.height.equalTo(22)
    }
    
    containerView.setCustomSpacing(16, after: selectedDayLabel)
    
    selectedDayCollectionView.snp.makeConstraints {
      $0.height.equalTo(69)
    }
    
    selectedTimeLabel.snp.makeConstraints {
      $0.height.equalTo(22)
    }
    
    containerView.setCustomSpacing(16, after: selectedTimeLabel)
    
    selectedTimeCollectionView.snp.makeConstraints {
      $0.height.equalTo(33 * 5 + 3 * 6 + 23 * 2 + 19 * 2)
    }
    
    nameTextField.snp.makeConstraints {
      $0.height.equalTo(40)
    }
    
    phoneNumberTextField.snp.makeConstraints {
      $0.height.greaterThanOrEqualTo(40)
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
      return CGSize(width: collectionView.frame.width - 30, height: 23)
    }
    return .zero
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView == selectedDayCollectionView {
      return CGSize(width: (collectionView.frame.width - (2 * 4)) / 5, height: 69)
    }
    return CGSize(width: 64, height: 33)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView == selectedDayCollectionView {
      if selectedDateModel[indexPath.row].isAvailable {
        viewModel.whichCalendarSeq.onNext(selectedDateModel[indexPath.row].calendarSeq)
        let cell = collectionView.cellForItem(at: indexPath) as? SelectedDayCollectionViewCell ?? SelectedDayCollectionViewCell()
        cell.showAnimation(scale: 0.98) {}
      }
    } else if collectionView == selectedTimeCollectionView {
      
        let cell = collectionView.cellForItem(at: indexPath) as? SelectedTimeCollectionViewCell ?? SelectedTimeCollectionViewCell()
        cell.showAnimation(scale: 0.98) { [weak self] in
          guard let self = self else { return }
          let timeModel = self.selectedTimeModel[indexPath.row]
          if indexPath.section == 0 {
            if !selectedTimeModel[indexPath.row].isReserved {
              let isSelected = timeModel.isTimeSelected
              let timeSeq = timeModel.timeSeq
              isSelected ? self.viewModel.deSelectTimeSeq.onNext(timeSeq) : self.viewModel.selectTimeSeq.onNext(timeSeq)
            } else {
              AlertManager.showAlert(title: "로뎀예약알림", message: "이미 예약된 시간이거나 지난 시간입니다\n다른 시간을 선택해주세요.", viewController: self, confirmHandler: nil)
            }
          } else if indexPath.section == 1 {
            let amCount = self.selectedTimeModel.filter { $0.meridiem == .am }.count
            if !selectedTimeModel[indexPath.row + amCount].isReserved {
              let isSelected = self.selectedTimeModel[indexPath.row + amCount].isTimeSelected
              let timeSeq = self.selectedTimeModel[indexPath.row + amCount].timeSeq
              isSelected ? self.viewModel.deSelectTimeSeq.onNext(timeSeq) : self.viewModel.selectTimeSeq.onNext(timeSeq)
            } else {
              AlertManager.showAlert(title: "로뎀예약알림", message: "이미 예약된 시간이거나 지난 시간입니다\n다른 시간을 선택해주세요.", viewController: self, confirmHandler: nil)
            }
          }
        }
      
    }
  }
  
//  func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
//    
//    if collectionView == selectedDayCollectionView {
//      if selectedDateModel[indexPath.row].isAvailable {
//        let cell = collectionView.cellForItem(at: indexPath) as? SelectedDayCollectionViewCell ?? SelectedDayCollectionViewCell()
//        cell.setHighlighted(isHighlighted: true)
//      }
//    } else if collectionView == selectedTimeCollectionView {
//      if !selectedTimeModel[indexPath.row].isReserved {
//        let cell = collectionView.cellForItem(at: indexPath) as? SelectedTimeCollectionViewCell ?? SelectedTimeCollectionViewCell()
//        cell.setHighlighted(isHighlighted: true)
//      }
//    }
//  }
//  
//  func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
//    
//    if collectionView == selectedDayCollectionView {
//      if selectedDateModel[indexPath.row].isAvailable {
//        let cell = collectionView.cellForItem(at: indexPath) as? SelectedDayCollectionViewCell ?? SelectedDayCollectionViewCell()
//        cell.setHighlighted(isHighlighted: false)
//      }
//    } else if collectionView == selectedTimeCollectionView {
//      if !selectedTimeModel[indexPath.row].isReserved {
//        let cell = collectionView.cellForItem(at: indexPath) as? SelectedTimeCollectionViewCell ?? SelectedTimeCollectionViewCell()
//        cell.setHighlighted(isHighlighted: false)
//      }
//    }
//  }
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
    return section == 0 ? 6 : 10
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

extension StudyReservationViewController: TermsOfUseCheckViewDelegate {
  func didTappedCheckBox(policySeq: Int, isChecked: Bool) {
    viewModel.checkCheckBox(policySeq: policySeq, isChecked: isChecked)
  }
}

extension StudyReservationViewController {
  private func registerNotification() {
    NotificationCenter.default.addObserver(self, selector: #selector(refreshWhenNetworkConnected), name: .refreshWhenNetworkConnected, object: nil)
  }
  
  private func removeNotification() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  private func refreshWhenNetworkConnected() {
    viewModel.inquireReservationInfo()
  }
}
