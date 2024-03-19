//
//  ChapelViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/06.
//

import UIKit

import RxCocoa
import SnapKit
import SkeletonView
import Then

final class ChapelViewController: BaseViewController, BackButtonHandler {
  
  private let viewModel: ChapelViewModelType
  
  private var chapelHeaderModel: ChapelCollectionHeaderViewModel?
  
  private var chapelListModel: [ChapelCollectionViewCellModel] = []
  
  private lazy var chapelCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
    $0.minimumLineSpacing = 20
  }).then {
    $0.register(ChapelCollectionViewCell.self, forCellWithReuseIdentifier: ChapelCollectionViewCell.identifier)
    $0.register(ChapelCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ChapelCollectionHeaderView.identifier)
    $0.dataSource = self
    $0.delegate = self
    $0.backgroundColor = .white
    $0.contentInset = .init(top: .zero, left: 15, bottom: 15, right: 15)
    $0.isSkeletonable = true
    $0.alwaysBounceVertical = true
  }
  
  init(viewModel: ChapelViewModelType = ChapelViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    
    viewModel.inquireChapelInfo()
    
    viewModel.chapelHeaderModel
      .drive(with: self) { owner, chapelHeaderModel in
        owner.chapelHeaderModel = chapelHeaderModel
        owner.viewModel.inquireChapelDetail()
      }
      .disposed(by: disposeBag)
    
    viewModel.chapelListModel
      .drive(with: self) { owner, chapelListModel in
        owner.chapelListModel = chapelListModel
        
        owner.view.hideSkeleton()
        
        owner.chapelCollectionView.reloadData()
      }
      .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        if error == .requiredStudentID {
          let vc = IntranetCheckViewController()
          vc.navigationItem.largeTitleDisplayMode = .never
          owner.navigationController?.pushViewController(vc, animated: true)
        } else if error == .networkError {
          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요.", viewController: owner) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
            owner.navigationController?.popViewController(animated: true)
          }
        }
      }
      .disposed(by: disposeBag)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    _ = [chapelCollectionView].map { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()  
    chapelCollectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "채플조회"
    setupBackButton()
    navigationController?.interactivePopGestureRecognizer?.delegate = self
    setupSkeletonView()
  }
  
  @objc func didTappedBackButton() {
    self.navigationController?.popViewController(animated: true)
  }
}

extension ChapelViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return chapelListModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChapelCollectionViewCell.identifier, for: indexPath) as? ChapelCollectionViewCell ?? ChapelCollectionViewCell()
    cell.configureUI(with: chapelListModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ChapelCollectionHeaderView.identifier, for: indexPath) as? ChapelCollectionHeaderView ?? ChapelCollectionHeaderView()
    header.configureUI(with: chapelHeaderModel)
    return header
  }
}

extension ChapelViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: 44)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: 28 + 14 + 320 + 45 + 40 - 20)
  }
}

extension ChapelViewController: SkeletonCollectionViewDataSource {
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
    ChapelCollectionViewCell.identifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    let cell = skeletonView.dequeueReusableCell(withReuseIdentifier: ChapelCollectionViewCell.identifier, for: indexPath) as? ChapelCollectionViewCell
    cell?.configureUI(with: .init(chapelResult: .absence))
    return cell
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, supplementaryViewIdentifierOfKind: String, at indexPath: IndexPath) -> ReusableCellIdentifier? {
    ChapelCollectionHeaderView.identifier
  }
}

extension ChapelViewController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true // or false
  }
}
