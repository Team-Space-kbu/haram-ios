//
//  MoreViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import AcknowList
import RxSwift
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
  case license
  case logout
  
  var title: String {
    switch self {
    case .provision:
      return "하람서비스약관"
    case .license:
      return "오픈소스라이센스"
    case .logout:
      return "로그아웃"
    }
  }
}

final class MoreViewController: BaseViewController {
  
  // MARK: - Property
  
  private let viewModel: MoreViewModelType
  
  // MARK: - UI Components
  
  private lazy var moreTableView = UITableView(frame: .zero, style: .plain).then {
    $0.delegate = self
    $0.dataSource = self
    $0.register(MoreTableViewCell.self, forCellReuseIdentifier: MoreTableViewCell.identifier)
    $0.backgroundColor = .white
    $0.sectionHeaderHeight = .leastNonzeroMagnitude
    $0.sectionFooterHeight = .leastNonzeroMagnitude
    $0.separatorStyle = .none
    $0.isScrollEnabled = false
  }
  
  private lazy var settingTableView = UITableView(frame: .zero, style: .plain).then {
    $0.delegate = self
    $0.dataSource = self
    $0.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
    $0.backgroundColor = .white
    $0.sectionHeaderHeight = .leastNonzeroMagnitude
    $0.sectionFooterHeight = .leastNonzeroMagnitude
    $0.separatorStyle = .none
    $0.isScrollEnabled = false
  }
  
  private let scrollView = UIScrollView().then {
    $0.alwaysBounceVertical = true
    $0.backgroundColor = .clear
    $0.showsVerticalScrollIndicator = false
  }
  
  private let contentView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  private let settingLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .bold22
    $0.text = "설정"
  }
  
  private let profileInfoView = ProfileInfoView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.hexD8D8DA.cgColor
    $0.backgroundColor = .hexF8F8F8
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .hexD8D8DA
  }
  
  // MARK: - Initializations
  
  init(viewModel: MoreViewModelType = MoreViewModel()) {
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
    //    navigationController?.navigationBar.isHidden = true
  }
  
  override func bind() {
    super.bind()
    
    viewModel.currentUserInfo
      .drive(with: self) { owner, profileInfoViewModel in
        owner.profileInfoView.configureUI(with: profileInfoViewModel)
      }
      .disposed(by: disposeBag)
    
    viewModel.successMessage
      .emit(with: self) { owner, message in
        guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else { return }
        
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
          window.rootViewController = LoginViewController()
        })
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
      $0.top.equalTo(profileInfoView.snp.bottom).offset(31.33)
      $0.leading.equalToSuperview().inset(18.01)
      $0.trailing.equalToSuperview().inset(28)
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
      $0.top.equalTo(settingLabel.snp.bottom).offset(17)
      $0.leading.equalToSuperview().inset(15)
      $0.trailing.equalToSuperview().inset(28)
      $0.height.equalTo(127 + 23 + 23)
      $0.bottom.equalToSuperview().inset(23)
    }
  }
  
  @objc
  private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
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
      let cell = tableView.dequeueReusableCell(withIdentifier: MoreTableViewCell.identifier, for: indexPath) as? MoreTableViewCell ?? MoreTableViewCell()
      cell.configureUI(with: .init(imageResource: MoreType.allCases[indexPath.row].imageResource, title: MoreType.allCases[indexPath.row].title))
      return cell
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath) as? SettingTableViewCell ?? SettingTableViewCell()
    cell.configureUI(with: .init(title: SettingType.allCases[indexPath.row].title))
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if tableView == moreTableView {
      return 23 + 24
    }
    return 23 + 13
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if tableView == settingTableView {
      let settingType = SettingType.allCases[indexPath.row]
      if settingType == .logout {
        viewModel.requestLogoutUser()
      } else if settingType == .license {
        let acknowList = CustomAcknowListViewController(fileNamed: Constants.openLicenseFileName)
        acknowList.hidesBottomBarWhenPushed = true
        acknowList.navigationItem.leftBarButtonItem = UIBarButtonItem(
          image: UIImage(resource: .back),
          style: .done,
          target: self,
          action: #selector(didTappedBackButton)
        )
        navigationController?.pushViewController(acknowList, animated: true)
      }
    } else {
      let moreType = MoreType.allCases[indexPath.row]
      let vc = SelectedCategoryNoticeViewController(noticeType: moreType == .employmentInformation ? .jobStudent : .jobChurch)
      vc.title = moreType.title
      vc.navigationItem.largeTitleDisplayMode = .never
      vc.hidesBottomBarWhenPushed = true
      navigationController?.pushViewController(vc, animated: true)
    }
  }
}
