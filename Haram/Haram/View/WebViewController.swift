////
////  WebViewController.swift
////  Haram
////
////  Created by 이건준 on 2023/04/19.
////
//
//import UIKit
//import WebRTC
//import AVFoundation
//
//final class WebViewController: UIViewController {
//  
//  // RTCVideoTrack to hold the remote video stream
//  var remoteVideoTrack: RTCVideoTrack?
//  
//  // RTCVideoView to render the remote video stream
//  let remoteVideoView = RTCVideoView()
//  
//  override func viewDidLoad() {
//    super.viewDidLoad()
//    
//    // Create a new RTCVideoTrack instance to hold the remote video stream
//    let remoteVideoTrack = self.peerConnection.transceivers.first { $0.mediaType == .video }?.receiver.track as? RTCVideoTrack
//    self.remoteVideoTrack = remoteVideoTrack
//    self.remoteVideoTrack?.add(self)
//    
//    // Configure the remote video view
//    self.remoteVideoView.frame = self.view.bounds
//    self.remoteVideoView.contentMode = .scaleAspectFill
//    self.view.addSubview(self.remoteVideoView)
//  }
//}
//
//extension WebViewController: RTCVideoRenderer {
//  func setSize(_ size: CGSize) {
//    
//  }
//  
//  // Implement RTCVideoRenderer methods
//  func renderFrame(_ frame: RTCVideoFrame?) {
//    guard let remoteVideoTrack = self.remoteVideoTrack else { return }
//    
//    // Render the video frame using the remote video view
//    remoteVideoTrack.renderFrame(frame)
//  }
//}
