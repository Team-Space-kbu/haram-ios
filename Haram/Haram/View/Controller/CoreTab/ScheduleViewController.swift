//
//  ScheduleViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import Elliotable
import SnapKit
import Then

enum ScheduleDay: CaseIterable {
  case mon
  case tue
  case wed
  case thr
  case fri
  
  var text: String {
    switch self {
    case .mon:
      return "월"
    case .tue:
      return "화"
    case .wed:
      return "수"
    case .thr:
      return "목"
    case .fri:
      return "금"
    }
  }
  
  var elliotDay: ElliotDay {
    switch self {
    case .mon:
      return .monday
    case .tue:
      return .tuesday
    case .wed:
      return .wednesday
    case .thr:
      return .thursday
    case .fri:
      return .friday
    }
  }
}

final class ScheduleViewController: BaseViewController {
  
  private let viewModel: ScheduleViewModelType
  
  private var courseModel: [ElliottEvent] = [] {
    didSet {
      elliotable.reloadData()
    }
  }
  
  private lazy var elliotable = Elliotable().then {
    $0.delegate = self
    $0.dataSource = self
    $0.roundCorner = .none
    $0.isFullBorder = true
    $0.courseTextAlignment = .left
    $0.courseItemTextSize = 13
    $0.roomNameFontSize = 8
    $0.textEdgeInsets = UIEdgeInsets(top: 2, left: 3, bottom: 2, right: 10)
  }
  
  init(viewModel: ScheduleViewModelType = ScheduleViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if UserManager.shared.hasIntranetToken {
      viewModel.inquireSchedule.onNext(())
    } else {
      let vc = IntranetLoginViewController()
      vc.modalPresentationStyle = .overFullScreen
      present(vc, animated: true)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
//    self.tabBarController?.delegate = self
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(elliotable)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    elliotable.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    viewModel.scheduleInfo
      .drive(rx.courseModel)
      .disposed(by: disposeBag)
  }
}

extension ScheduleViewController: ElliotableDelegate, ElliotableDataSource {
  func elliotable(elliotable: Elliotable, didSelectCourse selectedCourse: ElliottEvent) {
    
  }
  
  func elliotable(elliotable: Elliotable, didLongSelectCourse longSelectedCourse: ElliottEvent) {
    
  }
  
  func elliotable(elliotable: Elliotable, at dayPerIndex: Int) -> String {
    return ScheduleDay.allCases[dayPerIndex].text
  }
  
  func numberOfDays(in elliotable: Elliotable) -> Int {
    return ScheduleDay.allCases.count
  }
  
  func courseItems(in elliotable: Elliotable) -> [ElliottEvent] {
    return courseModel
  }
}

//extension ScheduleViewController: UITabBarControllerDelegate {
//  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//    print("시발1")
//    if viewController == self {
//      print("시발")
//      guard !UserManager.shared.hasIntranetToken else { return }
//      let vc = IntranetLoginViewController()
//      vc.navigationItem.largeTitleDisplayMode = .never
//      navigationController?.pushViewController(vc, animated: true)
//    }
//  }
//}
