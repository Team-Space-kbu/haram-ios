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
  private let id: Int
  
  private let detailImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.masksToBounds = true
    $0.isSkeletonable = true
    $0.isUserInteractionEnabled = true
  }
  
  private let button = UIButton()
  
  private let backgroundView = UIView().then {
    $0.backgroundColor = .clear
    $0.layer.shadowColor = UIColor(hex: 0x000000).withAlphaComponent(0.16).cgColor
    $0.layer.shadowOpacity = 1
    $0.layer.shadowRadius = 10
    $0.layer.shadowOffset = CGSize(width: 0, height: -3)
    $0.isSkeletonable = true
  }
  
  private let affiliatedDetailView = AffiliatedDetailInfoView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.maskedCorners = CACornerMask(
      arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner
    )
    $0.backgroundColor = .white
    $0.isSkeletonable = true
  }
  
  init(id: Int, viewModel: AffiliatedDetailViewModelType = AffiliatedDetailViewModel()) {
    self.id = id
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerNotifications()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeNotifications()
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    setupBackButton()
    setupSkeletonView()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    _ = [detailImageView, backgroundView].map { view.addSubview($0) }
    backgroundView.addSubview(affiliatedDetailView)
    detailImageView.addSubview(button)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    backgroundView.snp.makeConstraints {
      $0.bottom.equalToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo((((UIScreen.main.bounds.height - UINavigationController().navigationBar.frame.height) / 3) * 2))
    }
    
    affiliatedDetailView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    detailImageView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.equalTo(affiliatedDetailView.snp.top).offset(40)
    }
    
    button.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    
    viewModel.inquireAffiliatedDetail(id: id)
    
    viewModel.affiliatedDetailModel
      .drive(with: self) { owner, model in
        owner.view.hideSkeleton()
        owner.affiliatedDetailView.configureUI(with: model)
        owner.detailImageView.kf.setImage(with: model.imageURL)
      }
      .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .emit(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(title: "네트워크 연결 알림", message: "네트워크가 연결되있지않습니다\n Wifi혹은 데이터를 연결시켜주세요.", viewController: owner) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          }
        }
      }
      .disposed(by: disposeBag)
    
    button.rx.tap
      .subscribe(with: self) { owner, _ in
        if let zoomImage = owner.detailImageView.image {
          let modal = ZoomImageViewController(zoomImage: zoomImage)
          modal.modalPresentationStyle = .fullScreen
          owner.present(modal, animated: true)
        } else {
          AlertManager.showAlert(title: "이미지 확대 알림", message: "해당 이미지는 확대할 수 없습니다", viewController: owner, confirmHandler: nil)
        }
      }
      .disposed(by: disposeBag)
  }
  
  func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

struct AffiliatedDetailInfoViewModel {
  let imageURL: URL?
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
      $0.showsVerticalScrollIndicator = false
      $0.isSkeletonable = true
    }
    
    private let containerView = UIStackView().then {
      $0.backgroundColor = .clear
      $0.axis = .vertical
      $0.isLayoutMarginsRelativeArrangement = true
      $0.layoutMargins = .init(top: 30, left: 15, bottom: 15, right: 15)
      $0.spacing = 15
      $0.isSkeletonable = true
    }
    
    private let affiliatedTitleLabel = UILabel().then {
      $0.font = .bold25
      $0.textColor = .black
      $0.isSkeletonable = true
      $0.numberOfLines = 0
    }
    
    private let affiliatedLocationView = AffiliatedLocationView().then {
      $0.isSkeletonable = true
    }
    
    private let lineView = UIView().then {
      $0.backgroundColor = .hexD8D8DA
      $0.isSkeletonable = true
    }
    
    private let affiliatedIntroduceView = AffiliatedIntroduceView().then {
      $0.isSkeletonable = true
    }
    
    private let affiliatedBenefitView = AffiliatedBenefitView().then {
      $0.isSkeletonable = true
    }
    
    private let lineView2 = UIView().then {
      $0.backgroundColor = .hexD8D8DA
      $0.isSkeletonable = true
    }
    
    private let affiliatedMapView = AffiliatedMapView().then {
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

extension AffiliatedDetailViewController {
  private func registerNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(refreshWhenNetworkConnected), name: .refreshWhenNetworkConnected, object: nil)
  }
  
  private func removeNotifications() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  private func refreshWhenNetworkConnected() {
    viewModel.inquireAffiliatedDetail(id: id)
  }
}
