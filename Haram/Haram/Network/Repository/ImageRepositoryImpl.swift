//
//  ImageRepositoryImpl.swift
//  Haram
//
//  Created by 이건준 on 3/10/24.
//

import UIKit

import Alamofire
import RxSwift

protocol ImageRepository {
  func uploadImage(image: UIImage, request: UploadImageRequest, fileName: String) -> Single<UploadImageResponse>
}

final class ImageRepositoryImpl {
  
  private let service: BaseService
  
  init(service: BaseService = ApiService.shared) {
    self.service = service
  }
  
  private func setUpImageData(
    image: UIImage,
    params: [String: Any],
    fileName: String
  ) -> MultipartFormData {
    let formData = MultipartFormData()
    
    guard let imageData = image.jpegData(compressionQuality: 0.1) else { return formData }
    formData.append(
      imageData,
      withName: "multipartFile",
      fileName: fileName,
      mimeType: "image/jpeg"
    )
    
    for (key, value) in params {
      guard let value = value as? String else { continue }
      formData.append(
        Data(value.utf8),
        withName: key
      )
    }
    
    return formData
  }
  
}

extension ImageRepositoryImpl: ImageRepository {
  func uploadImage(image: UIImage, request: UploadImageRequest, fileName: String) -> Single<UploadImageResponse> {
    service.sendRequestWithImage(setUpImageData(
      image: image,
      params: request.toDictionary,
      fileName: fileName
    ), ImageRouter.uploadImage, type: UploadImageResponse.self)
  }
}

