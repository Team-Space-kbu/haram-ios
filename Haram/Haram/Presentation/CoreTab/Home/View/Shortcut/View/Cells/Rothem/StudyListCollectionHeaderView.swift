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
            self.backgroudImageView.image = self.enhanceWhiteText(in: thumbnailImage!)
          }
        }
      }.resume()
    }
    
    func applyDarkFilter(to image: UIImage) -> UIImage? {
      let context = CIContext(options: nil)
      if let filter = CIFilter(name: "CIPhotoEffectMono") {
        let ciImage = CIImage(image: image)
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(-0.1, forKey: kCIInputBrightnessKey) // 어두움 정도를 조절할 수 있습니다. 0에 가까울수록 어두워집니다.
        if let output = filter.outputImage {
          if let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage)
          }
        }
      }
      return nil
    }
    
    func enhanceWhiteText(in image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        // 밝기 조절
        let exposureFilter = CIFilter(name: "CIExposureAdjust")
        exposureFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        exposureFilter?.setValue(-3.0, forKey: kCIInputEVKey) // 더 많이 밝기를 줄여서 어둡게 만듭니다.
        
        guard let exposureAdjustedCIImage = exposureFilter?.outputImage else { return nil }
        
        // 하이라이트와 그림자 조절
        let highlightShadowFilter = CIFilter(name: "CIHighlightShadowAdjust")
        highlightShadowFilter?.setValue(exposureAdjustedCIImage, forKey: kCIInputImageKey)
        highlightShadowFilter?.setValue(1.0, forKey: "inputHighlightAmount") // 하이라이트를 강조
        highlightShadowFilter?.setValue(0.5, forKey: "inputShadowAmount") // 그림자를 줄임
        
        guard let outputCIImage = highlightShadowFilter?.outputImage else { return nil }
        
        // CIImage를 UIImage로 변환
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
        let outputUIImage = UIImage(cgImage: cgImage)
        
        return outputUIImage
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

