//
//  CheckReservationViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/18.
//

import UIKit

import SnapKit
import Then

final class CheckReservationViewController: BaseViewController {
  
  private let viewModel: CheckReservationViewModelType
  
  init(viewModel: CheckReservationViewModelType = CheckReservationViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "예약확인하기"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: Constants.backButton),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
  }
  
  override func bind() {
    super.bind()
    
  }
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
}
