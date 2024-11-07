//
//  FindIDResultViewController.swift
//  Haram
//
//  Created by 이건준 on 11/6/24.
//

import UIKit

import RxSwift

final class FindIDResultViewController: BaseViewController {
  
  private let viewModel: FindIDResultViewModel
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 30, left: 15, bottom: .zero, right: 15)
    $0.spacing = 23
    $0.backgroundColor = .clear
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "아이디 찾기📩"
    $0.textColor = .black
    $0.font = .bold24
  }
  
  private let alertLabel = UILabel().then {
    $0.text = "아이디 정보를 찾았습니다😎\n아이디를 통해 로그인을 해보세요"
    $0.textColor = .hex545E6A
    $0.font = .regular14
    $0.numberOfLines = 0
  }
  
  private let myIDLabel = UILabel()
  
  private let buttonStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 17
    $0.distribution = .fillEqually
  }
  
  private let backButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "돌아가기", contentInsets: .zero)
  }
  
  init(viewModel: FindIDResultViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    navigationController?.navigationBar.isHidden = true
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [containerView, buttonStackView].forEach { view.addSubview($0) }
    buttonStackView.addArrangedSubview(backButton)
    [titleLabel, alertLabel, myIDLabel].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.height.equalTo(30)
    }
    
    alertLabel.snp.makeConstraints {
      $0.height.equalTo(38)
    }
    
    containerView.setCustomSpacing(7, after: titleLabel)
    
    buttonStackView.snp.makeConstraints {
      $0.top.greaterThanOrEqualTo(containerView.snp.bottom)
      $0.bottom.equalToSuperview().inset(Device.isNotch ? 24 : 12)
      $0.directionalHorizontalEdges.width.equalToSuperview().inset(15)
      $0.height.equalTo(48)
    }
    
    backButton.snp.makeConstraints {
      $0.height.equalTo(48)
    }
  }
  
  override func bind() {
    super.bind()
    let input = FindIDResultViewModel.Input(viewDidLoad: .just(()))
    let output = viewModel.transform(input: input)
    output.foundUserID
      .bind(to: myIDLabel.rx.text)
      .disposed(by: disposeBag)
//    viewModel.errorMessage
//      .emit(with: self) { owner, error in
//        if error == .networkError {
//          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요.", viewController: owner) {
//            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
//            if UIApplication.shared.canOpenURL(url) {
//              UIApplication.shared.open(url)
//            }
//          }
//          return
//        }
//        
//        if error == .notFindUserError {
//          AlertManager.showAlert(title: "Space 알림", message: "해당 이메일에 대한 사용자가 존재하지않습니다\n다른 이메일로 시도해주세요.", viewController: owner) {
//            owner.navigationController?.popViewController(animated: true)
//          }
//        }
//      }
//      .disposed(by: disposeBag)
    
    backButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.navigationController?.popViewController(animated: true)
      }
      .disposed(by: disposeBag)
    
//    viewModel.successSendAuthCode
//      .emit(with: self) { owner, _ in
//        AlertManager.showAlert(title: "인증번호발송 알림", message: "해당 메일로 인증코드를 보내는데 성공했습니다.", viewController: owner, confirmHandler: nil)
//      }
//      .disposed(by: disposeBag)
    
  }
}

