//
//  BaseViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit.UIViewController

import class RxSwift.DisposeBag
import SkeletonView

protocol BaseViewControllerPorotocol where Self: BaseViewController {
  associatedtype ViewHolder: ViewHolderType
  associatedtype ViewModel: ViewModelType
  
  var viewModel: ViewModel { get }
  var viewHolder: ViewHolder { get }
}

extension BaseViewControllerPorotocol {
  func viewHolderConfigure() {
    viewHolder.place(in: view)
    viewHolder.configureConstraints(for: view)
  }
}

typealias ViewController = BaseViewController & BaseViewControllerPorotocol

class BaseViewController: UIViewController {
  
  /// A dispose bag. 각 ViewController에 종속적이다.
  final let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLayouts()
    setupConstraints()
    setupStyles()
    bind()
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
  
  func setupBackButton() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(resource: .back).withRenderingMode(.alwaysOriginal),
      style: .plain,
      target: self,
      action: nil
    )
  }
  
  func setupSkeletonView() {
    /// Configure Skeleton UI
    view.isSkeletonable = true
    
    let skeletonAnimation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .topLeftBottomRight)
    let graient = SkeletonGradient(baseColor: .skeletonDefault)
    
    view.showAnimatedGradientSkeleton(
      usingGradient: graient,
      animation: skeletonAnimation,
      transition: .none
    )
  }
}

