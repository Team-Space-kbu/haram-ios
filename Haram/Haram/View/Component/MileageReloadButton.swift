//
//  MileageReloadButton.swift
//  Haram
//
//  Created by 이건준 on 2023/07/23.
//

import UIKit

import RxSwift
import SnapKit
import Then

final class MileageReloadButton: UIView {
  
  private let disposeBag = DisposeBag()
  
  var isLoading: Bool = false {
    didSet {
      reloadLabel.textColor = isLoading ? .hex4B81EE : .hex707070
      reloadImageView.image = isLoading ? UIImage(named: "reloadBlue") : UIImage(named: "reloadGray")
    }
  }
  
  private let reloadLabel = UILabel().then {
    $0.text = "새로고침"
    $0.font = .regular
    $0.font = .systemFont(ofSize: 20)
    $0.textColor = .hex707070
  }
  
  private let reloadImageView = UIImageView().then {
    $0.image = UIImage(named: "reloadGray")
    $0.contentMode = .scaleAspectFill
  }
  
  let button = UIButton()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func bind() {
    button.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.isLoading.toggle()
      }
      .disposed(by: disposeBag)
  }
  
  private func configureUI() {
    
    [reloadLabel, reloadImageView, button].forEach { addSubview($0) }
    
    reloadLabel.snp.makeConstraints {
      $0.leading.directionalVerticalEdges.equalToSuperview()
    }
    
    reloadImageView.snp.makeConstraints {
      $0.size.equalTo(16)
      $0.leading.equalTo(reloadLabel.snp.trailing)
      $0.directionalVerticalEdges.trailing.equalToSuperview()
    }
    
    button.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
}
