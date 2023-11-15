//
//  MileageViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/05.
//

import UIKit

import SnapKit
import Then

final class MileageViewController: BaseViewController {
  
  private let viewModel: MileageViewModelType
  
  private var mileagePayInfoModel: MileageTableHeaderViewModel = MileageTableHeaderViewModel(totalMileage: 0) {
    didSet {
      mileageTableView.reloadData()
    }
  }
  
  private var model: [MileageTableViewCellModel] = [] {
    didSet {
      mileageTableView.reloadData()
    }
  }
  
  private lazy var mileageTableView = UITableView(frame: .zero, style: .grouped).then {
    $0.register(MileageTableViewCell.self, forCellReuseIdentifier: MileageTableViewCell.identifier)
    $0.register(MileageTableHeaderView.self, forHeaderFooterViewReuseIdentifier: MileageTableHeaderView.identifier)
    $0.separatorStyle = .none
    $0.delegate = self
    $0.dataSource = self
    $0.backgroundColor = .white
    $0.showsVerticalScrollIndicator = false
    $0.sectionHeaderHeight = 69.97 + 135 + 14 + 17 + 44
    $0.sectionFooterHeight = .leastNonzeroMagnitude
  }
  
  init(viewModel: MileageViewModelType = MileageViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    
    viewModel.currentUserMileageInfo
      .drive(rx.model)
      .disposed(by: disposeBag)
    
    viewModel.currentAvailabilityPoint
      .drive(rx.mileagePayInfoModel)
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "마일리지"
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: Constants.backButton),
      style: .done,
      target: self,
      action: #selector(didTappedBackButton)
    )
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(mileageTableView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    mileageTableView.snp.makeConstraints {
      $0.directionalVerticalEdges.equalToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
    }
  }
  
  @objc private func didTappedBackButton() {
    self.navigationController?.popViewController(animated: true)
  }
}

extension MileageViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return model.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: MileageTableViewCell.identifier, for: indexPath) as? MileageTableViewCell ?? MileageTableViewCell()
    cell.configureUI(with: model[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 64
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: MileageTableHeaderView.identifier) as? MileageTableHeaderView ?? MileageTableHeaderView()
    header.configureUI(with: mileagePayInfoModel)
    return header
  }
}
