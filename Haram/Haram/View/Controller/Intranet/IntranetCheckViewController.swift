//
//  IntranetCheckViewController.swift
//  Haram
//
//  Created by 이건준 on 11/13/23.
//

import UIKit

import SnapKit
import Then

final class IntranetCheckViewController: BaseViewController {
  private let backgroudImageView = BackgroundImageView()
  
  private let titleLabel = UILabel().then {
    $0.text = "인트라넷로그인"
    $0.font = .bold24
    $0.textColor = .black
  }
  
  private let subLabel = UILabel().then {
    $0.text = "한국성서대학교 인트라넷 로그인이 필요합니다.\n아이디와 패스워드는 성서몬에 저장하지 않으며\n핸드폰에 안전하게 암호화하여 저장합니다."
    $0.numberOfLines = 3
    $0.font = .regular14
    $0.textColor = .black
    $0.textAlignment = .center
  }
  
  private let lastButton = UIButton().then {
    let attributedString = NSAttributedString(
      string: "나중에",
      attributes: [
        .font: UIFont.regular14,
        .foregroundColor: UIColor.black
      ]
    )
    $0.setAttributedTitle(attributedString, for: .normal)
    $0.backgroundColor = .clear
  }
  
  private let loginButton = UIButton().then {
    let attributedString = NSAttributedString(
      string: "로그인하기",
      attributes: [
        .font: UIFont.bold13,
        .foregroundColor: UIColor.white
      ]
    )
    $0.setAttributedTitle(attributedString, for: .normal)
    $0.backgroundColor = .hex79BD9A
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
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
    
    titleLabel.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(243)
      $0.centerX.equalToSuperview()
    }
    
    subLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(7)
      $0.directionalHorizontalEdges.equalToSuperview().inset(60)
    }
    
    lastButton.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(66)
      $0.top.equalTo(subLabel.snp.bottom).offset(104)
    }
    
    loginButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(46)
      $0.centerY.equalTo(lastButton)
      $0.height.equalTo(39)
      $0.width.equalTo(95)
    }
  }
}

extension IntranetCheckViewController {
  final private class BackgroundImageView: UIView {
    private let mainImageView = UIImageView().then {
      $0.image = UIImage(named: "intranetMain")
      $0.contentMode = .scaleAspectFill
    }
    
    private let leftSubImageView = UIImageView().then {
      $0.image = UIImage(named: "intranetSubLeft")
      $0.contentMode = .scaleAspectFill
    }
    
    private let rightSubImageView = UIImageView().then {
      $0.image = UIImage(named: "intranetSubRight")
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
