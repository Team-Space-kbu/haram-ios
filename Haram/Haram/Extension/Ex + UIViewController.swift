//
//  Ex + UIViewController.swift
//  Haram
//
//  Created by 이건준 on 12/23/23.
//

import UIKit

@objc protocol BackButtonHandler: AnyObject {
    @objc func didTappedBackButton()
}

extension BackButtonHandler where Self: UIViewController {
    func setupBackButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: Constants.backButton),
            style: .plain,
            target: self,
            action: #selector(didTappedBackButton)
        )
    }
}
