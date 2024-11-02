//
//  NewAccountViewController.swift
//  Haram
//
//  Created by 이건준 on 11/1/24.
//

import UIKit

import RxSwift

final class NewAccountViewController: ViewController {
  let viewModel: NewAccountViewModel
  let viewHolder: NewAccountViewHolder = NewAccountViewHolder()
  
  init(viewModel: NewAccountViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    viewHolderConfigure()
    navigationController?.navigationBar.isHidden = true
  }
  
  override func bind() {
    super.bind()
    viewHolder.schoolEmailButton.rx.tap
      .subscribe(with: self) { owner, _ in
        let vc = VerifyEmailViewController()
        vc.navigationItem.largeTitleDisplayMode = .never
        owner.navigationController?.pushViewController(vc, animated: true)
      }
      .disposed(by: disposeBag)
    
    viewHolder.intranetAccountButton.rx.tap
      .subscribe(with: self) { owner, _ in
        
      }
      .disposed(by: disposeBag)
    
    viewHolder.backButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.navigationController?.popViewController(animated: true)
      }
      .disposed(by: disposeBag)
  }
}

