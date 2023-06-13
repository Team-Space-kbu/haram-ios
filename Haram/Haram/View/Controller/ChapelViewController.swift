//
//  ChapelViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/06.
//

import UIKit

import SnapKit
import Then

final class ChapelViewController: BaseViewController {
  
  private var chapelHeaderModel: ChapelCollectionHeaderViewModel? {
    didSet {
      chapelCollectionView.reloadData()
    }
  }
  
  private var chapelListModel: [ChapelCollectionViewCellModel] = [] {
    didSet {
      chapelCollectionView.reloadData()
    }
  }
  
  private lazy var chapelCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
    $0.minimumLineSpacing = 20
  }).then {
    $0.register(ChapelCollectionViewCell.self, forCellWithReuseIdentifier: ChapelCollectionViewCell.identifier)
    $0.register(ChapelCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ChapelCollectionHeaderView.identifier)
    $0.dataSource = self
    $0.delegate = self
    $0.backgroundColor = .systemBackground
    $0.contentInset = .init(top: .zero, left: 15, bottom: .zero, right: 15)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(chapelCollectionView)
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
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "back"),
      style: .done,
      target: self,
      action: #selector(didTappedBackButton)
    )
    
    if UserManager.shared.hasIntranetToken {
      IntranetService.shared.inquireChapelList(
        request: .init(
          intranetToken: UserManager.shared.intranetToken!,
          xsrfToken: UserManager.shared.xsrfToken!,
          laravelSession: UserManager.shared.laravelSession!
        )
      )
      .subscribe(with: self) { owner, response in
        let chapelListModel = response.map { ChapelCollectionViewCellModel(response: $0) }
        print("리스트조회 \(chapelListModel)")
        owner.chapelListModel = chapelListModel
      }
      .disposed(by: disposeBag)
      
      IntranetService.shared.inquireChapelInfo(
        request: .init(
          intranetToken: UserManager.shared.intranetToken!,
          xsrfToken: UserManager.shared.xsrfToken!,
          laravelSession: UserManager.shared.laravelSession!
        )
      )
      .subscribe(with: self) { owner, response in
        print("채플인포조회 \(response)")
        guard let entireDays = Int(response.entireDays),
              let confirmationDays = Int(response.confirmationDays) else { return }
        owner.chapelHeaderModel = ChapelCollectionHeaderViewModel(
          chapelDayViewModel: response.confirmationDays,
          chapelInfoViewModel: .init(
            attendanceDays: response.attendanceDays,
            remainDays: "\(entireDays - confirmationDays)",
            lateDays: response.lateDays)
        )
      }
      .disposed(by: disposeBag)
    }
  }
  
  @objc private func didTappedBackButton() {
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
    return CGSize(width: collectionView.bounds.width, height: 28 + 14 + 320)
  }
}
