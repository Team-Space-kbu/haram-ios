//
//  BaseNavigationController.swift
//  Haram
//
//  Created by 이건준 on 10/14/23.
//

import UIKit.UIViewController

import class RxSwift.DisposeBag

class BaseNavigationController: UINavigationController {
  
  private var duringTransition = false
  private var disabledPopVCs: [String] = []
  /// A dispose bag. 각 ViewController에 종속적이다.
  final let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLayouts()
    setupConstraints()
    setupStyles()
    bind()
    
    interactivePopGestureRecognizer?.delegate = self
    self.delegate = self
  }
  
  override func pushViewController(_ viewController: UIViewController, animated: Bool) {
    duringTransition = true
    
    super.pushViewController(viewController, animated: animated)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
  
  /// UI 프로퍼티를 view에 할당합니다.
  ///
  /// ```
  /// func setupLayouts() {
  ///   self.view.addSubview(label)
  ///   self.stackView.addArrangedSubview(label)
  ///   self.label.layer.addSubLayer(gradientLayer)
  ///   // codes..
  /// }
  /// ```
  func setupLayouts() { }
  
  /// UI 프로퍼티의 제약조건을 설정합니다.
  ///
  /// ```
  /// func setupConstraints() {
  ///   // with SnapKit
  ///   label.snp.makeConstraints { make in
  ///     make.edges.equalToSuperview()
  ///   }
  ///   // codes..
  /// }
  /// ```
  func setupConstraints() { }
  
  /// View와 관련된 Style을 설정합니다.
  ///
  /// ```
  /// func setupStyles() {
  ///   navigationController?.navigationBar.tintColor = .white
  ///   view.backgroundColor = .white
  ///   // codes..
  /// }
  /// ```
  func setupStyles() {
    view.backgroundColor = .white
    //    navigationItem.backButtonTitle = ""
    //    navigationItem.title = nil
  }
  
  /// Action, State 스트림을 bind합니다.
  /// 예를들어, Button이 tap 되었을 때, 또는 tableView를 rx로 설정할 때 이용됩니다.
  ///
  /// ```
  /// func bind() {
  ///   button.rx.tap
  ///     .subscribe {
  ///       print("Tapped")
  ///     }
  ///     .disposed(by: disposeBag)
  ///   // codes..
  /// }
  /// ```
  func bind() { }
  
}

extension BaseNavigationController: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
    self.duringTransition = false
  }
}

extension BaseNavigationController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard gestureRecognizer == interactivePopGestureRecognizer,
          let topVC = topViewController else {
      return true // default value
    }
    
    return viewControllers.count > 1 && duringTransition == false && isPopGestureEnable(topVC)
  }
  
  private func isPopGestureEnable(_ topVC: UIViewController) -> Bool {
    for vc in disabledPopVCs {
      if String(describing: type(of: topVC)) == String(describing: vc) {
        return false
      }
    }
    return true
  }
}
