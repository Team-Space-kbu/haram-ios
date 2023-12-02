//
//  WebViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/19.
//

import UIKit

import SnapKit
import Then
import WebRTC


final class WebViewController: BaseViewController {
  
  // MARK: - UI Components
  #if arch(arm64)
  private let rtcView = RTCMTLVideoView().then {
    $0.videoContentMode = .scaleAspectFill
  }
  #else
  private let rtcView = RTCEAGLVideoView()
  #endif
  
  // MARK: - Properties For WebRTC
  private let factory = RTCPeerConnectionFactory()
  
  // 미디어 스트림 생성
  private lazy var localStream: RTCMediaStream = factory.mediaStream(withStreamId: "media").then {
    // 로컬 스트림에 트랙 추가
    $0.addVideoTrack(localVideoTrack)
    $0.addAudioTrack(localAudioTrack)
  }
  // 비디오 소스
  private lazy var videoSource :RTCVideoSource = factory.videoSource()
  // 로컬 트랙
  private lazy var localVideoTrack = factory.videoTrack(with: videoSource, trackId: "video0")
  private lazy var localAudioTrack = factory.audioTrack(withTrackId: "audio0")

  // connection constraints
  private lazy var constraints:RTCMediaConstraints = RTCMediaConstraints(
    mandatoryConstraints: nil,
    optionalConstraints: options
  )
  
  private let options:[String:String] = [
      "DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue,
      "kRTCMediaConstraintsMaxWidth":"640",
      "kRTCMediaConstraintsMaxHeight":"480",
      "kRTCMediaConstraintsMaxFrameRate":"30"
  ]
      

  // config 설정
  private let config = RTCConfiguration().then {
//    $0.iceServers = iceServers
    $0.iceTransportPolicy = .all
    $0.rtcpMuxPolicy = .negotiate
    $0.continualGatheringPolicy = .gatherContinually
    $0.bundlePolicy = .maxBundle
  }


  // connection 생성
  private lazy var peerConnection = factory.peerConnection(
    with: config,
    constraints: constraints,
    delegate: nil
  )
  
  // PeerConnection 구성을 위한 설정
  private let rtcConfig = RTCConfiguration()
  private lazy var rtcPeerConnection = factory.peerConnection(with: rtcConfig, constraints: RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil), delegate: nil)
  
  //오디오 세션 설정
  private let rtcAudioSession = RTCAudioSession.sharedInstance().then {
    $0.lockForConfiguration()
    do {
        try $0.setCategory( AVAudioSession.Category.playAndRecord.rawValue )
        try $0.setMode( AVAudioSession.Mode.voiceChat.rawValue )
    } catch let error {

    }
    $0.unlockForConfiguration()
  }
  
  override func setupStyles() {
    super.setupStyles()
    if let peerConnection = peerConnection {
      peerConnection.add(localStream)
    }
    
//    // RTCVideoSource와 RTCPeerConnectionFactory 인스턴스를 생성합니다.
//    let videoSource = RTCPeerConnectionFactory().videoSource()
//
//
//    // 카메라 비디오 트랙 설정
//    let videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
//
//    // 카메라 디바이스를 가져옵니다.
//    let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
//    guard let camera = session.devices.first else {
//      // 카메라를 찾을 수 없는 경우 처리 로직을 추가합니다.
//      return
//    }
//
//    // 카메라를 캡처합니다.
//    let format = camera.activeFormat
//    let fps = camera.activeVideoMinFrameDuration
//    do {
//      let videoDeviceInput = try AVCaptureDeviceInput(device: camera)
//      videoCapturer.captureSession.addInput(videoDeviceInput)
//      videoCapturer.startCapture(with: camera, format: format, fps: Int(fps.value))
//    } catch {
//      // 카메라 캡처를 시작할 수 없는 경우 처리 로직을 추가합니다.
//    }
//
//    // 오디오 트랙을 생성하고 오디오 소스를 인자로 전달합니다.
//    let audioSource = factory.audioSource(with: nil)
//    let audioTrack = factory.audioTrack(with: audioSource, trackId: "audioTrackId")
//    let videoTrack = factory.videoTrack(with: videoSource, trackId: "videoTrack")
//
//    // MediaStream을 생성하고 비디오 트랙과 오디오 트랙을 추가합니다.
//    let mediaStream = factory.mediaStream(withStreamId: "mediaStreamId")
//
//    mediaStream.addVideoTrack(videoTrack)
//    mediaStream.addAudioTrack(audioTrack)
//
//
//    // PeerConnection에 미디어 스트림 추가
//    guard let rtcPeerConnection = rtcPeerConnection else { return }
//    rtcPeerConnection.add(mediaStream)
//
//    // 시그널링 및 ICE 후보자 교환 등의 작업은 해당 프로토콜이나 시그널링 서버와 상호작용하는 코드로 구현되어야 합니다.
//    // 이를 통해 PeerConnection 간의 연결 설정과 네트워크 통신 경로를 설정할 수 있습니다.
//    // 시그널링 및 ICE 후보자 교환 과정은 해당 프로토콜이나 시그널링 서버의 요구에 따라 달라집니다.
//
//
//    let offerConstraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
//    rtcPeerConnection.offer(for: offerConstraints) { [weak self] localSDP, error in
//      if let error = error {
//        // Offer 생성 중 오류 발생
//        print("Offer 생성 오류: \(error.localizedDescription)")
//        return
//      }
//
//      guard let localSDP = localSDP,
//            let self = self else { return }
//      // Offer 생성 성공
//      // 로컬 SDP 설정
//      rtcPeerConnection.setLocalDescription(localSDP) { error in
//        if let error = error {
//          print("로컬 SDP 설정 오류: \(error.localizedDescription)")
//          return
//        }
//
//        // 로컬 SDP 교환을 위한 코드 작성
//        // 시그널링 서버나 프로토콜에 따라 해당 코드를 작성해야 합니다.
//        // 예시로서 교환된 로컬 SDP를 상대방에게 전달하는 과정을 포함합니다.
//        // 이 과정은 시그널링 서버나 프로토콜의 규격에 따라 구현되어야 합니다.
//        // 상대방으로부터 수신한 원격 SDP를 이후 단계에서 처리해야 합니다.
//        self.sendLocalSDPToRemote(localSDP)
//      }
//    }
//
//    let localStream = factory.mediaStream(withStreamId: "localStream")
//
//    localStream.addAudioTrack(audioTrack)
//    localStream.addVideoTrack(videoTrack)
//    rtcPeerConnection.add(localStream)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(rtcView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    rtcView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
  
  func sendLocalSDPToRemote(_ localSDP: RTCSessionDescription) {
    guard let jsonString = createSDPJSONString(localSDP) else {
      print("로컬 SDP 변환 실패")
      return
    }
    
    // WebSocket을 통해 상대방에게 SDP 전송
    let data = jsonString.data(using: .utf8)
    //      webSocket.send(data)
  }
  
  func createSDPJSONString(_ localSDP: RTCSessionDescription) -> String? {
    let sdpType: String
    
    switch localSDP.type {
    case .offer:
      sdpType = "offer"
    case .answer:
      sdpType = "answer"
    default:
      return nil
    }
    
    let sdpDictionary: [String: String] = [
      "sdp": localSDP.sdp,
      "type": sdpType
    ]
    
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: sdpDictionary, options: [])
      return String(data: jsonData, encoding: .utf8)
    } catch {
      print("JSON 데이터 생성 실패: \(error.localizedDescription)")
      return nil
    }
  }
  
  // 원격 SDP 수신 시 처리
  func didReceiveRemoteSDP(_ remoteSDP: RTCSessionDescription) {
    guard let rtcPeerConnection = rtcPeerConnection else { return }
    rtcPeerConnection.setRemoteDescription(remoteSDP) { [weak self] error in
      guard let self = self else { return }
      if let error = error {
        print("원격 SDP 설정 오류: \(error.localizedDescription)")
        return
      }
      
      if remoteSDP.type == .offer {
        // Answer 생성
        self.createAnswer()
      }
    }
  }
  
  // Answer 생성
  func createAnswer() {
    guard let rtcPeerConnection = rtcPeerConnection else { return }
    let answerConstraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
    rtcPeerConnection.answer(for: answerConstraints) { localSDP, error in
      guard let localSDP = localSDP else { return }
      if let error = error {
        print("Answer 생성 오류: \(error.localizedDescription)")
        return
      }
      
      rtcPeerConnection.setLocalDescription(localSDP) { error in
        if let error = error {
          print("로컬 SDP 설정 오류: \(error.localizedDescription)")
          return
        }
        
        // 로컬 SDP를 상대방에게 전송하는 함수 호출
        self.sendLocalSDPToRemote(localSDP)
      }
    }
  }
}
