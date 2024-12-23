//
//  AffiliatedListViewController.swift
//  Haram
//
//  Created by 이건준 on 11/15/23.
//

import UIKit

import SnapKit
import SkeletonView
import Then

final class AffiliatedListViewController: BaseViewController {
  
  // MARK: - Property
  
  private let viewModel: AffiliatedListViewModel
  
  init(viewModel: AffiliatedListViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerNotifications()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeNotifications()
  }
  
  private lazy var affiliatedListView = UITableView(frame: .zero, style: .plain).then {
    $0.register(AffiliatedTableViewCell.self)
    $0.dataSource = self
    $0.delegate = self
    $0.backgroundColor = .white
    $0.separatorStyle = .singleLine
    $0.separatorColor = .hexD8D8DA
    $0.separatorInset = .zero
    $0.separatorInsetReference = .fromCellEdges
    $0.sectionFooterHeight = .leastNonzeroMagnitude
    $0.sectionHeaderHeight = .leastNonzeroMagnitude
    $0.showsVerticalScrollIndicator = false
    $0.alwaysBounceVertical = true
    $0.isSkeletonable = true
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    title = "제휴업체"
    setupBackButton()
    
    affiliatedListView.delegate = self
    affiliatedListView.dataSource = self
    
    setupSkeletonView()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(affiliatedListView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    affiliatedListView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    let input = AffiliatedListViewModel.Input(
      viewDidLoad: .just(()),
      didTapBackButton: navigationItem.leftBarButtonItem!.rx.tap.asObservable(), 
      didTapAffiliatedCell: affiliatedListView.rx.itemSelected.asObservable()
    )
    let output = viewModel.transform(input: input)
    output.reloadData
      .subscribe(with: self) { owner, _ in
        owner.view.hideSkeleton()
        owner.affiliatedListView.reloadData()
      }
      .disposed(by: disposeBag)

    output.errorMessage
      .subscribe(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(on: self.navigationController, message: .custom("네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요."), confirmHandler:  {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
            self.navigationController?.popViewController(animated: true)
          })

        }
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - UITableViewDelegate, SkeletonTableViewDataSource

extension AffiliatedListViewController: UITableViewDelegate, SkeletonTableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.affiliatedModel.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(AffiliatedTableViewCell.self, for: indexPath) ?? AffiliatedTableViewCell()
    cell.configureUI(with: viewModel.affiliatedModel[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 15 + 15 + 100
  }
  
  func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    cell.animateView(alpha: 0.5, scale: 0.9, duration: 0.1, completion: {})
  }
  
  func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    cell.animateView(alpha: 1, scale: 1, duration: 0.1, completion: {})
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
    AffiliatedTableViewCell.reuseIdentifier
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
    return skeletonView.dequeueReusableCell(AffiliatedTableViewCell.self, for: indexPath)
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
    10
  }
}

extension AffiliatedListViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}

extension AffiliatedListViewController {
  private func registerNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(refreshWhenNetworkConnected), name: .refreshWhenNetworkConnected, object: nil)
  }
  
  private func removeNotifications() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  private func refreshWhenNetworkConnected() {
//    viewModel.tryInquireAffiliated()
  }
}
