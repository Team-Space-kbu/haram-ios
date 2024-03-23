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
  private var termsOfWebModel: [TermsWebTableViewCellModel] = []
  
  private let titleLabel = UILabel().then {
    $0.text = "이용약관📄"
    $0.textColor = .black
    $0.font = .bold24
    $0.isSkeletonable = true
  }
  
  private lazy var termsOfUseTableView = UITableView(frame: .zero, style: .plain).then {
    $0.register(TermsOfUseTableViewCell.self, forCellReuseIdentifier: TermsOfUseTableViewCell.identifier)
    $0.register(TermsWebTableViewCell.self, forCellReuseIdentifier: TermsWebTableViewCell.identifier)
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
    $0.alwaysBounceVertical = true
    $0.backgroundColor = .clear
    $0.isSkeletonable = true
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 30, left: 15, bottom: .zero, right: 15)
    $0.backgroundColor = .clear
    $0.spacing = 21
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
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = 10
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
  
  override func setupStyles() {
    super.setupStyles()
    navigationController?.navigationBar.isHidden = true
    setupSkeletonView()
  }
  
  override func bind() {
    super.bind()
    
    viewModel.inquireTermsSignUp()
    
    
    Signal.combineLatest(
      viewModel.termsOfModel,
      viewModel.termsOfWebModel
    )
    .emit(with: self) { owner, result in
      let (termModel, webModel) = result
      owner.termsOfModel = termModel
      owner.termsOfWebModel = webModel
      
      owner.termsOfUseTableView.snp.updateConstraints {
        $0.height.equalTo(termModel.count * (124 + 28 + 21))
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        owner.view.hideSkeleton()
      }
      owner.termsOfUseTableView.reloadData()
    }
    .disposed(by: disposeBag)
    
//    viewModel.termsOfModel
//      .emit(with: self) { owner, model in
//        owner.termsOfModel = model
//        owner.termsOfUseTableView.snp.updateConstraints {
//          $0.height.equalTo(model.count * (124 + 28 + 21))
//        }
//        owner.termsOfUseTableView.reloadData()
//      }
//      .disposed(by: disposeBag)
    
//    viewModel.termsOfWebModel
//      .emit(with: self) { owner, model in
//        owner.termsOfWebModel = model
//        
//        owner.termsOfUseTableView.reloadData()
//      }
//      .disposed(by: disposeBag)
    
    applyButton.rx.tap
      .subscribe(with: self) { owner, _ in
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
    
  }
  
  override func setupLayouts() {
    super.setupLayouts()
//    view.addSubview(termsOfUseTableView)
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    scrollView.addSubview(horizontalStackView)
    _ = [titleLabel, checkAllButton, termsOfUseTableView].map { containerView.addArrangedSubview($0) }
    [cancelButton, applyButton].forEach { horizontalStackView.addArrangedSubview($0) }
//    [titleLabel, checkAllButton, horizontalStackView].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.top.width.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    horizontalStackView.snp.makeConstraints {
      $0.top.greaterThanOrEqualTo(containerView.snp.bottom)
      $0.height.equalTo(48)
      $0.directionalHorizontalEdges.width.equalToSuperview().inset(15)
      $0.bottom.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.height.equalTo(30)
    }
    
    checkAllButton.snp.makeConstraints {
      $0.height.equalTo(18 + 10)
    }
    
    termsOfUseTableView.snp.makeConstraints {
      $0.height.equalTo(2 * ((124 + 28 + 21)))
//      $0.top.equalToSuperview().inset(30)
//      $0.directionalHorizontalEdges.bottom.equalToSuperview().inset(15)
    }
    
//    horizontalStackView.snp.makeConstraints {
//      $0.height.equalTo(48)
//    }
//    
//    checkAllButton.snp.makeConstraints {
//      $0.height.equalTo(18 + 10)
//    }
    
//    [checkButton, checkButton1].forEach {
//      $0.snp.makeConstraints {
//        $0.height.greaterThanOrEqualTo(18 + 10)
//      }
//    }
    
//    containerView.setCustomSpacing(23, after: titleLabel)
//    containerView.setCustomSpacing(35, after: checkAllButton)
  }
}

extension TermsOfUseViewController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    termsOfModel.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row % 2 == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: TermsOfUseTableViewCell.identifier, for: indexPath) as? TermsOfUseTableViewCell ?? TermsOfUseTableViewCell()
      cell.configureUI(with: termsOfModel[indexPath.section])
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: TermsWebTableViewCell.identifier, for: indexPath) as? TermsWebTableViewCell ?? TermsWebTableViewCell()
      cell.configureUI(with: termsOfWebModel[indexPath.section])
//      cell.delegate = self
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.row % 2 == 0 {
      return 28
    } else {
      return 124 + 21
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if indexPath.row == 0 {
      viewModel.checkedTermsSignUp(seq: termsOfModel[indexPath.section].seq, isChecked: !termsOfModel[indexPath.section].isChecked)
    }
  }
  
}

extension TermsOfUseViewController: SkeletonTableViewDataSource {
  func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
    if indexPath.row % 2 == 0 {
      let cell = skeletonView.dequeueReusableCell(withIdentifier: TermsOfUseTableViewCell.identifier, for: indexPath) as? TermsOfUseTableViewCell ?? TermsOfUseTableViewCell()
      return cell
    } else {
      let cell = skeletonView.dequeueReusableCell(withIdentifier: TermsWebTableViewCell.identifier, for: indexPath) as? TermsWebTableViewCell ?? TermsWebTableViewCell()
      return cell
    }
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
    if indexPath.row % 2 == 0 {
      return TermsOfUseTableViewCell.identifier
    } else {
      return TermsWebTableViewCell.identifier
    }
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
    2
  }
  
  func numSections(in collectionSkeletonView: UITableView) -> Int {
    2
  }
}
