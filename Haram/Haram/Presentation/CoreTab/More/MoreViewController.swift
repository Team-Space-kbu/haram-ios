//
//  MoreViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import AcknowList
import RxSwift
import SkeletonView
import SnapKit
import Then

enum MoreType: CaseIterable {
  case employmentInformation
  case churchRecruitmentNotice
  
  var title: String {
    switch self {
    case .employmentInformation:
      return "취업정보"
    case .churchRecruitmentNotice:
      return "교회(사역) 채용공고"
    }
  }
  
  var imageResource: ImageResource {
    switch self {
    case .employmentInformation:
      return .blueRocket
    case .churchRecruitmentNotice:
      return .yellowHeart
    }
  }
}

enum SettingType: CaseIterable {
  case provision
  case privacyInfo
  case license
  case customerService
  case logout
  
  var title: String {
    switch self {
    case .provision:
      return "하람서비스약관"
    case .privacyInfo:
      return "개인정보처리방침"
    case .license:
      return "오픈소스라이센스"
    case .customerService:
      return "고객센터 안내"
    case .logout:
      return "로그아웃"
    }
  }
  
  var url: URL? {
    switch self {
    case .provision:
      return URL(string: "https://team-spaces.notion.site/space-51257ec335724f90ad69ce20ae3e2393?pvs=4")
    case .privacyInfo:
      return URL(string: "https://team-spaces.notion.site/238de2ae5b7a4000a40492037ed35640?pvs=4")
    case .customerService:
      return URL(string: "https://team-spaces.notion.site/027b854625fe4d2f8b2938f63a2532f2?pvs=4")
    default:
      return nil
    }
  }
}

final class MoreViewController: BaseViewController {
  
  // MARK: - Property
  
  private let viewModel: MoreViewModel
  
  // MARK: - UI Components
  
  private lazy var moreTableView = UITableView(frame: .zero, style: .plain).then {
    $0.delegate = self
    $0.dataSource = self
    $0.register(MoreTableViewCell.self)
    $0.backgroundColor = .white
    $0.sectionHeaderHeight = .leastNonzeroMagnitude
    $0.sectionFooterHeight = .leastNonzeroMagnitude
    $0.separatorStyle = .none
    $0.isScrollEnabled = false
    $0.isSkeletonable = true
    $0.showsVerticalScrollIndicator = false
    $0.isScrollEnabled = false
  }
  
  private lazy var settingTableView = UITableView(frame: .zero, style: .plain).then {
    $0.delegate = self
    $0.dataSource = self
    $0.register(SettingTableViewCell.self)
    $0.backgroundColor = .white
    $0.sectionHeaderHeight = .leastNonzeroMagnitude
    $0.sectionFooterHeight = .leastNonzeroMagnitude
    $0.separatorStyle = .none
    $0.isSkeletonable = true
    $0.showsVerticalScrollIndicator = false
    $0.isScrollEnabled = false
  }
  
  private let scrollView = UIScrollView().then {
    $0.alwaysBounceVertical = true
    $0.backgroundColor = .clear
    $0.showsVerticalScrollIndicator = false
    $0.isSkeletonable = true
  }
  
  private let contentView = UIView().then {
    $0.backgroundColor = .clear
    $0.isSkeletonable = true
  }
  
  private let settingLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .bold22
    $0.text = "설정"
    $0.isSkeletonable = true
  }
  
  private let profileInfoView = ProfileInfoView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.hexD8D8DA.cgColor
    $0.backgroundColor = .hexF8F8F8
    $0.isSkeletonable = true
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .hexD8D8DA
    $0.isSkeletonable = true
  }
  
  // MARK: - Initializations
  
  init(viewModel: MoreViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
  override func setupStyles() {
    super.setupStyles()
    
    let label = UILabel().then {
      $0.text = "더보기"
      $0.textColor = .black
      $0.font = .bold26
    }
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
    setupSkeletonView()
  }
  
  override func bind() {
    super.bind()
    let input = MoreViewModel.Input(
      viewWillAppear: self.rx.methodInvoked(#selector(UIViewController.viewWillAppear)).map { _ in Void() },
      didTappedMenuCell: moreTableView.rx.itemSelected.asObservable(),
      didTappedSettingCell: settingTableView.rx.itemSelected.asObservable(),
      didTappedMoreButton: profileInfoView.button.rx.tap.asObservable()
    )
    bindNotificationCenter(input: input)
    
    let output = viewModel.transform(input: input)
    output.currentUserInfo
      .compactMap { $0 }
      .subscribe(with: self) { owner, profileInfoViewModel in
        owner.view.hideSkeleton()
        owner.profileInfoView.configureUI(with: profileInfoViewModel)
      }
      .disposed(by: disposeBag)
    
    output.errorMessage
      .subscribe(with: self) { owner, error in
        if error == .retryError || error == .networkError {
          AlertManager.showAlert(on: owner.navigationController, message: .custom("네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요."), confirmHandler:  {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          })
        }
      }
      .disposed(by: disposeBag)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    [profileInfoView, moreTableView, lineView, settingLabel, settingTableView].forEach { contentView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    contentView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    profileInfoView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(20)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(131)
    }
    
    moreTableView.snp.makeConstraints {
      $0.top.equalTo(profileInfoView.snp.bottom).offset(31.33 - 12)
      $0.leading.equalToSuperview().inset(15)
      $0.trailing.equalToSuperview().inset(15)
      $0.height.equalTo((23 + 24) * MoreType.allCases.count)
    }
    
    lineView.snp.makeConstraints {
      $0.top.equalTo(moreTableView.snp.bottom).offset(6)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15.5)
      $0.height.equalTo(1)
    }
    
    settingLabel.snp.makeConstraints {
      $0.top.equalTo(lineView.snp.bottom).offset(28)
      $0.leading.equalToSuperview().inset(15)
    }
    
    settingTableView.snp.makeConstraints {
      $0.top.equalTo(settingLabel.snp.bottom).offset(17 - 6.5)
      $0.leading.equalToSuperview().inset(15)
      $0.trailing.equalToSuperview().inset(15)
      $0.height.equalTo((23 + 13) * SettingType.allCases.count)
      $0.bottom.equalToSuperview().inset(13)
    }
  }
}

extension MoreViewController {
  private func bindNotificationCenter(input: MoreViewModel.Input) {
    NotificationCenter.default.rx.notification(.refreshWhenNetworkConnected)
      .map { _ in Void() }
      .bind(to: input.didConnectNetwork)
      .disposed(by: disposeBag)
  }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MoreViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == moreTableView {
      return MoreType.allCases.count
    }
    return SettingType.allCases.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if tableView == moreTableView {
      let cell = tableView.dequeueReusableCell(MoreTableViewCell.self, for: indexPath) ?? MoreTableViewCell()
      cell.configureUI(with: .init(imageResource: MoreType.allCases[indexPath.row].imageResource, title: MoreType.allCases[indexPath.row].title))
      return cell
    }
    let cell = tableView.dequeueReusableCell(SettingTableViewCell.self, for: indexPath) ?? SettingTableViewCell()
    cell.configureUI(with: .init(title: SettingType.allCases[indexPath.row].title))
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if tableView == moreTableView {
      return 23 + 24
    }
    return 23 + 13
  }
  
  func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
    if tableView == settingTableView {
      let cell = tableView.cellForRow(at: indexPath) as? SettingTableViewCell ?? SettingTableViewCell()
      cell.showAnimation(scale: 0.9, completion: {})
    } else {
      let cell = tableView.cellForRow(at: indexPath) as? MoreTableViewCell ?? MoreTableViewCell()
      cell.showAnimation(scale: 0.9, completion: {})
    }
  }
  
  func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
    
  }
}

extension MoreViewController: SkeletonTableViewDataSource {
  func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
    if skeletonView == moreTableView {
      return skeletonView.dequeueReusableCell(MoreTableViewCell.self, for: indexPath)
    } else if skeletonView == settingTableView {
      return skeletonView.dequeueReusableCell(SettingTableViewCell.self, for: indexPath)
    }
    return nil
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
    if skeletonView == moreTableView {
      return MoreTableViewCell.reuseIdentifier
    }
    return SettingTableViewCell.reuseIdentifier
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if skeletonView == moreTableView {
      return MoreType.allCases.count
    }
    return SettingType.allCases.count
  }
}
