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

enum Day: String, Decodable, CaseIterable {
  case MONDAY
  case TUESDAY
  case WEDNESDAY
  case THURSDAY
  case FRIDAY
  
  var text: String {
    switch self {
    case .MONDAY:
      return "월"
    case .TUESDAY:
      return "화"
    case .WEDNESDAY:
      return "수"
    case .THURSDAY:
      return "목"
    case .FRIDAY:
      return "금"
    }
  }
  
  var elliotDay: ElliotDay {
    switch self {
    case .MONDAY:
      return .monday
    case .TUESDAY:
      return .tuesday
    case .WEDNESDAY:
      return .wednesday
    case .THURSDAY:
      return .thursday
    case .FRIDAY:
      return .friday
    }
  }
}

final class ScheduleViewController: BaseViewController {
  
  private let viewModel: ScheduleViewModel
  
  private let elliotable = Elliotable().then {
    $0.roundCorner = .none
    $0.isFullBorder = true
    $0.courseTextAlignment = .left
    $0.courseItemTextSize = 13
    $0.roomNameFontSize = 8
    $0.textEdgeInsets = UIEdgeInsets(top: 2, left: 3, bottom: 2, right: 10)
  }
  
  private let indicatorView = UIActivityIndicatorView(style: .large)
  
  init(viewModel: ScheduleViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
//  override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//    registerNotifications()
//  }
//  
//  override func viewWillDisappear(_ animated: Bool) {
//    super.viewWillDisappear(animated)
//    removeNotifications()
//  }
  
  override func setupStyles() {
    super.setupStyles()
    
    /// Set Delegate & DataSource
    elliotable.delegate = self
    elliotable.dataSource = self
    
    /// Set Navigationbar
    title = "시간표"
    setupBackButton()
    indicatorView.startAnimating()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    _ = [elliotable, indicatorView].map { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    elliotable.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    indicatorView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    let input = ScheduleViewModel.Input(
      viewDidLoad: .just(()),
      didTapBackButton: navigationItem.leftBarButtonItem!.rx.tap.asObservable()
    )
    let output = viewModel.transform(input: input)
    output.schedulingInfo
      .subscribe(with: self) { owner, model in
        owner.elliotable.reloadData()
        owner.indicatorView.stopAnimating()
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
            owner.navigationController?.popViewController(animated: true)
          })
        }
      }
      .disposed(by: disposeBag)
  }
}

extension ScheduleViewController: ElliotableDelegate, ElliotableDataSource {
  
  func elliotable(elliotable: Elliotable, didSelectCourse selectedCourse: ElliottEvent) {
    
  }
  
  func elliotable(elliotable: Elliotable, didLongSelectCourse longSelectedCourse: ElliottEvent) {
    
  }
  
  func elliotable(elliotable: Elliotable, at dayPerIndex: Int) -> String {
    return Day.allCases[dayPerIndex].text
  }
  
  func numberOfDays(in elliotable: Elliotable) -> Int {
    return Day.allCases.count
  }
  
  func courseItems(in elliotable: Elliotable) -> [ElliottEvent] {
    return viewModel.courseModel
  }
}
