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
  
//  private let scrollView = UIScrollView().then {
//    $0.backgroundColor = .clear
//    $0.showsVerticalScrollIndicator = false
//    $0.showsHorizontalScrollIndicator = false
//    $0.isScrollEnabled = true
//  }
//
//  private let scrollContainerView = UIView().then {
//    $0.backgroundColor = .clear
//  }
  
//  private let mileageHeaderView = MileageHeaderView().then {
//    $0.backgroundColor = .red
//  }
//
//  private let spendListLabel = UILabel().then {
//    $0.text = "소비내역"
//    $0.textColor = .black
//    $0.font = .systemFont(ofSize: 14)
//  }
  
  private lazy var mileageTableView = UITableView(frame: .zero, style: .grouped).then {
    $0.register(MileageTableViewCell.self, forCellReuseIdentifier: MileageTableViewCell.identifier)
    $0.register(MileageTableHeaderView.self, forHeaderFooterViewReuseIdentifier: MileageTableHeaderView.identifier)
    $0.separatorStyle = .none
    $0.delegate = self
    $0.dataSource = self
    $0.backgroundColor = .systemBackground
    $0.showsVerticalScrollIndicator = false
    $0.sectionHeaderHeight = 279.97 - 10
    $0.sectionFooterHeight = .leastNonzeroMagnitude
//    $0.isScrollEnabled = false
  }
  
  override func setupStyles() {
    super.setupStyles()
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "back"),
      style: .done,
      target: self,
      action: #selector(didTappedBackButton)
    )
  }
  
  override func setupLayouts() {
    super.setupLayouts()
//    view.addSubview(scrollView)
//    scrollView.addSubview(scrollContainerView)
    view.addSubview(mileageTableView)
//    [mileageHeaderView, spendListLabel, mileageTableView].forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
//    scrollView.snp.makeConstraints {
//      $0.directionalEdges.equalToSuperview()
//    }
//    
//    scrollContainerView.snp.makeConstraints {
//      $0.width.directionalVerticalEdges.equalToSuperview()
//    }
    
//    mileageHeaderView.snp.makeConstraints {
//      $0.top.equalTo(view.safeAreaLayoutGuide).offset(69)
//      $0.leading.equalToSuperview().inset(15)
//    }
//
//    spendListLabel.snp.makeConstraints {
//      $0.top.equalTo(mileageHeaderView.snp.bottom).offset(96)
//      $0.leading.equalToSuperview().inset(15)
//    }
    
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
    return 10
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: MileageTableViewCell.identifier, for: indexPath) as? MileageTableViewCell ?? MileageTableViewCell()
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
    return header
  }
}
