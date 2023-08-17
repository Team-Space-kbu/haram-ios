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
  
  private let studyReservationLabel = UILabel()
  
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
      $0.height.equalTo(300)
    }
    
    studyReservationLabel.snp.makeConstraints {
      $0.top.equalTo(studyListHeaderView.snp.bottom).offset(10)
      $0.leading.equalToSuperview().inset(10)
    }
  }
  
  func configureUI(with model: StudyListHeaderViewModel) {
    studyListHeaderView.configureUI(with: model)
  }
}

// MARK: - StudyListHeaderView

extension StudyListCollectionHeaderView {
  final class StudyListHeaderView: UIView {
    
    private let backgroudImageView = UIImageView()
    
    private let titleLabel = UILabel()
    
    private let descriptionLabel = UILabel()
    
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
        $0.leading.bottom.equalToSuperview().inset(15)
        $0.trailing.lessThanOrEqualToSuperview()
      }
      
      titleLabel.snp.makeConstraints {
        $0.bottom.equalTo(descriptionLabel.snp.top).offset(-10)
        $0.leading.equalToSuperview()
        $0.trailing.lessThanOrEqualToSuperview()
      }
    }
    
    func configureUI(with model: StudyListHeaderViewModel) {
      titleLabel.text = model.title
      descriptionLabel.text = model.description
      backgroudImageView.kf.setImage(with: model.thumbnailImageURL)
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
