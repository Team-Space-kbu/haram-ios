//
//  HaramTabbarController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import UIKit

import SnapKit
import Then

final class HaramTabbarController: UITabBarController {
  
  private let homeViewController = UINavigationController(rootViewController: HomeViewController().then {
    $0.tabBarItem = UITabBarItem(
      title: "하람",
      image: UIImage(named: "home"),
      tag: 0
    )
  })
  
  private let boardViewController = UINavigationController(rootViewController: BoardViewController().then {
    $0.tabBarItem = UITabBarItem(
      title: "게시판",
      image: UIImage(named: "board"),
      tag: 2
    )
  })
  
  private let moreViewController = UINavigationController(rootViewController: MoreViewController().then {
    $0.tabBarItem = UITabBarItem(
      title: "더보기",
      image: UIImage(named: "more"),
      tag: 3
    )
  })
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLayouts()
    setupConstraints()
    setupStyles()
  }
  
  private func setupLayouts() {
    
    viewControllers = [
      homeViewController,
      boardViewController,
      moreViewController
    ]
  }
  
  private func setupConstraints() {
    
  }
  
  private func setupStyles() {
    
    tabBar.tintColor = .hex79BD9A
    tabBar.backgroundColor = .white
    
    // tab bar appearance
    tabBar.standardAppearance = UITabBarAppearance().then {
      $0.stackedLayoutAppearance = UITabBarItemAppearance().then {
        // Deselected state
        $0.normal.titleTextAttributes = [.font: UIFont.medium10, .foregroundColor: UIColor.hex95989A]
        
        // Selected State
        $0.selected.titleTextAttributes = [.font: UIFont.regular10, .foregroundColor: UIColor.hex79BD9A]
      }
    }
    delegate = self
  }
}
extension HaramTabbarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideTransitionAnimator(viewControllers: tabBarController.viewControllers)
    }
}
//extension HaramTabbarController: UITabBarControllerDelegate {
//  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
////    if viewController == boardViewController {
////      
////    }
////    else if viewController == moreViewController {
////      guard let vc = moreViewController.topViewController as? MoreViewController else { return }
////      vc.bind(userID: UserManager.shared.userID!)
////    }
//  }
//}
class SlideTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    // 각 뷰컨트롤러의 인덱스를 구하기 위해 사용
    let viewControllers: [UIViewController]?
    // 전환 애니메이션 시간
    let transitionDuration: Double = 0.5
    
    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }
    
    // 필수 메서드 (전환 애니메이션의 지속 시간)
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }
    
    // 필수 메서드 (전환 애니메이션 효과를 정의)
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let fromView = fromVC.view,
              let fromIndex = getIndex(forViewController: fromVC),
              let toVC = transitionContext.viewController(forKey: .to),
              let toView = toVC.view,
              let toIndex = getIndex(forViewController: toVC)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let frame = transitionContext.initialFrame(for: fromVC)
        var fromFrameEnd = frame
        var toFrameStart = frame
        // 탭바컨트롤러의 인덱스를 통해 x축으로 움직일 방향을 정해줌
        // 바뀔 뷰 > 현재 뷰 == 왼쪽으로 이동, 바뀔 뷰 < 현재 뷰 == 오른쪽으로 이동
        fromFrameEnd.origin.x = toIndex > fromIndex ? -frame.width : +frame.width
        toFrameStart.origin.x = toIndex > fromIndex ? +frame.width : -frame.width
        
        // 예를들어, 바뀔 뷰 > 현재 뷰라면 현재 toView.orisin.x 위치는 보이는 영역 바깥쪽(오른쪽)에 위치함.
        // 그리고 아래의 애니메이션을 통해 위치를 0으로 이동 시켜줌 (왼쪽으로 이동 시킴)
        toView.frame = toFrameStart
        
        DispatchQueue.main.async {
            // ⭐️ containerView는 애니메이션 실행되는 동안 나타나는 중간 뷰(틀)라고 생각하면 됩니다.
            // UIView.transition 메서드에서는 자동으로 슈퍼뷰에서 추가 및 제거가 됐지만,
            // 여기선 우리가 직접 뷰를 추가 및 제거 해줘야 합니다.
            transitionContext.containerView.addSubview(toView)
            UIView.animate(withDuration: self.transitionDuration) {
                fromView.frame = fromFrameEnd
                toView.frame = frame
            } completion: { success in
                // 슈퍼뷰에서 제거
                fromView.removeFromSuperview()
                // 필수적으로 전환이 완료 됬다는 시스템에 알려줘야 한다고 함.
                transitionContext.completeTransition(success)
            }
        }
    }
    
    // 현재 뷰컨트롤러의 인덱스 구하기 (인덱스를 통해 왼쪽, 오른쪽으로 넘길지 알아야 한다.)
    func getIndex(forViewController vc: UIViewController) -> Int? {
        guard let viewControllers = self.viewControllers else { return nil }
        for (index, viewController) in viewControllers.enumerated() {
            if viewController == vc { return index }
        }
        return nil
    }
}
