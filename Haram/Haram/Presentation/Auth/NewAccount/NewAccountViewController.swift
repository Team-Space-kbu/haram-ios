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
    let input = NewAccountViewModel.Input(
      didTapSchoolAccountButton: viewHolder.schoolEmailButton.rx.tap.asObservable(),
      didTapIntranetAccountButton: viewHolder.intranetAccountButton.rx.tap.asObservable(),
      didTapBackButton: viewHolder.backButton.rx.tap.asObservable()
    )
    _ = viewModel.transform(input: input)
  }
}

