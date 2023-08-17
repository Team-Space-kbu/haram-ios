//
//  StudyListCollectionHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/08/17.
//

import UIKit

import SnapKit
import Then

final class StudyListCollectionHeaderView: UICollectionReusableView {
  
  static let identifier = "StudyListCollectionHeaderView"
  
  // MARK: - UI Components
  
  private let studyListHeaderView = StudyListHeaderView()
  
  private let studyReservationLabel = UILabel().then {
    $0.font = .bold22
    $0.textColor = .black
    $0.text = "로뎀스터디룸예약"
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [studyListHeaderView, studyReservationLabel].forEach { addSubview($0) }
    
    studyListHeaderView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(294)
    }
    
    studyReservationLabel.snp.makeConstraints {
      $0.top.equalTo(studyListHeaderView.snp.bottom).offset(26)
      $0.leading.equalToSuperview().inset(15)
      $0.bottom.equalToSuperview().inset(22)
    }
  }
  
  func configureUI(with model: StudyListHeaderViewModel) {
    studyListHeaderView.configureUI(with: model)
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
    }
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      configureUI()
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
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
      backgroudImageView.image = UIImage(named: "notice")
//      backgroudImageView.kf.setImage(with: model.thumbnailImageURL)
    }
  }
}

struct StudyListHeaderViewModel: Hashable {
  let thumbnailImageURL: URL?
  let title: String
  let description: String
  private let identifier = UUID()
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
}
