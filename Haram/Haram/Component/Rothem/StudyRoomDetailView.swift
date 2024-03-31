//
//  StudyRoomDetailView.swift
//  Haram
//
//  Created by 이건준 on 2023/08/19.
//

import UIKit

import RxSwift
import SnapKit
import SkeletonView
import Then

struct RothemRoomDetailViewModel {
  let roomTitle: String
  let roomDestination: String
  let roomDescription: String
  let amenityModel: [PopularAmenityCollectionViewCellModel]
  
  init(response: InquireRothemRoomInfoResponse) {
    roomTitle = response.roomResponse.roomName
    roomDestination = response.roomResponse.location
    roomDescription = response.roomResponse.roomExplanation
    amenityModel = response.amenityResponses.map { PopularAmenityCollectionViewCellModel(response: $0) }
  }
}

protocol RothemRoomDetailViewDelegate: AnyObject {
  func didTappedReservationButton()
}

final class RothemRoomDetailView: UIView {
  
  private let disposeBag = DisposeBag()
  weak var delegate: RothemRoomDetailViewDelegate?
  
  private var amenityModel: [PopularAmenityCollectionViewCellModel] = [] {
    didSet {
      popularAmenityCollectionView.reloadData()
    }
  }
  
  private let scrollView = UIScrollView().then {
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
    $0.showsVerticalScrollIndicator = false
    $0.isSkeletonable = true
    $0.contentInsetAdjustmentBehavior = .never
  }
  
  private let containerView = UIView().then {
    $0.backgroundColor = .clear
    $0.isSkeletonable = true
  }
  
  private let roomTitleLabel = UILabel().then {
    $0.font = .bold25
    $0.textColor = .black
    $0.isSkeletonable = true
  }
  
  private let roomLocationView = AffiliatedLocationView().then {
    $0.isSkeletonable = true
  }
  
//  private let roomDestinationLabel = UILabel().then {
//    $0.font = .regular12
//    $0.textColor = .hex9F9FA4
//    $0.sizeToFit()
//    $0.isSkeletonable = true
//  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .hexD8D8DA
    $0.isSkeletonable = true
  }
  
  private let roomDescriptionTitleLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .black
    $0.text = "Description"
    $0.isSkeletonable = true
  }
  
  private let roomDescriptionContentLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .hex9F9FA4
    $0.numberOfLines = 0
    $0.isSkeletonable = true
    $0.skeletonTextNumberOfLines = 3
  }
  
  private let popularAmenityTitleLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .black
    $0.text = "Popular amenities"
    $0.isSkeletonable = true
  }
  
  private lazy var popularAmenityCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.minimumInteritemSpacing = 17
    }
  ).then {
    $0.register(PopularAmenityCollectionViewCell.self, forCellWithReuseIdentifier: PopularAmenityCollectionViewCell.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.isSkeletonable = true
  }
  
  private let reservationButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.haramButton(label: "예약하기", contentInsets: .zero)
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = 10
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func bind() {
    reservationButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedReservationButton()
      }
      .disposed(by: disposeBag)
  }
  
  private func configureUI() {
    
    isSkeletonable = true
    
    addSubview(scrollView)
    
    scrollView.addSubview(containerView)
    
    [roomTitleLabel, roomLocationView, lineView, roomDescriptionTitleLabel, roomDescriptionContentLabel, popularAmenityTitleLabel, popularAmenityCollectionView, reservationButton].forEach { containerView.addSubview($0) }
    
    scrollView.snp.makeConstraints {
      $0.directionalEdges.width.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.directionalVerticalEdges.width.equalToSuperview()
      $0.height.greaterThanOrEqualToSuperview()
    }
    
    roomTitleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(16)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(30)
    }
    
    roomLocationView.snp.makeConstraints {
      $0.top.equalTo(roomTitleLabel.snp.bottom).offset(5)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(14)
    }
    
    lineView.snp.makeConstraints {
      $0.top.equalTo(roomLocationView.snp.bottom).offset(17)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(1)
    }
    
    roomDescriptionTitleLabel.snp.makeConstraints {
      $0.top.equalTo(lineView.snp.bottom).offset(17)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(22)
    }
    
    roomDescriptionContentLabel.snp.makeConstraints {
      $0.top.equalTo(roomDescriptionTitleLabel.snp.bottom).offset(7)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
    }
    
    popularAmenityTitleLabel.snp.makeConstraints {
      $0.top.equalTo(roomDescriptionContentLabel.snp.bottom).offset(20)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(22)
    }
    
    popularAmenityCollectionView.snp.makeConstraints {
      $0.top.equalTo(popularAmenityTitleLabel.snp.bottom).offset(11)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.height.equalTo(56)
    }
    
    reservationButton.snp.makeConstraints {
      $0.top.greaterThanOrEqualTo(popularAmenityCollectionView.snp.bottom).offset(17)
      $0.height.equalTo(49)
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.bottom.equalToSuperview().inset(Device.bottomInset)
    }
  }
  
  func configureUI(with model: RothemRoomDetailViewModel) {
    
    roomTitleLabel.hideSkeleton()
    roomLocationView.hideSkeleton()
    roomDescriptionContentLabel.hideSkeleton()
    
    amenityModel = model.amenityModel
    roomTitleLabel.text = model.roomTitle
    roomLocationView.configureUI(with: .init(locationImageResource: .locationGray, locationContent: model.roomDestination))
//    let attributedString = NSMutableAttributedString(string: "")
//    let imageAttachment = NSTextAttachment()
//    imageAttachment.image = UIImage(resource: .locationGray)
//    imageAttachment.bounds = CGRect(x: 0, y: 0, width: 10, height: 12)
//    attributedString.append(NSAttributedString(attachment: imageAttachment))
//    attributedString.append(NSAttributedString(string: model.roomDestination))
//    roomDestinationLabel.attributedText = attributedString
    
    roomDescriptionContentLabel.addLineSpacing(lineSpacing: 2, string: model.roomDescription)
  }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension RothemRoomDetailView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return amenityModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularAmenityCollectionViewCell.identifier, for: indexPath) as? PopularAmenityCollectionViewCell ?? PopularAmenityCollectionViewCell()
    cell.configureUI(with: amenityModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    guard !amenityModel.isEmpty else {
      return CGSize(width: 48, height: 56)
    }
    let label = UILabel().then {
      $0.font = .regular12
      $0.text = amenityModel[indexPath.row].amenityContent
      $0.sizeToFit()
    }
    return CGSize(width: label.frame.width, height: 56)
  }
}

extension RothemRoomDetailView: SkeletonCollectionViewDataSource {
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
    PopularAmenityCollectionViewCell.identifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    let cell = skeletonView.dequeueReusableCell(withReuseIdentifier: PopularAmenityCollectionViewCell.identifier, for: indexPath) as? PopularAmenityCollectionViewCell ?? PopularAmenityCollectionViewCell()
    return cell
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    5
  }
}
