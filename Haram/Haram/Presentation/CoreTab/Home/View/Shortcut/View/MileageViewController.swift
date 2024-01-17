//
//  MileageViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/05.
//

import UIKit

import SkeletonView
import SnapKit
import Then

final class MileageViewController: BaseViewController, BackButtonHandler {
  
  private let viewModel: MileageViewModelType
  
  private var mileagePayInfoModel: MileageTableHeaderViewModel? {
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
    $0.isSkeletonable = true
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
    
    viewModel.isLoading
      .filter { !$0 }
      .drive(with: self) { owner, isLoading in
        owner.view.hideSkeleton()
      }
      .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        guard error == .requiredStudentID else { return }
        let vc = IntranetCheckViewController()
        vc.navigationItem.largeTitleDisplayMode = .never
        owner.navigationController?.pushViewController(vc, animated: true)
      }
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "마일리지"
    setupBackButton()
    
    setupSkeletonView()
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
  
  @objc func didTappedBackButton() {
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
    header.configureUI(with: mileagePayInfoModel ?? MileageTableHeaderViewModel(totalMileage: 0))
    return header
  }
}

extension MileageViewController: SkeletonTableViewDelegate, SkeletonTableViewDataSource {
  func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
    let cell = skeletonView.dequeueReusableCell(withIdentifier: MileageTableViewCell.identifier, for: indexPath) as? MileageTableViewCell ?? MileageTableViewCell()
    cell.configureUI(with: .init(mainText: "2023 총장배소프트웨어경진대회 - 컴소", subText: "20231119", mileage: -1000, imageSource: .cafeCostes))
    return cell
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
    MileageTableViewCell.identifier
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, identifierForHeaderInSection section: Int) -> ReusableHeaderFooterIdentifier? {
    MileageTableHeaderView.identifier
  }
  
}
