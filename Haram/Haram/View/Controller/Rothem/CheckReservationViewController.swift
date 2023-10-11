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
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
}
