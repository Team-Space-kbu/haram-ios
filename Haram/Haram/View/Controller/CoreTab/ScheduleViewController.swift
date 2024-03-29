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
  
  private let viewModel: ScheduleViewModelType
  
  private var courseModel: [ElliottEvent] = [] {
    didSet {
      elliotable.reloadData()
    }
  }
  
  private let elliotable = Elliotable().then {
    $0.roundCorner = .none
    $0.isFullBorder = true
    $0.courseTextAlignment = .left
    $0.courseItemTextSize = 13
    $0.roomNameFontSize = 8
    $0.textEdgeInsets = UIEdgeInsets(top: 2, left: 3, bottom: 2, right: 10)
  }
  
  private let indicatorView = UIActivityIndicatorView(style: .large)
  
  init(viewModel: ScheduleViewModelType = ScheduleViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    /// Set Delegate & DataSource
    elliotable.delegate = self
    elliotable.dataSource = self
    
    /// Set Navigationbar
    title = "시간표"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: Constants.backButton),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
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
    viewModel.scheduleInfo
      .drive(rx.courseModel)
      .disposed(by: disposeBag)
    
    viewModel.isLoading
      .drive(indicatorView.rx.isAnimating)
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
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
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
    return courseModel
  }
}
