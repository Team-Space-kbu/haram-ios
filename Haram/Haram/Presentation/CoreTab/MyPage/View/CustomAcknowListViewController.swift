//
//  CustomAcknowListViewController.swift
//  Haram
//
//  Created by 이건준 on 3/5/24.
//

import UIKit

import AcknowList
import SnapKit
import Then

final class CustomAcknowListViewController: AcknowListViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let acknowledgement = acknowledgements[indexPath.row] as Acknow?,
       let navigationController = navigationController {
        if acknowledgement.text != nil {
            let viewController = AcknowViewController(acknowledgement: acknowledgement)
          viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(resource: .back),
            style: .done,
            target: self,
            action: #selector(didTappedBackButton)
          )
            navigationController.pushViewController(viewController, animated: true)
        }
    }
  }
  
  @objc
  private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
}

extension CustomAcknowListViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}
