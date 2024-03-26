//
//  AffiliatedDetailViewController.swift
//  Haram
//
//  Created by 이건준 on 3/26/24.
//

import UIKit

import SnapKit
import Then

final class AffiliatedDetailViewController: BaseViewController, BackButtonHandler {
  
  private let viewModel: AffiliatedDetailViewModelType
  
  private let detailImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }
  
  private let affiliatedDetailView = AffiliatedDetailInfoView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.maskedCorners = CACornerMask(
      arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner
    )
    $0.backgroundColor = .white
  }
  
  init(viewModel: AffiliatedDetailViewModelType = AffiliatedDetailViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    setupBackButton()
    detailImageView.kf.setImage(with: URL(string: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20220726_135%2F1658824149602owtrU_JPEG%2FSE-bc4d3285-021e-49d8-b798-f273383d16b8.jpg"))
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    _ = [detailImageView, affiliatedDetailView].map { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    affiliatedDetailView.snp.makeConstraints {
      $0.bottom.equalToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo((((UIScreen.main.bounds.height - UINavigationController().navigationBar.frame.height) / 3) * 2))
    }
    
    detailImageView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.equalTo(affiliatedDetailView.snp.top).offset(40)
    }
  }
  
  override func bind() {
    super.bind()
    
    viewModel.affiliatedDetailModel
      .drive(with: self) { owner, model in
        owner.affiliatedDetailView.configureUI(with: model)
      }
      .disposed(by: disposeBag)
  }
  
  func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

struct AffiliatedDetailInfoViewModel {
  let title: String
  let affiliatedLocationModel: AffiliatedLocationViewModel
  let affiliatedIntroduceModel: AffiliatedIntroduceViewModel
  let affiliatedBenefitModel: AffiliatedBenefitViewModel
  let affiliatedMapViewModel: AffiliatedMapViewModel
}

extension AffiliatedDetailViewController {
  final class AffiliatedDetailInfoView: UIView {
    
    private let scrollView = UIScrollView().then {
      $0.backgroundColor = .clear
      $0.alwaysBounceVertical = true
    }
    
    private let containerView = UIStackView().then {
      $0.backgroundColor = .clear
      $0.axis = .vertical
      $0.isLayoutMarginsRelativeArrangement = true
      $0.layoutMargins = .init(top: 30, left: 15, bottom: 15, right: 15)
      $0.spacing = 15
    }
    
    private let affiliatedTitleLabel = UILabel().then {
      $0.font = .bold25
      $0.textColor = .black
    }
    
    private let affiliatedLocationView = AffiliatedLocationView()
    
    private let lineView = UIView().then {
      $0.backgroundColor = .hexD8D8DA
    }
    
    private let affiliatedIntroduceView = AffiliatedIntroduceView()
    
    private let affiliatedBenefitView = AffiliatedBenefitView()
    
    private let lineView2 = UIView().then {
      $0.backgroundColor = .hexD8D8DA
    }
    
    private let affiliatedMapView = AffiliatedMapView()
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      configureUI()
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
      addSubview(scrollView)
      scrollView.addSubview(containerView)
      _ = [affiliatedTitleLabel, affiliatedLocationView, lineView, affiliatedIntroduceView, affiliatedBenefitView, lineView2, affiliatedMapView].map { containerView.addArrangedSubview($0) }
      
      scrollView.snp.makeConstraints {
        $0.directionalEdges.width.equalToSuperview()
      }
      
      containerView.snp.makeConstraints {
        $0.directionalVerticalEdges.width.equalToSuperview()
      }
      
      lineView.snp.makeConstraints {
        $0.height.equalTo(1)
      }
      
      lineView2.snp.makeConstraints {
        $0.height.equalTo(1)
      }
      
      affiliatedMapView.snp.makeConstraints {
        $0.height.equalTo(22 + 161 + 7) // 7은 지도와 지도 사이의 간격
      }
      
      containerView.setCustomSpacing(7, after: affiliatedTitleLabel)
    }
    
    func configureUI(with model: AffiliatedDetailInfoViewModel) {
      affiliatedTitleLabel.text = model.title
      affiliatedLocationView.configureUI(with: model.affiliatedLocationModel)
      affiliatedIntroduceView.configureUI(with: model.affiliatedIntroduceModel)
      affiliatedBenefitView.configureUI(with: model.affiliatedBenefitModel)
      affiliatedMapView.configureUI(with: model.affiliatedMapViewModel)
    }
  }
}
