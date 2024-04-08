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
  
  var registerID: AnyObserver<String> { get }
  var registerPassword: AnyObserver<String> { get }
  var registerRePassword: AnyObserver<String> { get }
  var registerNickname: AnyObserver<String> { get }
  func registerMember(id: String, email: String, password: String, nickname: String, authCode: String)
  func checkUserIDIsValid(id: String)
  func checkPasswordIsValid(password: String)
  func checkNicknameIsValid(nickname: String)
  func checkRepasswordIsEqual(password: String, repassword: String)
  
  var isRegisterButtonEnabled: Driver<Bool> { get }
  var errorMessage: Signal<HaramError> { get }
  var successMessage: Signal<HaramError> { get }
  var signupSuccessMessage: Signal<String> { get }
  var isLoading: Driver<Bool> { get }
}

final class RegisterViewModel {
  private let disposeBag = DisposeBag()
  private let authRepository: AuthRepository
  
  private let isRegisterButtonEnabledSubject = BehaviorSubject<Bool>(value: false)
  private let errorMessageRelay              = PublishRelay<HaramError>()
  private let successMessageRelay            = PublishRelay<HaramError>()
  private let signupSuccessMessageRelay      = PublishRelay<String>()
  private let isLoadingSubject               = PublishSubject<Bool>()
  private let isSuccessRequestAuthCodeSubject = BehaviorSubject<Bool>(value: false)
  private let registerIDSubject            = BehaviorSubject<String>(value: "")
  private let registerPasswordSubject            = BehaviorSubject<String>(value: "")
  private let registerNicknameSubject            = BehaviorSubject<String>(value: "")
  private let registerRepasswordSubject            = BehaviorSubject<String>(value: "")
  private let registerAuthcodeSubject            = BehaviorSubject<String>(value: "")
  
  init(authRepository: AuthRepository = AuthRepositoryImpl()) {
    self.authRepository = authRepository
  }
  
  func registerMember(id: String, email: String, password: String, nickname: String, authCode: String) {
    
    isLoadingSubject.onNext(true)
    // TODO: - 회원가입 시 약관정책에 대한 정보 반환
    authRepository.signupUser(
      request: .init(
        userID: id,
        email: email + "@bible.ac.kr",
        password: password,
        nickname: nickname,
        emailAuthCode: authCode, 
        userTermsRequests: UserManager.shared.userTermsRequests!
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
  var registerID: RxSwift.AnyObserver<String> {
    registerIDSubject.asObserver()
  }
  
  var registerPassword: RxSwift.AnyObserver<String> {
    registerPasswordSubject.asObserver()
  }
  
  var registerRePassword: RxSwift.AnyObserver<String> {
    registerRepasswordSubject.asObserver()
  }
  
  var registerNickname: RxSwift.AnyObserver<String> {
    registerNicknameSubject.asObserver()
  }
  
  func checkRepasswordIsEqual(password: String, repassword: String) {
    
    let isValid = password == repassword
    if isValid {
      successMessageRelay.accept(.noEqualPassword)
    } else {
      errorMessageRelay.accept(.noEqualPassword)
    }
  }
  
  var successMessage: RxCocoa.Signal<HaramError> {
    successMessageRelay.asSignal()
  }
  
  func checkUserIDIsValid(id: String) {
    
    // userId가 4~30자, 영어 or 숫자만 가능
    
    let isUnValid = 4 > id.count || 30 < id.count || !isValidAlphanumeric(id)
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
    if isUnValid {
      errorMessageRelay.accept(.unvalidpasswordFormat)
    } else {
      successMessageRelay.accept(.unvalidpasswordFormat)
    }
  }
  
  func checkNicknameIsValid(nickname: String) {
    
    let isUnValid = 0..<2 ~= nickname.count || 15 < nickname.count || !isValidKoreanAlphanumeric(nickname)

    LogHelper.log("닉네임 유효안함 \(isUnValid)", level: .debug)
    if isUnValid {
      errorMessageRelay.accept(.unvalidNicknameFormat)
    } else {
      successMessageRelay.accept(.unvalidNicknameFormat)
    }
  }
  
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.asSignal()
  }
  
  var isRegisterButtonEnabled: RxCocoa.Driver<Bool> {
    Observable.combineLatest(
      registerIDSubject,
      registerNicknameSubject,
      registerPasswordSubject,
      registerRepasswordSubject
    )
    .withUnretained(self)
    .map { owner, result in
      let (id, nickname, password, repassword) = result
      
      let isIDUnValid = 4 > id.count || 30 < id.count || !owner.isValidAlphanumeric(id)
      let isPWDUnValid = !owner.isValidPassword(password)
      let isNicknameUnValid = 0..<2 ~= nickname.count || 15 < nickname.count || !owner.isValidKoreanAlphanumeric(nickname)
      
      return !isIDUnValid && !isPWDUnValid && !isNicknameUnValid && password == repassword
    }
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
