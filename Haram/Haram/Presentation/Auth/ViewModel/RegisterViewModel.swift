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
  func registerMember()
  func checkUserIDIsValid()
  func checkPasswordIsValid()
  func checkEmailIsValid()
  func checkAuthCodeIsValid()
  func checkNicknameIsValid()
  
  var registerID: AnyObserver<String> { get }
  var registerEmail: AnyObserver<String> { get }
  var registerPWD: AnyObserver<String> { get }
  var registerRePWD: AnyObserver<String> { get }
  var registerNickname: AnyObserver<String> { get }
  var registerAuthCode: AnyObserver<String> { get }
  func requestEmailAuthCode()
  
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
  
  private let registerIDSubject              = BehaviorSubject<String>(value: "")
  private let registerPWDSubject             = BehaviorSubject<String>(value: "")
  private let registerRePWDSubject           = BehaviorSubject<String>(value: "")
  private let registerEmailSubject           = BehaviorSubject<String>(value: "")
  private let registerNicknameSubject        = BehaviorSubject<String>(value: "")
  private let registerAuthCodeSubject        = BehaviorSubject<String>(value: "")
  private let isRegisterButtonEnabledSubject = BehaviorSubject<Bool>(value: false)
  private let errorMessageRelay              = PublishRelay<HaramError>()
  private let successMessageRelay            = PublishRelay<HaramError>()
  private let signupSuccessMessageRelay      = PublishRelay<String>()
  private let isLoadingSubject               = PublishSubject<Bool>()
  private let isSuccessRequestAuthCodeSubject = BehaviorSubject<Bool>(value: false)
  
  init(authRepository: AuthRepository = AuthRepositoryImpl()) {
    self.authRepository = authRepository
  }
  
  func registerMember() {
    
    let tryRegisterMember = Observable.zip(
      registerIDSubject,
      registerEmailSubject,
      registerPWDSubject,
      registerRePWDSubject,
      registerNicknameSubject,
      registerAuthCodeSubject
    ) { ($0, $1, $2, $3, $4, $5) }
//      .filter { [weak self] result in
//        guard let self = self else { return false }
//        let (userID, userEmail, password, rePassword, nickName, authCode) = result
//        
//        // userId가 4~30자, 영어 or 숫자만 가능
//        if 0..<4 ~= userID.count || 30 < userID.count || !isValidAlphanumeric(userID) {
//          self.errorMessageRelay.accept(.unvalidUserIDFormat)
//          return false
//        }
//        
//        if 0..<2 ~= nickName.count || 15 < nickName.count || !isValidKoreanAlphanumeric(nickName) {
//          self.errorMessageRelay.accept(.unvalidNicknameFormat)
//          return false
//        }
//        
//        if !isValidPassword(password) {
//          self.errorMessageRelay.accept(.unvalidpasswordFormat)
//          return false
//        }
//        
//        if authCode.count != 6 {
//          self.errorMessageRelay.accept(.unvalidAuthCode)
//          return false
//        }
//        
//        // 비밀번호와 재비밀번호가 같지않다면
//        if password != rePassword {
//          self.errorMessageRelay.accept(.noEqualPassword)
//          self.isLoadingSubject.onNext(false)
//          return false
//        }
//        return true
//      }
      .withUnretained(self)
      .flatMapLatest { owner, result in
        let (id, email, password, _, nickname, authcode) = result
        return owner.authRepository.signupUser(
          request: .init(
            userID: id,
            email: email,
            password: password,
            nickname: nickname,
            emailAuthCode: authcode
          )
        )
      }
    
    tryRegisterMember
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
  var successMessage: RxCocoa.Signal<HaramError> {
    successMessageRelay.asSignal()
  }
  
  func checkUserIDIsValid() {
    
    // userId가 4~30자, 영어 or 숫자만 가능
    
    registerIDSubject
      .withUnretained(self)
      .map { 1..<4 ~= $1.count || 30 < $1.count || !$0.isValidAlphanumeric($1) }
      .subscribe(with: self) { owner, isUnValid in
        if isUnValid {
          owner.errorMessageRelay.accept(.unvalidUserIDFormat)
        } else {
          owner.successMessageRelay.accept(.unvalidUserIDFormat)
        }
      }
      .disposed(by: disposeBag)
  }
  
  func checkPasswordIsValid() {
    registerPWDSubject
      .filter { !$0.isEmpty }
      .withUnretained(self)
      .map { !$0.isValidPassword($1) }
      .subscribe(with: self) { owner, isUnValid in
        if isUnValid {
          owner.errorMessageRelay.accept(.unvalidpasswordFormat)
        }
      }
      .disposed(by: disposeBag)
  }
  
  func checkEmailIsValid() {
    
  }
  
  func checkAuthCodeIsValid() {
    registerEmailSubject
      .filter { !$0.isEmpty }
      .map { $0.count != 6 }
      .subscribe(with: self) { owner, isUnValid in
        if isUnValid {
          owner.errorMessageRelay.accept(.unvalidAuthCode)
        }
      }
      .disposed(by: disposeBag)
  }
  
  func checkNicknameIsValid() {
    registerNicknameSubject
      .filter { !$0.isEmpty }
      .withUnretained(self)
      .map { 0..<2 ~= $1.count || 15 < $1.count || !$0.isValidKoreanAlphanumeric($1) }
      .subscribe(with: self) { owner, isUnValid in
        if isUnValid {
          owner.errorMessageRelay.accept(.unvalidAuthCode)
        }
      }
      .disposed(by: disposeBag)
  }
  
  var isSendAuthCodeButtonEnabled: RxCocoa.Driver<Bool> {
    registerEmailSubject
      .map {
        let emailRegex = #"^[a-zA-Z0-9._%+-]+@bible\.ac\.kr$"#
        
        // NSPredicate를 사용하여 정규표현식과 매칭하는지 확인
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
        // 입력된 이메일이 유효한지 확인
        return emailPredicate.evaluate(with: $0 + "@bible.ac.kr")
      }
      .distinctUntilChanged()
      .asDriver(onErrorDriveWith: .empty())
  }
  
  var isSuccessRequestAuthCode: RxCocoa.Driver<Bool> {
    isSuccessRequestAuthCodeSubject.asDriver(onErrorJustReturn: false)
  }
  
  func requestEmailAuthCode() {
    
    registerEmailSubject
      .map { $0 + "@bible.ac.kr" }
      .flatMapLatest(authRepository.requestEmailAuthCode(userEmail: ))
      .subscribe(with: self) { owner, _ in
        owner.isSuccessRequestAuthCodeSubject.onNext(true)
      }
      .disposed(by: disposeBag)
  }
  
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay.asSignal()
  }
  
  var registerRePWD: RxSwift.AnyObserver<String> {
    registerRePWDSubject.asObserver()
  }
  
  var registerAuthCode: RxSwift.AnyObserver<String> {
    registerAuthCodeSubject.asObserver()
  }
  
  var isRegisterButtonEnabled: RxCocoa.Driver<Bool> {
    Observable.combineLatest(
      registerIDSubject,
      registerEmailSubject,
      registerPWDSubject,
      registerRePWDSubject,
      registerNicknameSubject,
      registerAuthCodeSubject
    ) { !$0.isEmpty && !$1.isEmpty && !$2.isEmpty && !$3.isEmpty && !$4.isEmpty && !$5.isEmpty }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)
  }
  
  var registerID: RxSwift.AnyObserver<String> {
    registerIDSubject.asObserver()
  }
  
  var registerPWD: RxSwift.AnyObserver<String> {
    registerPWDSubject.asObserver()
  }
  
  var registerNickname: AnyObserver<String> {
    registerNicknameSubject.asObserver()
  }
  
  var registerEmail: RxSwift.AnyObserver<String> {
    registerEmailSubject.asObserver()
  }
  
  var signupSuccessMessage: Signal<String> {
    signupSuccessMessageRelay.asSignal()
  }
  
  var isLoading: Driver<Bool> {
    isLoadingSubject.asDriver(onErrorJustReturn: false)
  }
}
