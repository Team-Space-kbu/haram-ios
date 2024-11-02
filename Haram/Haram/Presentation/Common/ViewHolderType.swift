//
//  ViewHolderType.swift
//  Haram
//
//  Created by 이건준 on 10/7/24.
//

import UIKit

protocol ViewHolderType {
    func place(in view: UIView)
    func configureConstraints(for view: UIView)
}
