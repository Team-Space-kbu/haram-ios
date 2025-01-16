//
//  TermsOfUseViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/07/23.
//

import UIKit

import RxCocoa
import SkeletonView
import SnapKit
import Then

final class TermsOfUseViewController: BaseViewController {
  
  private let viewModel: TermsOfUseViewModel
  private let tapTermsOfUseCell = PublishRelay<IndexPath>()
  
  private let titleLabel = UILabel().then {
    $0.text = "이용약관📄"
    $0.textColor = .black
    $0.font = .bold24
    $0.isSkeletonable = true
  }
  
  private lazy var termsOfUseTableView = UITableView(frame: .zero, style: .plain).then {
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
  
  private let scrollView = UIScrollView().then {
    $0.contentInsetAdjustmentBehavior = .never
    $0.alwaysBounceVertical = true
    $0.backgroundColor = .clear
    $0.showsVerticalScrollIndicator = false
    $0.isSkeletonable = true
  }
  
  private let containerView = UIView().then {
    $0.backgroundColor = .clear
    $0.isSkeletonable = true
  }
  
  private let horizontalStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 17
    $0.distribution = .fillEqually
    $0.backgroundColor = .clear
    $0.isSkeletonable = true
  }
  
  private let cancelButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramCancelButton(label: "취소", contentInsets: .zero)
  }
  
  private let applyButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "확인", contentInsets: .zero)
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = 10
  }
  
  private lazy var checkAllButton = CheckBoxControl(type: .none, title: "아래 약관에 모두 동의합니다.").then {
    $0.isSkeletonable = true
  }
  
  init(viewModel: TermsOfUseViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerNotifications()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeNotifications()
  }
  
  override func setupStyles() {
    super.setupStyles()
    setupSkeletonView()
  }
  
  override func bind() {
    super.bind()
    let input = TermsOfUseViewModel.Input(
      viewDidLoad: .just(()),
      didTapCancelButton: cancelButton.rx.tap.asObservable(),
      didTapContinueButton: applyButton.rx.tap.asObservable(),
      didTapCheckBox: tapTermsOfUseCell.asObservable(),
      didTapAllCheckButton: checkAllButton.rx.controlEvent(.touchUpInside).asObservable()
    )
    let output = viewModel.transform(input: input)
    output.termsOfModel
      .filter { !$0.isEmpty }
      .subscribe(with: self) { owner, termModel in
        owner.termsOfUseTableView.snp.updateConstraints {
          $0.height.equalTo(termModel.count * (124 + 28 + 21))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          owner.view.hideSkeleton()
        }
        owner.termsOfUseTableView.reloadData()
      }
      .disposed(by: disposeBag)
    
    output.isCheckedAllCheckButton
      .bind(to: checkAllButton.rx.isChecked)
      .disposed(by: disposeBag)
    
    output.isEnabledContinueButton
      .bind(to: applyButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    output.errorMessage
      .subscribe(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(on: owner.navigationController, message: .custom("네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요."), confirmHandler:  {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          })
        }
      }
      .disposed(by: disposeBag)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    [cancelButton, applyButton].forEach { horizontalStackView.addArrangedSubview($0) }
    _ = [titleLabel, checkAllButton, termsOfUseTableView, horizontalStackView].map { containerView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.directionalVerticalEdges.width.equalToSuperview()
      $0.height.greaterThanOrEqualToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(30 + Device.topInset)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(30)
    }
    
    checkAllButton.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(21 - 5)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(18)
    }
    
    termsOfUseTableView.snp.makeConstraints {
      $0.top.equalTo(checkAllButton.snp.bottom).offset(21)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(2 * ((124 + 28 + 21)))
    }
    
    horizontalStackView.snp.makeConstraints {
      $0.top.greaterThanOrEqualTo(termsOfUseTableView.snp.bottom).offset(17)
      $0.height.equalTo(48)
      $0.bottom.equalToSuperview().inset(Device.isNotch ? 24 : 12)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
    }
    
  }
}

extension TermsOfUseViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.output.termsOfModel.value.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(TermsOfUseTableViewCell.self, for: indexPath) ?? TermsOfUseTableViewCell()
    cell.configureUI(with: viewModel.output.termsOfModel.value[indexPath.row])
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

extension TermsOfUseViewController: SkeletonTableViewDataSource {
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

extension TermsOfUseViewController {
  private func registerNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(refreshWhenNetworkConnected), name: .refreshWhenNetworkConnected, object: nil)
  }
  
  private func removeNotifications() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  private func refreshWhenNetworkConnected() {
//    viewModel.inquireTermsSignUp()
  }
}
