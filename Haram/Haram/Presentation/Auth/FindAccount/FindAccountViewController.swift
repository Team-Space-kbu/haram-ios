//
//  FindAccountViewController.swift
//  Haram
//
//  Created by 이건준 on 11/1/24.
//

import UIKit

import RxSwift

final class FindAccountViewController: ViewController {
  let viewModel: FindAccountViewModel
  let viewHolder: FindAccountViewHolder = FindAccountViewHolder()
  
  init(viewModel: FindAccountViewModel) {
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
    let input = FindAccountViewModel.Input(
      didTapFindIDButton: viewHolder.findIDButton.rx.tap.asObservable(),
      didTapFindPasswordButton: viewHolder.findPWDButton.rx.tap.asObservable(),
      didTapBackButton: viewHolder.backButton.rx.tap.asObservable()
    )
    _ = viewModel.transform(input: input)
    
//    viewHolder.findIDButton.rx.tap
//      .subscribe(with: self) { owner, _ in
//        let vc = FindIDViewController(
//          viewModel: FindPasswordViewModel(
//            payload: .init(),
//            dependency: .init(authRepository: AuthRepositoryImpl())
//          )
//        )
//        vc.navigationItem.largeTitleDisplayMode = .never
//        owner.navigationController?.pushViewController(vc, animated: true)
//      }
//      .disposed(by: disposeBag)
//    
//    viewHolder.findPWDButton.rx.tap
//      .subscribe(with: self) { owner, _ in
//        let vc = FindPasswordViewController(
//          viewModel: FindPasswordViewModel(
//            payload: .init(),
//            dependency: .init(authRepository: AuthRepositoryImpl())
//          )
//        )
//        vc.navigationItem.largeTitleDisplayMode = .never
//        owner.navigationController?.pushViewController(vc, animated: true)
//      }
//      .disposed(by: disposeBag)
//    
//    viewHolder.backButton.rx.tap
//      .subscribe(with: self) { owner, _ in
//        owner.dismiss(animated: true)
//      }
//      .disposed(by: disposeBag)
  }
}
