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
  
  private let mileageHeaderView = MileageHeaderView()
  
  private let spendListLabel = UILabel().then {
    $0.text = "소비내역"
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 14)
  }
  
  private lazy var mileageTableView = UITableView(frame: .zero, style: .plain).then {
    $0.register(MileageTableViewCell.self, forCellReuseIdentifier: MileageTableViewCell.identifier)
    $0.separatorStyle = .none
    $0.delegate = self
    $0.dataSource = self
    $0.backgroundColor = .systemBackground
    $0.showsVerticalScrollIndicator = false
    $0.sectionHeaderHeight = .leastNonzeroMagnitude
    $0.sectionFooterHeight = .leastNonzeroMagnitude
//    $0.isScrollEnabled = false
  }
  
  override func setupLayouts() {
    super.setupLayouts()
//    view.addSubview(scrollView)
//    scrollView.addSubview(scrollContainerView)
    [mileageHeaderView, spendListLabel, mileageTableView].forEach { view.addSubview($0) }
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
    
    mileageHeaderView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(69)
      $0.leading.equalToSuperview().inset(15)
    }
    
    spendListLabel.snp.makeConstraints {
      $0.top.equalTo(mileageHeaderView.snp.bottom).offset(96)
      $0.leading.equalToSuperview().inset(15)
    }
    
    mileageTableView.snp.makeConstraints {
      $0.top.equalTo(spendListLabel.snp.bottom).offset(14)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(UIScreen.main.bounds.height - 279)
      $0.bottom.equalToSuperview()
    }
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
}
