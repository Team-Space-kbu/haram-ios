//
//  IntranetAlertViewController.swift
//  Haram
//
//  Created by 이건준 on 11/13/23.
//

import UIKit

import SnapKit
import Then
import RxSwift

final class IntranetAlertViewController: BaseViewController {
  private let viewModel: IntranetAlertViewModel
  
  private let backgroudImageView = UIImageView(image: UIImage(resource: .intranetCheck)).then {
    $0.contentMode = .scaleAspectFill
    $0.isUserInteractionEnabled = true
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "인트라넷 로그인"
    $0.font = .bold24
    $0.textColor = .black
  }
  
  private let subLabel = UILabel().then {
    $0.text = "한국성서대학교 인트라넷 로그인이 필요합니다.\n재학중인 학생임을 확인하는 절차로 학번을 조회합니다.\n인트라넷 로그인 정보는 어디에든 저장되지 않으며\n로그인 이후에는 더 이상 로그인하지 않습니다."
    $0.numberOfLines = 0
    $0.font = .regular14
    $0.textColor = .black
    $0.textAlignment = .center
  }
  
  private let buttonStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 17
    $0.distribution = .fillEqually
  }
  
  private let lastButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramCancelButton(label: "나중에", contentInsets: .zero)
  }
  
  private let loginButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "로그인하기", contentInsets: .zero)
  }
  
  init(viewModel: IntranetAlertViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
//  override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//    navigationController?.setNavigationBarHidden(true, animated: false)
//    let startIdx = navigationController?.viewControllers.startIndex
//    navigationController?.viewControllers.remove(at: startIdx! + 1)
//  }
//  
//  override func viewWillDisappear(_ animated: Bool) {
//    super.viewWillDisappear(animated)
//    navigationController?.setNavigationBarHidden(false, animated: false)
//  }
  
//  override func setupStyles() {
//    super.setupStyles()
//    navigationController?.interactivePopGestureRecognizer?.delegate = self
//  }

  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(backgroudImageView)
    [lastButton, loginButton].forEach { buttonStackView.addArrangedSubview($0) }
    _ = [titleLabel, subLabel, buttonStackView].map { backgroudImageView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    backgroudImageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    buttonStackView.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(Device.isNotch ? 24 : 12)
      $0.directionalHorizontalEdges.width.equalToSuperview().inset(15)
      $0.height.equalTo(48)
    }
    
    subLabel.snp.makeConstraints {
      $0.bottom.equalTo(loginButton.snp.top).offset(-50)
      $0.directionalHorizontalEdges.equalToSuperview().inset(16)
    }
    
    titleLabel.snp.makeConstraints {
      $0.bottom.equalTo(subLabel.snp.top).offset(-20)
      $0.top.greaterThanOrEqualToSuperview()
      $0.centerX.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    let input = IntranetAlertViewModel.Input(
      didTapCancelButton: lastButton.rx.tap.asObservable(),
      didTapConfirmButton: loginButton.rx.tap.asObservable()
    )
    _ = viewModel.transform(input: input)
    
//    lastButton.rx.tap
//      .subscribe(with: self) { owner, _ in
//        owner.navigationController?.setNavigationBarHidden(false, animated: true)
//        owner.navigationController?.popToRootViewController(animated: true)
//      }
//      .disposed(by: disposeBag)
//    
//    loginButton.rx.tap
//      .throttle(.seconds(1), scheduler: MainScheduler.instance)
//      .subscribe(with: self) { owner, _ in
//        let vc = IntranetLoginViewController(viewModel: IntranetLoginViewModel(dependency: .init(authRepository: AuthRepositoryImpl(), coordinator: IntranetLoginCoordinator(navigationController: self.navigationController!))))
//        vc.hidesBottomBarWhenPushed = true
//        vc.navigationItem.largeTitleDisplayMode = .never
//        owner.navigationController?.pushViewController(vc, animated: true)
//      }
//      .disposed(by: disposeBag)
  }
}

//extension IntranetAlertViewController: UIGestureRecognizerDelegate {
//  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//    return true // or false
//  }
//  
//  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
//    return true
//  }
//}
