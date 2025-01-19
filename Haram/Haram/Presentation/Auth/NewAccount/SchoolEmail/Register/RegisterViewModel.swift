//
//  RegisterViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/01.
//

import Foundation

import RxSwift
import RxCocoa

final class RegisterViewModel: ViewModelType {
  private let disposeBag = DisposeBag()
  private let dependency: Dependency
  private let payload: Payload
  
  struct Payload {
    let authCode: String
    let email: String
  }
  
  var verifiedEmail: String {
    payload.email.replacingOccurrences(of: "@bible.ac.kr", with: "")
  }
  
  struct Dependency {
    let authRepository: AuthRepository
    let coordinator: RegisterCoordinator
  }
  
  struct Input {
    let didEditID: Observable<String>
    let didEditNickname: Observable<String>
    let didEditPassword: Observable<String>
    let didEditRepassword: Observable<String>
    let didTapRegisterButton: Observable<Void>
  }
  
  struct Output {
    let isRegisterButtonEnabledSubject = BehaviorSubject<Bool>(value: false)
    let errorMessageRelay              = PublishRelay<HaramError>()
    let successMessageRelay            = PublishRelay<HaramError>()
    let signupSuccessMessageRelay      = PublishRelay<String>()
    let isLoadingSubject               = PublishSubject<Bool>()
  }
  
  init(payload: Payload, dependency: Dependency) {
    self.payload = payload
    self.dependency = dependency
  }
  
  func transform(input: Input) -> Output {
    let output = Output()
    
    input.didTapRegisterButton
      .throttle(.milliseconds(500), latest: false, scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .withLatestFrom(
        Observable.combineLatest(
          input.didEditID,
          input.didEditNickname,
          input.didEditPassword,
          input.didEditRepassword
        )
      )
      .subscribe(with: self) { owner, result in
        let (id, nickname, password, repassword) = result
        
        guard owner.isValid(output: output, id: id) && owner.isValid(output: output, nickname: nickname) && owner.isValid(output: output, password: password) && owner.isEqual(output: output, password: password, repassword: repassword) else {
          print("회원가입 유효하지않은 값 존재")
          return
        }
        
        owner.registerMember(
          output: output,
          id: id,
          email: owner.payload.email,
          password: password,
          nickname: nickname,
          authCode: owner.payload.authCode
        )
      }
      .disposed(by: disposeBag)
    
    return output
  }
  
  func registerMember(output: Output, id: String, email: String, password: String, nickname: String, authCode: String) {
    
    output.isLoadingSubject.onNext(true)
    
    dependency.authRepository.signupUser(
      request: .init(
        userID: id,
        email: email,
        password: password,
        nickname: nickname,
        emailAuthCode: authCode,
        userTermsRequests: UserManager.shared.userTermsRequests!
      )
    )
    .subscribe(with: self, onSuccess: { owner, _ in
      owner.dependency.coordinator.showAlert(message: "회원가입 성공\n로그인 화면으로 이동합니다.") {
        owner.dependency.coordinator.popToRootViewController()
      }
    }, onFailure: { owner, error in
      guard let error = error as? HaramError else { return }
      output.errorMessageRelay.accept(error)
    }, onDisposed: { _ in
      output.isLoadingSubject.onNext(false)
    })
    .disposed(by: disposeBag)
  }
  
  private func isValidPassword(_ password: String) -> Bool {
    // 적어도 하나의 알파벳, 숫자, 특수 문자를 포함하는 정규 표현식
    let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
    
    // 정규 표현식과 매치되는지 확인
    let regexTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
    return regexTest.evaluate(with: password)
  }
  
  private func isValidAlphanumeric(_ input: String) -> Bool {
    // 영어 또는 숫자로만 이루어진 정규 표현식
    let alphanumericRegex = "^[a-zA-Z0-9]*$"
    
    // 정규 표현식과 매치되는지 확인
    let regexTest = NSPredicate(format: "SELF MATCHES %@", alphanumericRegex)
    return regexTest.evaluate(with: input)
  }
  
  private func isValidKoreanAlphanumeric(_ input: String) -> Bool {
    // 한글, 영어, 숫자로만 이루어진 정규 표현식
    let koreanAlphanumericRegex = "^[ㄱ-ㅎ가-힣a-zA-Z0-9]*$"
    
    // 정규 표현식과 매치되는지 확인
    let regexTest = NSPredicate(format: "SELF MATCHES %@", koreanAlphanumericRegex)
    return regexTest.evaluate(with: input)
  }
  
}

extension RegisterViewModel {
  func isEqual(output: Output, password: String, repassword: String) -> Bool {
    
    let isEqual = password == repassword
    if isEqual {
      output.successMessageRelay.accept(.noEqualPassword)
    } else {
      output.errorMessageRelay.accept(.noEqualPassword)
    }
    
    return isEqual
  }
  
  func isValid(output: Output, id: String) -> Bool {
    // userId가 4~30자, 영어 or 숫자만 가능

    let isUnValid = 4 > id.count || 30 < id.count || !isValidAlphanumeric(id)
    LogHelper.debug("아이디 유효안함 \(isUnValid)")
    if isUnValid {
      output.errorMessageRelay.accept(.unvalidUserIDFormat)
    } else {
      output.successMessageRelay.accept(.unvalidUserIDFormat)
    }
    
    return !isUnValid
  }
  
    func isValid(output: Output, password: String) -> Bool {
  
      let isUnValid = !isValidPassword(password)
      LogHelper.debug("비번 유효안함 \(isUnValid)")
      if isUnValid {
        output.errorMessageRelay.accept(.unvalidpasswordFormat)
      } else {
        output.successMessageRelay.accept(.unvalidpasswordFormat)
      }
      
      return !isUnValid
    }
  
    func isValid(output: Output, nickname: String) -> Bool {
  
      let isUnValid = 0..<2 ~= nickname.count || 15 < nickname.count || !isValidKoreanAlphanumeric(nickname)
      LogHelper.debug("닉네임 유효안함 \(isUnValid)")
      if isUnValid {
        output.errorMessageRelay.accept(.unvalidNicknameFormat)
      } else {
        output.successMessageRelay.accept(.unvalidNicknameFormat)
      }
      
      return !isUnValid
    }
}
