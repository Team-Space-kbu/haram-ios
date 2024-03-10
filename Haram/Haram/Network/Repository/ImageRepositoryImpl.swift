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
  func uploadImage(image: UIImage, request: UploadImageRequest) -> Observable<Result<UploadImageResponse, HaramError>>
}

final class ImageRepositoryImpl {
  
  private let service: BaseService
  
  init(service: BaseService = ApiService.shared) {
    self.service = service
  }
  
  private func setUpImageData(
    image: UIImage,
    params: [String: Any]
  ) -> MultipartFormData {
    let formData = MultipartFormData()
    
//    for image in images {
//      guard let imageData = image.jpegData(compressionQuality: 0.1) else { continue }
//      formData.append(
//        imageData,
//        withName: "files",
//        fileName: "\(image).jpeg",
//        mimeType: "image/jpeg"
//      )
//    }
    
    guard let imageData = image.jpegData(compressionQuality: 0.1) else { return formData }
    formData.append(
      imageData,
      withName: "multipartFile",
      fileName: "\(image).jpeg",
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
  func uploadImage(image: UIImage, request: UploadImageRequest) -> Observable<Result<UploadImageResponse, HaramError>> {
    service.sendRequestWithImage(setUpImageData(
      image: image,
      params: request.toDictionary
    ), ImageRouter.uploadImage, type: UploadImageResponse.self)
  }
}

