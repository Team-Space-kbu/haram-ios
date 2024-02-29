//
//  RegisterViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/01.
//

import Foundation

import RxSwift
import RxCocoa

protocol RegisterViewModelType {
  func registerMember(id: String, email: String, password: String, nickname: String, authCode: String)
  func checkUserIDIsValid(id: String)
  func checkPasswordIsValid(password: String)
  func checkEmailIsValid(email: String)
  func checkAuthCodeIsValid(authCode: String)
  func checkNicknameIsValid(nickname: String)
  func checkRepasswordIsEqual(password: String, repassword: String)
  
  func requestEmailAuthCode(email: String)
  
  var isRegisterButtonEnabled: Driver<Bool> { get }
  var isSendAuthCodeButtonEnabled: Driver<Bool> { get }
  var errorMessage: Signal<HaramError> { get }
  var successMessage: Signal<HaramError> { get }
  var signupSuccessMessage: Signal<String> { get }
  var isLoading: Driver<Bool> { get }
  var isSuccessRequestAuthCode: Driver<Bool> { get }
}

final class RegisterViewModel {
  private let disposeBag = DisposeBag()
  private let authRepository: AuthRepository
  
  private let isValidIDSubject              = BehaviorSubject<Bool>(value: false)
  private let isValidPWDSubject             = BehaviorSubject<Bool>(value: false)
  private let isValidRePWDSubject           = BehaviorSubject<Bool>(value: false)
  private let isValidEmailSubject           = BehaviorSubject<Bool>(value: false)
  private let isValidNicknameSubject        = BehaviorSubject<Bool>(value: false)
  private let isValidAuthCodeSubject        = BehaviorSubject<Bool>(value: false)
  
  private let isRegisterButtonEnabledSubject = BehaviorSubject<Bool>(value: false)
  private let errorMessageRelay              = PublishRelay<HaramError>()
  private let successMessageRelay            = PublishRelay<HaramError>()
  private let signupSuccessMessageRelay      = PublishRelay<String>()
  private let isLoadingSubject               = PublishSubject<Bool>()
  private let isSuccessRequestAuthCodeSubject = BehaviorSubject<Bool>(value: false)
  
  init(authRepository: AuthRepository = AuthRepositoryImpl()) {
    self.authRepository = authRepository
  }
  
  func registerMember(id: String, email: String, password: String, nickname: String, authCode: String) {
    
    isLoadingSubject.onNext(true)
    
    authRepository.signupUser(
      request: .init(
        userID: id,
        email: email + "@bible.ac.kr",
        password: password,
        nickname: nickname,
        emailAuthCode: authCode
      )
    )
    .subscribe(with: self) { owner, result in
      switch result {
      case .success(_):
        owner.signupSuccessMessageRelay.accept("회원가입 성공")
      case .failure(let error):
        owner.errorMessageRelay.accept(error)
      }
      owner.isLoadingSubject.onNext(false)
    }
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

extension RegisterViewModel: RegisterViewModelType {
  func checkRepasswordIsEqual(password: String, repassword: String) {
    
    let isValid = password == repassword
    if isValid {
      successMessageRelay.accept(.noEqualPassword)
    } else {
      errorMessageRelay.accept(.noEqualPassword)
    }
    isValidRePWDSubject.onNext(password == repassword)
  }
  
  var successMessage: RxCocoa.Signal<HaramError> {
    successMessageRelay.asSignal()
  }
  
  func checkUserIDIsValid(id: String) {
    
    // userId가 4~30자, 영어 or 숫자만 가능
    
    let isUnValid = 4 > id.count || 30 < id.count || !isValidAlphanumeric(id)
    isValidIDSubject.onNext(!isUnValid)
    LogHelper.log("아이디 유효안함 \(isUnValid)", level: .debug)
    if isUnValid {
      errorMessageRelay.accept(.unvalidUserIDFormat)
    } else {
      successMessageRelay.accept(.unvalidUserIDFormat)
    }
  }
  
  func checkPasswordIsValid(password: String) {
    
    let isUnValid = !isValidPassword(password)
    LogHelper.log("비번 유효안함 \(isUnValid)", level: .debug)
    isValidPWDSubject.onNext(!isUnValid)
    if isUnValid {
      errorMessageRelay.accept(.unvalidpasswordFormat)
    } else {
      successMessageRelay.accept(.unvalidpasswordFormat)
    }
  }
  
  func checkEmailIsValid(email: String) {
    let emailRegex = #"^[a-zA-Z0-9._%+-]+@bible\.ac\.kr$"#
    
    // NSPredicate를 사용하여 정규표현식과 매칭하는지 확인
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
    
    // 입력된 이메일이 유효한지 확인
    let isValid = emailPredicate.evaluate(with: email + "@bible.ac.kr")
    isValidEmailSubject.onNext(isValid)
    LogHelper.log("이메일 유효 \(isValid)", level: .debug)
    
    if isValid {
      successMessageRelay.accept(.unvalidEmailFormat)
    } else {
      errorMessageRelay.accept(.unvalidEmailFormat)
    }
  }
  
  func checkAuthCodeIsValid(authCode: String) {
    
    let isUnValid = authCode.count != 6
    isValidAuthCodeSubject.onNext(!isUnValid)
    LogHelper.log("인증코드 유효안함 \(isUnValid)", level: .debug)
    if isUnValid {
      errorMessageRelay.accept(.unvalidAuthCode)
    } else {
      successMessageRelay.accept(.unvalidAuthCode)
    }
    
  }
  
  func checkNicknameIsValid(nickname: String) {
    
    let isUnValid = 0..<2 ~= nickname.count || 15 < nickname.count || !isValidKoreanAlphanumeric(nickname)
    isValidNicknameSubject.onNext(!isUnValid)
    LogHelper.log("닉네임 유효안함 \(isUnValid)", level: .debug)
    if isUnValid {
      errorMessageRelay.accept(.unvalidNicknameFormat)
    } else {
      successMessageRelay.accept(.unvalidNicknameFormat)
    }
  }
  
  var isSendAuthCodeButtonEnabled: RxCocoa.Driver<Bool> {
    isValidEmailSubject
      .distinctUntilChanged()
      .asDriver(onErrorDriveWith: .empty())
  }
  
  var isSuccessRequestAuthCode: RxCocoa.Driver<Bool> {
    isSuccessRequestAuthCodeSubject.asDriver(onErrorJustReturn: false)
  }
  
  func requestEmailAuthCode(email: String) {
    
    authRepository.requestEmailAuthCode(userEmail: email + "@bible.ac.kr")
      .subscribe(with: self) { owner, _ in
        owner.isSuccessRequestAuthCodeSubject.onNext(true)
      }
      .disposed(by: disposeBag)
  }
  
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.asSignal()
  }
  
  var isRegisterButtonEnabled: RxCocoa.Driver<Bool> {
    Observable.combineLatest(
      isValidIDSubject,
      isValidPWDSubject,
      isValidEmailSubject,
      isValidNicknameSubject,
      isValidAuthCodeSubject,
      isValidRePWDSubject
    )
    .map { $0.0 && $0.1 && $0.2 && $0.3 && $0.4 && $0.5 }
    .distinctUntilChanged()
    .asDriver(onErrorJustReturn: false)
  }
  
  var signupSuccessMessage: Signal<String> {
    signupSuccessMessageRelay.asSignal()
  }
  
  var isLoading: Driver<Bool> {
    isLoadingSubject.asDriver(onErrorJustReturn: false)
  }
}
