//
//  RothemRoomReservationViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/18.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import SkeletonView
import Then

final class RothemRoomReservationViewController: BaseViewController {
  
  private let viewModel: RothemRoomReservationViewModel
  private let tapTermsOfUseCell = PublishRelay<IndexPath>()
  
  private var policyModel: [TermsOfUseTableViewCellModel] = [] {
    didSet {
      termsOfUseTableView.reloadData()
    }
  }
  
  private var selectedDateModel: [SelectedDayCollectionViewCellModel] = [] {
    didSet {
      selectedDayCollectionView.reloadData()
    }
  }
  
  private var selectedAMModel: [SelectedTimeCollectionViewCellModel] = [] {
    didSet {
      selectedTimeCollectionView.reloadData()
    }
  }
  
  private var selectedPMModel: [SelectedTimeCollectionViewCellModel] = [] {
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
  
  private lazy var termsOfUseTableView = AutoSizingTableView(frame: .zero, style: .plain).then {
    $0.register(TermsOfUseTableViewCell.self)
    $0.dataSource = self
    $0.delegate = self
    $0.backgroundColor = .white
    $0.separatorStyle = .none
    $0.sectionFooterHeight = .leastNonzeroMagnitude
    $0.sectionHeaderHeight = .leastNonzeroMagnitude
    $0.isScrollEnabled = false
    $0.showsVerticalScrollIndicator = false
    $0.isSkeletonable = true
  }
  
  private let selectedDayLabel = UILabel().then {
    $0.text = "날짜선택"
    $0.font = .bold18
    $0.textColor = .black
    $0.isSkeletonable = true
  }
  
  private let selectedDayCollectionView = AutoSizingCollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.scrollDirection = .horizontal
      $0.minimumLineSpacing = 18
    }).then {
      $0.backgroundColor = .white
      $0.isScrollEnabled = false
      $0.register(SelectedDayCollectionViewCell.self)
      $0.isSkeletonable = true
    }
  
  private let selectedTimeLabel = UILabel().then {
    $0.text = "시간선택"
    $0.font = .bold18
    $0.textColor = .black
    $0.isSkeletonable = true
  }
  
  private let selectedTimeCollectionView = AutoSizingCollectionView(
    frame: .zero,
    collectionViewLayout: LeftAlignedCollectionViewFlowLayout().then {
      $0.sectionInset = UIEdgeInsets(top: .zero, left: .zero, bottom: 19, right: .zero)
      $0.minimumInteritemSpacing = 15
      $0.minimumLineSpacing = 6
    }).then {
      $0.backgroundColor = .white
      $0.register(SelectedTimeCollectionViewCell.self)
      $0.register(SelectedTimeCollectionHeaderView.self, of: UICollectionView.elementKindSectionHeader)
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
  
  private lazy var nameTextField = HaramTextField(placeholder: "이름").then {
    $0.isSkeletonable = true
    $0.textField.isSkeletonable = true
    $0.textField.delegate = self
  }
  
  private lazy var phoneNumberTextField = HaramTextField(
    placeholder: "전화번호(- 없이 입력)",
    options: .errorLabel
  ).then {
    $0.textField.keyboardType = .phonePad
    $0.isSkeletonable = true
    $0.textField.isSkeletonable = true
    $0.textField.delegate = self
  }
  
  private let reservationButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "예약하기", contentInsets: .zero)
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = 10
    $0.isEnabled = false
  }
  
  private let tapGesture = UITapGestureRecognizer(target: RothemRoomReservationViewController.self, action: nil).then {
    $0.numberOfTapsRequired = 1
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  private let panGesture = UIPanGestureRecognizer(target: RothemRoomReservationViewController.self, action: nil).then {
    $0.cancelsTouchesInView = false
    $0.isEnabled = true
  }
  
  init(viewModel: RothemRoomReservationViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    
    let input = RothemRoomReservationViewModel.Input(
      viewDidLoad: .just(()),
      didEditReservationName: nameTextField.rx.text.orEmpty.asObservable(),
      didEditReservationPhoneNumber: phoneNumberTextField.rx.text.orEmpty.asObservable(),
      didTapReservationDayCell: selectedDayCollectionView.rx.itemSelected.asObservable(),
      didTapReservationTimeCell: selectedTimeCollectionView.rx.itemSelected.asObservable(),
      didTapTermsOfUseCell: tapTermsOfUseCell.asObservable(),
      didTapReservationButton: reservationButton.rx.tap.asObservable(),
      didTapBackButton: navigationItem.leftBarButtonItem!.rx.tap.asObservable()
    )
    bindNotificationCenter(input: input)
    
    let output = viewModel.transform(input: input)
    output.studyRoomInfoViewModel
      .subscribe(with: self) { owner, model in
        owner.studyRoomInfoView.configureUI(with: model)
      }
      .disposed(by: disposeBag)
    
    output.selectedDayCollectionViewCellModel
      .bind(to: rx.selectedDateModel)
      .disposed(by: disposeBag)
    
    output.amModel
      .bind(to: rx.selectedAMModel)
      .disposed(by: disposeBag)
    
    output.pmModel
      .bind(to: rx.selectedPMModel)
      .disposed(by: disposeBag)
    
    output.policyModel
      .subscribe(with: self) { owner, model in
        owner.policyModel = model
      }
      .disposed(by: disposeBag)
    
    output.isEnabledReservationButton
      .bind(to: reservationButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    Observable.merge(
      tapGesture.rx.event.map { _ in Void() },
      panGesture.rx.event.map { _ in Void() }
    )
    .subscribe(with: self) { owner, _ in
      owner.view.endEditing(true)
    }
    .disposed(by: disposeBag)
    
    output.isLoading
      .filter { !$0 }
      .subscribe(with: self) { owner, _ in
        owner.view.hideSkeleton()
      }
      .disposed(by: disposeBag)
    
    output.errorMessage
      .compactMap { $0 }
      .subscribe(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(message: .networkUnavailable, actions: [
            DefaultAlertButton {
              guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
              if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
              }
            }
          ])
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
    
    setupSkeletonView()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    [studyRoomInfoView, termsOfUseTableView, selectedDayLabel, selectedDayCollectionView, selectedTimeLabel, selectedTimeCollectionView, reservationInfoLabel, nameTextField, phoneNumberTextField, reservationButton].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    scrollView.snp.makeConstraints {
      $0.top.width.equalToSuperview()
      $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
    }
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.width.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    studyRoomInfoView.snp.makeConstraints {
      $0.height.greaterThanOrEqualTo(98)
    }
    
    selectedDayCollectionView.snp.makeConstraints {
      $0.height.equalTo(75)
    }
    
    reservationButton.snp.makeConstraints {
      $0.height.equalTo(49)
    }
    
    containerView.setCustomSpacing(26, after: selectedDayCollectionView)
    containerView.setCustomSpacing(26, after: selectedTimeCollectionView)
    containerView.setCustomSpacing(89 - 15 - 49, after: phoneNumberTextField)
  }
}

extension RothemRoomReservationViewController {
  private func bindNotificationCenter(input: RothemRoomReservationViewModel.Input) {
    NotificationCenter.default.rx.notification(.refreshWhenNetworkConnected)
      .map { _ in Void() }
      .bind(to: input.didConnectNetwork)
      .disposed(by: disposeBag)
  }
}

extension RothemRoomReservationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
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
      return selectedAMModel.count
    }
    return selectedPMModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == selectedTimeCollectionView {
      let cell = collectionView.dequeueReusableCell(SelectedTimeCollectionViewCell.self, for: indexPath) ?? SelectedTimeCollectionViewCell()
      cell.configureUI(with: indexPath.section == 0 ? selectedAMModel[indexPath.row] : selectedPMModel[indexPath.row])
      return cell
    }
    let cell = collectionView.dequeueReusableCell(SelectedDayCollectionViewCell.self, for: indexPath) ?? SelectedDayCollectionViewCell()
    cell.configureUI(with: selectedDateModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if collectionView == selectedTimeCollectionView {
      let header = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: SelectedTimeCollectionHeaderView.reuseIdentifier,
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
      return CGSize(width: (collectionView.frame.width - (18 * 4)) / 5, height: 75)
    }
    return CGSize(width: 64, height: 33)
  }
  
  func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) else { return }
    cell.animateView(alpha: 0.5, scale: 0.9, duration: 0.1, completion: {})
  }
  
  func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) else { return }
    cell.animateView(alpha: 1, scale: 1, duration: 0.1, completion: {})
  }
}

// MARK: - SkeletonViewDataSource
extension RothemRoomReservationViewController: SkeletonCollectionViewDataSource {
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
    if skeletonView == selectedDayCollectionView {
      return SelectedDayCollectionViewCell.reuseIdentifier
    }
    return SelectedTimeCollectionViewCell.reuseIdentifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    if skeletonView == selectedDayCollectionView {
      return skeletonView.dequeueReusableCell(SelectedDayCollectionViewCell.self, for: indexPath)
    }
    return skeletonView.dequeueReusableCell(SelectedTimeCollectionViewCell.self, for: indexPath)
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if skeletonView == selectedDayCollectionView {
      return 5
    }
    return section == 0 ? 6 : 10
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, supplementaryViewIdentifierOfKind: String, at indexPath: IndexPath) -> ReusableCellIdentifier? {
    if skeletonView == selectedTimeCollectionView {
      return SelectedTimeCollectionHeaderView.reuseIdentifier
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

extension RothemRoomReservationViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    policyModel.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(TermsOfUseTableViewCell.self, for: indexPath) ?? TermsOfUseTableViewCell()
    cell.configureUI(with: policyModel[indexPath.row])
    cell.checkboxControl.rx.controlEvent(.touchUpInside)
      .compactMap { [weak tableView] in
        tableView?.indexPath(for: cell)
      }
      .bind(to: tapTermsOfUseCell)
      .disposed(by: disposeBag)
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 124 + 21 + 28
  }
}

extension RothemRoomReservationViewController: SkeletonTableViewDataSource {
  func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
    skeletonView.dequeueReusableCell(TermsOfUseTableViewCell.self, for: indexPath)
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
    TermsOfUseTableViewCell.reuseIdentifier
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
    2
  }
}

// MARK: - UIGestureRecognizerDelegate

extension RothemRoomReservationViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}

// MARK: - UITextFieldDelegate

extension RothemRoomReservationViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == nameTextField.textField {
      phoneNumberTextField.textField.becomeFirstResponder()
    } else if textField == phoneNumberTextField.textField {
      phoneNumberTextField.resignFirstResponder()
    }
    return true
  }
}

final class AutoSizingTableView: UITableView {
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded() // 현재 레이아웃을 업데이트
        return CGSize(width: contentSize.width, height: contentSize.height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }
}
