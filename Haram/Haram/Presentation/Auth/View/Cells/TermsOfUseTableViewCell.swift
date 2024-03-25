//
//  TermsOfUseTableViewCell.swift
//  Haram
//
//  Created by 이건준 on 3/20/24.
//

import UIKit

import RxSwift
import SnapKit
import SkeletonView
import Then

struct TermsOfUseTableViewCellModel {
  let seq: Int
  let title: String
  var isChecked: Bool
  let isRequired: Bool
  
  init(response: InquireTermsSignUpResponse) {
    seq = response.termsSeq
    title = response.title
    isChecked = false
    isRequired = response.isRequired
  }
}

final class TermsOfUseTableViewCell: UITableViewCell {
  
  static let identifier = "TermsOfUseTableViewCell"
  
  private var seq: Int?
  private var isChecked = false {
    willSet {
      self.checkImage.layer.borderColor  = newValue ? UIColor.hex3B8686.cgColor : UIColor.lightGray.cgColor
      self.checkImage.image = newValue ? Image.checkShape?.withTintColor(.hex3B8686, renderingMode: .alwaysOriginal) :  nil
    }
  }
  
  private let checkImage = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 3
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = 3
  }
  
  private let alertLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .hex545E6A
    $0.textAlignment = .left
    $0.isSkeletonable = true
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    seq = nil
    alertLabel.text = nil
    isChecked = false
//    checkImage.image = nil
    checkImage.backgroundColor = nil
//    checkImage.layer.borderColor = nil
  }
  
  private func configureUI() {
    
    isSkeletonable = true
    contentView.isSkeletonable = true
    
    selectionStyle = .none
    self.checkImage.backgroundColor = .white
    self.checkImage.layer.borderWidth = 2
    self.checkImage.layer.borderColor = UIColor.lightGray.cgColor
    
    _ = [checkImage, alertLabel].map { contentView.addSubview($0) }
    
    checkImage.snp.makeConstraints {
      $0.leading.top.equalToSuperview()
      $0.size.equalTo(18)
    }
    
    alertLabel.snp.makeConstraints {
      $0.centerY.equalTo(checkImage)
      $0.leading.equalTo(checkImage.snp.trailing).offset(5)
      $0.trailing.equalToSuperview()
    }
  }
  
  func configureUI(with model: TermsOfUseTableViewCellModel) {
    alertLabel.text = model.title
    self.isChecked = model.isChecked
    seq = model.seq
  }
  
  private enum Image {
    static let checkShape = UIImage(systemName: "checkmark.square.fill")
  }
}
