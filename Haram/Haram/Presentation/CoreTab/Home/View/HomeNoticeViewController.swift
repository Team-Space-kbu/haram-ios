//
//  HomeNoticeViewController.swift
//  Haram
//
//  Created by 이건준 on 4/3/24.
//

import UIKit

import SnapKit
import Then

final class HomeNoticeViewController: BaseViewController, BackButtonHandler {
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.showsHorizontalScrollIndicator = false
    $0.showsVerticalScrollIndicator = true
    $0.isSkeletonable = true
    $0.alwaysBounceVertical = true
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .clear
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: .zero, left: 15, bottom: 15, right: 15)
    $0.isSkeletonable = true
    $0.spacing = 10
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .bold20
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.isSkeletonable = true
    $0.skeletonTextNumberOfLines = 1
    $0.text = "안녕하세요 Team Space 입니다!"
  }
  
  private let contentLabel = UILabel().then {
    $0.textColor = .hex9F9FA4
    $0.numberOfLines = 0
    $0.font = .regular18
    $0.textAlignment = .left
    $0.text =
    """
    안녕하세요 Team Space 입니다!
    오랜 시간동안 준비하여 드디어 어플리케이션 서비스를 시작하게 되었습니다.
    저는 Space의 팀원 이건준입니다. 졸업하여 이제는 제가 쓸 수 없게 되었지만
    후배분들이 조금이나마 더 편리하게 사용할 수 있으면 만족합니다.
    개발된 기능은 아직 모두 추가하지 못하였지만 협의가 되지않은 기능이 많기 때문에
    차근차근 업데이트를 진행할 예정입니다. 다양한 기능들이 준비되어 있으니 기대부탁드립니다 !
    그리고 이 서비스를 개발하기위해 팀원으로 고생한 임성묵, 문상우 학우와 서비스를 개발하는데
    도움을 주신 모든 분들께 감사하다는 말을 전하고 싶습니다, 감사합니다.
    """
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    _ = [titleLabel, contentLabel].map { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    scrollView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.top.width.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.height.equalTo(27)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "공지사항"
    setupBackButton()
    navigationController?.interactivePopGestureRecognizer?.delegate = self
  }
  
  func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
}

extension HomeNoticeViewController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true // or false
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // tap gesture과 swipe gesture 두 개를 다 인식시키기 위해 해당 delegate 추가
    return true
  }
}

