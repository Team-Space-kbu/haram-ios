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
  
  private let viewModel: TermsOfUseViewModelType
  
  private var termsOfModel: [TermsOfUseTableViewCellModel] = []
  
  private let titleLabel = UILabel().then {
    $0.text = "이용약관📄"
    $0.textColor = .black
    $0.font = .bold24
    $0.isSkeletonable = true
  }
  
  private lazy var termsOfUseTableView = UITableView(frame: .zero, style: .plain).then {
    $0.register(TermsOfUseTableViewCell.self, forCellReuseIdentifier: TermsOfUseTableViewCell.identifier)
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
//    $0.isSkeletonable = true
//    $0.skeletonCornerRadius = 10
  }
  
  private let applyButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "확인", contentInsets: .zero)
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = 10
  }
  
  private lazy var checkAllButton = CheckBoxControl(type: .none, title: "아래 약관에 모두 동의합니다.").then {
    $0.isSkeletonable = true
  }
  
  init(viewModel: TermsOfUseViewModelType = TermsOfUseViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    removeNotifications()
  }
  
  override func setupStyles() {
    super.setupStyles()
    navigationController?.navigationBar.isHidden = true
    setupSkeletonView()
    registerNotifications()
  }
  
  override func bind() {
    super.bind()
    
    viewModel.inquireTermsSignUp()
    
    viewModel.termsOfModel
      .emit(with: self) { owner, termModel in
        
        owner.termsOfModel = termModel
        
        
        owner.termsOfUseTableView.snp.updateConstraints {
          $0.height.equalTo(termModel.count * (124 + 28 + 21))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          owner.view.hideSkeleton()
        }
        owner.termsOfUseTableView.reloadData()
      }
      .disposed(by: disposeBag)
    
    applyButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.viewModel.saveTermsInfo()
        
        let vc = VerifyEmailViewController()
        vc.navigationItem.largeTitleDisplayMode = .never
        owner.navigationController?.pushViewController(vc, animated: true)
      }
      .disposed(by: disposeBag)
    
    cancelButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.dismiss(animated: true)
      }
      .disposed(by: disposeBag)
    
    viewModel.isContinueButtonEnabled
      .drive(applyButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    checkAllButton.rx.isChecked
      .subscribe(with: self) { owner, isChecked in
        owner.viewModel.checkedAllTermsSignUp(isChecked: isChecked)
      }
      .disposed(by: disposeBag)
    
    viewModel.isCheckallCheckButton
      .drive(checkAllButton.rx.isChecked)
      .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터 연결 후 다시 시도해주세요.", viewController: owner) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          }
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
      $0.height.equalTo(28)
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

extension TermsOfUseViewController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return termsOfModel.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: TermsOfUseTableViewCell.identifier, for: indexPath) as? TermsOfUseTableViewCell ?? TermsOfUseTableViewCell()
    cell.configureUI(with: termsOfModel[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 124 + 21 + 28
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    viewModel.checkedTermsSignUp(seq: termsOfModel[indexPath.row].seq, isChecked: !termsOfModel[indexPath.row].isChecked)
  }
  
}

extension TermsOfUseViewController: SkeletonTableViewDataSource {
  func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
    let cell = skeletonView.dequeueReusableCell(withIdentifier: TermsOfUseTableViewCell.identifier, for: indexPath) as? TermsOfUseTableViewCell ?? TermsOfUseTableViewCell()
    return cell
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
    return TermsOfUseTableViewCell.identifier
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
    2
  }
  
  func numSections(in collectionSkeletonView: UITableView) -> Int {
    1
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
    viewModel.inquireTermsSignUp()
  }
}
