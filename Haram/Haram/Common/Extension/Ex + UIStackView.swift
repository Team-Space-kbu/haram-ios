//
//  Ex + UIStackView.swift
//  Haram
//
//  Created by 이건준 on 9/19/24.
//

import UIKit

extension UIStackView {
    
    /**
    StackView 사용시, subView들 사이에 DividerView를 삽입해 주는 extension
     - Parameters:
        - views: addArrangedSubview를 통해 주입될 subView들
        - exclude: 해당 index 아래에는 dvider 주입 안함
        - divider: UIView를 반환하는 클로저. UIView가 클래스 이기 때문에 해당 방식으로 주입
     */
    func addArrangedSubviews(_ views: [UIView], _ exclude: [Int], divier: (() -> UIView)) {
        
        let noDivier = Set(exclude)
        let lastIndex = views.count - 1
        
        for (index, subView) in views.enumerated() {
            self.addArrangedSubview(subView)
            if index < lastIndex && noDivier.contains(index) == false {
                self.addArrangedSubview(divier())
            }
        }
    }
}
