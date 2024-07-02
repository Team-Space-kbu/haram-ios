//
//  IntranetCheckViewController.swift
//  Haram
//
//  Created by 이건준 on 11/13/23.
//

import UIKit

import SnapKit
import Then
import RxSwift

final class IntranetCheckViewController: BaseViewController {
  private let backgroudImageView = BackgroundImageView()
  
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
  
  private let lastButton = UIButton(configuration: .haramLabelButton(title: "나중에"))
  
  private let loginButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "로그인하기", contentInsets: .zero)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: false)
    let startIdx = navigationController?.viewControllers.startIndex
    navigationController?.viewControllers.remove(at: startIdx! + 1)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarHidden(false, animated: false)
  }
  
  override func setupStyles() {
    super.setupStyles()
    navigationController?.interactivePopGestureRecognizer?.delegate = self
  }

  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(backgroudImageView)
    _ = [titleLabel, subLabel, lastButton, loginButton].map { backgroudImageView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    backgroudImageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    loginButton.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(47)
      $0.trailing.equalToSuperview().inset(46)
      $0.height.equalTo(39)
      $0.width.equalTo(95)
    }
    
    lastButton.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(66)
      $0.centerY.equalTo(loginButton)
      $0.height.equalTo(39)
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
    
    lastButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.navigationController?.setNavigationBarHidden(false, animated: true)
        owner.navigationController?.popToRootViewController(animated: true)
      }
      .disposed(by: disposeBag)
    
    loginButton.rx.tap
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .subscribe(with: self) { owner, _ in
        let vc = IntranetLoginViewController(viewModel: IntranetLoginViewModel(type: .noShortcut))
        vc.hidesBottomBarWhenPushed = true
        vc.navigationItem.largeTitleDisplayMode = .never
        owner.navigationController?.pushViewController(vc, animated: true)
      }
      .disposed(by: disposeBag)
  }
}

extension IntranetCheckViewController {
  final private class BackgroundImageView: UIView {
    private let mainImageView = UIImageView().then {
      $0.image = UIImage(resource: .intranetMain)
      $0.contentMode = .scaleAspectFill
    }
    
    private let leftSubImageView = UIImageView().then {
      $0.image = UIImage(resource: .intranetSubLeft)
      $0.contentMode = .scaleAspectFill
    }
    
    private let rightSubImageView = UIImageView().then {
      $0.image = UIImage(resource: .intranetSubRight)
      $0.contentMode = .scaleAspectFill
    }
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      configureUI()
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
      _ = [mainImageView, leftSubImageView, rightSubImageView].map { addSubview($0) }
      mainImageView.snp.makeConstraints {
        $0.top.equalToSuperview().inset(166)
        $0.size.equalTo(260)
        $0.centerX.equalToSuperview()
      }
      
      rightSubImageView.snp.makeConstraints {
        $0.centerY.equalTo(mainImageView.snp.top)
        $0.trailing.equalToSuperview()
      }
      
      leftSubImageView.snp.makeConstraints {
        $0.leading.equalToSuperview()
        $0.centerY.equalTo(mainImageView.snp.bottom).offset(50)
      }
    }
  }
}
extension IntranetCheckViewController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true // or false
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}
