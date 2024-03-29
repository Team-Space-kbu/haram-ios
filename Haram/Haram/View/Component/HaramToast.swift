//
//  HaramToast.swift
//  Haram
//
//  Created by 이건준 on 2023/09/13.
//

import UIKit

import SnapKit
import Then

/// `Toast` 클래스입니다.
final class HaramToast: UIView {
  
  // MARK: - Properties
  
  enum ToastType {
    /// 토스트 성공 메시지
    case success
    
    /// 토스트 실패 메시지
    case failure
    
    fileprivate var image: UIImage? {
      switch self {
      case .success:
        return .init(systemName: "checkmark.circle.fill")
      case .failure:
        return .init(named: "exclamationCircle")
      }
    }
  }
  
  /// Toast에 들어갈 text
  private var text: String? {
    get { label.text }
    set { label.text = newValue }
  }
  
  /// Toast의 지속 시간
  private var duration: Duration
  
  /// 토스트 타입
  private var toastType: ToastType
  
  // MARK: - UI Components
  
  private let stackView = UIStackView().then {
    $0.alignment = .center
    $0.spacing = 4
  }
  
  private let indicationImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }
  
  private let label = UILabel().then {
    $0.font = .regular16
    $0.numberOfLines = 0
    $0.textColor = .white
  }
  
  // MARK: - Initializations
  
  /// private init입니다. Toast를 만들고 싶다면
  /// `makeToast`를 이용해주세요.
  private init(text: String?, duration: Duration, toastType: ToastType) {
    self.duration = duration
    self.toastType = toastType
    super.init(frame: .zero)
    self.text = text
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// Toast를 생성합니다.
  /// 생성될 때, 적절한 위치에 맞추어 Toast가 나타났다가 사라지게 됩니다.
  /// - Parameters:
  ///   - text: Toast 내부에 들어갈 텍스트
  ///   - duration: Toast의 지속시간, `.short`는 1.5초, `.long`은 3초입니다.
  static func makeToast(text: String?, duration: Duration = .long, toastType: ToastType = .success) {
    guard let text, !text.isEmpty else { return }
    
    let toast = HaramToast(text: text, duration: duration, toastType: toastType)
    
    guard let window = UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .flatMap(\.windows)
      .first(where: \.isKeyWindow)
    else {
      return
    }
    
    window.addSubview(toast)
    toast.snp.makeConstraints {
      $0.bottom.equalTo(window.safeAreaLayoutGuide).inset(Metrics.Margin.vertical)
      $0.centerX.equalToSuperview()
      $0.width.lessThanOrEqualTo(window.safeAreaLayoutGuide).inset(Metrics.Margin.horizontal)
    }
    
    toast.showToast()
  }
  
  // MARK: - Configurations
  
  private func setupLayouts() {
    addSubview(stackView)
    [indicationImageView, label].forEach {
      stackView.addArrangedSubview($0)
    }
  }
  
  /// 오토레이아웃을 세팅합니다.
  ///
  /// label의 width에 lessThanOrEqualToSuperview()를 사용함으로써
  /// 1줄일 때 중앙정렬, 2줄 이상일 때 좌측정렬이 됩니다.
  private func setupConstraints() {
    stackView.snp.makeConstraints {
      $0.directionalVerticalEdges.equalToSuperview().inset(Metrics.Padding.vertical)
      $0.directionalHorizontalEdges.equalToSuperview().inset(Metrics.Padding.horizontal)
      $0.height.greaterThanOrEqualTo(Metrics.Size.height)
      $0.centerX.equalToSuperview()
    }
    
    indicationImageView.snp.makeConstraints {
      $0.size.equalTo(Metrics.Size.image)
    }
  }
  
  private func setupStyles() {
    indicationImageView.image = toastType.image
    backgroundColor = .black.withAlphaComponent(0.8)
    layer.cornerRadius = 8
    clipsToBounds = true
    alpha = 0
  }
  
  // MARK: - Custom Methods
  
  /// Toast의 alpha값을 0에서 1로 변경하여 Toast가 보이도록 합니다.
  private func showToast() {
    UIView.animate(
      withDuration: 0.5,
      delay: 0,
      options: .curveEaseIn) {
        self.alpha = 1
      } completion: { _ in
        self.hideToast()
      }
  }
  
  /// 지속시간이 지난 이후 다시 alpha값을 0으로 만들어 Toast가 사라지도록 만듭니다.
  private func hideToast() {
    UIView.animate(
      withDuration: 0.25,
      delay: duration.value,
      options: .curveEaseOut) {
        self.alpha = 0
      } completion: { _ in
        self.removeToast()
      }
  }
  
  /// Toast를 제거합니다.
  private func removeToast() {
    self.removeFromSuperview()
  }
}

// MARK: - Constants

extension HaramToast {
  
  /// Toast 지속 시간을 설정하는 enum입니다.
  enum Duration {
    case short
    case long
    
    var value: Double {
      switch self {
      case .short:            return 1.5
      case .long:             return 3
      }
    }
  }
  
  private enum Metrics {
    enum Margin {
      static let horizontal   = 16
      static let vertical     = 24 + 46 + 24
    }
    
    enum Padding {
      static let horizontal   = 10
      static let vertical     = 4
    }
    
    enum Size {
      static let image        = 32
      static let height       = 40
    }
  }
}
