//
//  StudyListCollectionHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/08/17.
//

import CoreImage
import UIKit

import SnapKit
import SkeletonView
import Then
import Kingfisher

enum StudyListCollectionHeaderViewType {
  case noReservation
  case reservation
}

protocol StudyListCollectionHeaderViewDelegate: AnyObject {
  func didTappedCheckButton()
}

final class StudyListCollectionHeaderView: UICollectionReusableView {
  
  static let identifier = "StudyListCollectionHeaderView"
  weak var delegate: StudyListCollectionHeaderViewDelegate?
  
  // MARK: - UI Components
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 26
    $0.isSkeletonable = true
  }
  
  private let studyListHeaderView = StudyListHeaderView()
  
  private let checkReservationInfoView = CheckReservationInfoView()
  
  private let studyReservationLabel = UILabel().then {
    $0.font = .bold22
    $0.textColor = .black
    $0.text = "로뎀스터디룸예약"
    $0.isSkeletonable = true
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    
    /// Set Skeleton
    isSkeletonable = true
    
    
    /// Set delegate
    checkReservationInfoView.delegate = self
    
    /// Set Layout
    addSubview(containerView)
    [studyListHeaderView, studyReservationLabel].forEach { containerView.addArrangedSubview($0) }
    
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    studyListHeaderView.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(294)
    }
    
    studyReservationLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(15)
      $0.bottom.equalToSuperview().inset(22)
    }
    
  }
  
  func configureUI(with model: StudyListHeaderViewModel?, type: StudyListCollectionHeaderViewType = .noReservation) {
    guard let model = model else { return }
    let isContain = containerView.subviews.contains(checkReservationInfoView)
    if type == .reservation {
      if !isContain {
        containerView.insertArrangedSubview(checkReservationInfoView, at: 1)
        checkReservationInfoView.snp.makeConstraints {
          $0.height.equalTo(41)
          $0.directionalHorizontalEdges.equalToSuperview().inset(15)
        }
        containerView.setCustomSpacing(27, after: checkReservationInfoView)
      }
      studyListHeaderView.configureUI(with: model)
    } else {
      if isContain {
        checkReservationInfoView.removeFromSuperview()
      }
      studyListHeaderView.configureUI(with: model)
    }
  }
}

// MARK: - StudyListHeaderView

extension StudyListCollectionHeaderView {
  final class StudyListHeaderView: UIView {
    
    private let backgroudImageView = UIImageView().then {
      $0.contentMode = .scaleAspectFill
    }
    
    private let titleLabel = UILabel().then {
      $0.textColor = .white
      $0.font = .bold18
    }
    
    private let descriptionLabel = UILabel().then {
      $0.textColor = .white
      $0.font = .regular14
      $0.numberOfLines = 0
    }
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      configureUI()
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
      isSkeletonable = true
      
      addSubview(backgroudImageView)
      [titleLabel, descriptionLabel].forEach { backgroudImageView.addSubview($0) }
      
      backgroudImageView.snp.makeConstraints {
        $0.directionalEdges.equalToSuperview()
      }
      
      descriptionLabel.snp.makeConstraints {
        $0.leading.equalToSuperview().inset(15)
        $0.trailing.lessThanOrEqualToSuperview().inset(12)
        $0.bottom.lessThanOrEqualToSuperview().inset(22)
      }
      
      titleLabel.snp.makeConstraints {
        $0.bottom.equalTo(descriptionLabel.snp.top).offset(-12)
        $0.leading.equalToSuperview().inset(15)
        $0.trailing.lessThanOrEqualToSuperview().inset(12)
      }
    }
    
    func configureUI(with model: StudyListHeaderViewModel) {
      titleLabel.text = model.title
      descriptionLabel.text = model.description
      
      URLSession.shared.dataTask(with: model.thumbnailImageURL!) { data, _, error in
        if let data = data, error == nil {
          let thumbnailImage = UIImage(data: data)
          DispatchQueue.main.async {
            self.backgroudImageView.image = self.applyDarkFilter(to: thumbnailImage!)
          }
        }
      }.resume()
    }
    
    func applyDarkFilter(to image: UIImage) -> UIImage? {
      let context = CIContext(options: nil)
      if let filter = CIFilter(name: "CIColorControls") {
        let ciImage = CIImage(image: image)
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(-0.5, forKey: kCIInputBrightnessKey) // 어두움 정도를 조절할 수 있습니다. 0에 가까울수록 어두워집니다.
        if let output = filter.outputImage {
          if let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage)
          }
        }
      }
      return nil
    }
  }
}

struct StudyListHeaderViewModel: Hashable {
  let thumbnailImageURL: URL?
  let title: String
  let description: String
  private let identifier = UUID()
  
  init(rothemNotice: NoticeResponse) {
    thumbnailImageURL = URL(string: rothemNotice.thumbnailPath)
    title = rothemNotice.title
    description = rothemNotice.content
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
}

extension StudyListCollectionHeaderView: CheckReservationInfoViewDelegate {
  func didTappedButton() {
    delegate?.didTappedCheckButton()
  }
}

