//
//  PagingSectionFooterView.swift
//  Haram
//
//  Created by 이건준 on 2023/06/08.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

protocol PagingSectionFooterViewDelegate: AnyObject {
  func didChangedPageControl(_ currentPage: Int)
}

final class PagingSectionFooterView: UICollectionReusableView {
  
  weak var delegate: PagingSectionFooterViewDelegate?
  
  static let identifier = "PagingSectionFooterView"
  private let disposeBag = DisposeBag()
  
  private let pageControl = UIPageControl().then {
    $0.currentPage = 0
    $0.pageIndicatorTintColor = .systemGray2
    $0.currentPageIndicatorTintColor = UIColor.hex79BD9A
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    addSubview(pageControl)
    pageControl.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  private func bind() {
    pageControl.rx.controlEvent(.valueChanged)
      .subscribe(with: self) { owner,  _ in
        owner.delegate?.didChangedPageControl(owner.pageControl.currentPage)
      }
      .disposed(by: disposeBag)
  }
  
  func setPageControl(subBanners: [HomebannerCollectionViewCellModel], currentPage: PublishSubject<Int>) {
    pageControl.numberOfPages = subBanners.count
    currentPage
      .asDriver(onErrorDriveWith: .empty())
      .drive(pageControl.rx.currentPage)
      .disposed(by: disposeBag)
  }
}
