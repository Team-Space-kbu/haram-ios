//
//  IntranetLoginViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/06/06.
//

import UIKit

import RxSwift
import SnapKit
import Then

final class IntranetLoginViewController: BaseViewController {
  private let containerStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 10
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 40, left: 20, bottom: .zero, right: 20)
  }
  
  private let logoImageView = UIImageView().then {
    $0.image = UIImage(named: "intranetLoginLogo")
    $0.contentMode = .scaleAspectFit
  }
  
  private let loginLabel = UILabel().then {
    $0.text = "로그인"
    $0.font = .regular
    $0.font = .systemFont(ofSize: 24)
  }
  
  private let intranetLabel = UILabel().then {
    $0.text = "한국성서대학교인트라넷"
    $0.font = .regular
    $0.font = .systemFont(ofSize: 14)
  }
  
  private let idTextField = UITextField().then {
    $0.placeholder = "아이디"
    $0.backgroundColor = .hexF5F5F5
    $0.tintColor = .black
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.hexD0D0D0.cgColor
    $0.leftView = UIView(frame: .init(x: .zero, y: .zero, width: 20, height: 55))
    $0.leftViewMode = .always
  }
  
  private let pwTextField = UITextField().then {
    $0.placeholder = "비밀번호"
    $0.backgroundColor = .hexF5F5F5
    $0.tintColor = .black
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.hexD0D0D0.cgColor
    $0.leftView = UIView(frame: .init(x: .zero, y: .zero, width: 20, height: 55))
    $0.leftViewMode = .always
  }
  
  private let loginButton = UIButton().then {
    $0.backgroundColor = .hex79BD9A
    $0.tintColor = .white
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.setTitle("로그인", for: .normal)
  }
  
  private let lastAuthButton = UIButton().then {
    $0.setTitle("나중에인증하기", for: .normal)
    $0.setTitleColor(.label, for: .normal)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
    navigationController?.navigationBar.isHidden = false
  }
  
  override func setupStyles() {
    super.setupStyles()
    navigationController?.navigationBar.isHidden = true
//    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(didTappedBackButton))
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(containerStackView)
    view.addSubview(lastAuthButton)
    [logoImageView, loginLabel, intranetLabel, idTextField, pwTextField, loginButton].forEach { containerStackView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    containerStackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    logoImageView.snp.makeConstraints {
      $0.width.equalTo(238)
      $0.height.equalTo(248)
    }
    
    [idTextField, pwTextField].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(55)
      }
    }
    
    loginButton.snp.makeConstraints {
      $0.height.equalTo(48)
    }
    
    lastAuthButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
    }
    
    containerStackView.setCustomSpacing(28, after: intranetLabel)
  }
  
  override func bind() {
    super.bind()
    
    AuthService.shared.requestIntranetToken()
      .subscribe(onNext: { response in
        UserManager.shared.set(
          intranetToken: response.intranetToken,
          xsrfToken: response.xsrfToken,
          laravelSession: response.laravelSession
        )
        print("토큰 \(UserManager.shared.hasIntranetToken)")
      })
      .disposed(by: disposeBag)
    
    loginButton.rx.tap
      .subscribe(with: self) { owner, _ in
        AuthService.shared.loginIntranet(
          request: .init(
            intranetToken: UserManager.shared.intranetToken!,
            intranetID: "kilee124",
            intranetPWD: "dlrjswns135"
          )
        )
        .subscribe(with: self) { owner, response in
          print("인트라넷 로그인 성공 !! \(response)")
//          owner.dismiss(animated: true)
          owner.navigationController?.popViewController(animated: true)
        }
        .disposed(by: owner.disposeBag)
      }
      .disposed(by: disposeBag)
    
    lastAuthButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.navigationController?.popViewController(animated: true)
      }
      .disposed(by: disposeBag)
  }
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}
