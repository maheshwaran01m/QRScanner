//
//  CameraView.swift
//  QRScanner
//
//  Created by MAHESHWARAN on 28/10/23.
//

import SwiftUI
import AVKit

struct CameraView: UIViewRepresentable {
  
  var frameSize: CGSize
  
  @Binding var session: AVCaptureSession
  
  init(frameSize: CGSize, session: Binding<AVCaptureSession>) {
    _session = session
    self.frameSize = frameSize
  }
  
  func makeUIView(context: Context) -> UIView {
    let view = UIViewType(frame: .init(origin: .zero, size: frameSize))
    view.backgroundColor = .clear
    
    let cameraLayer = AVCaptureVideoPreviewLayer(session: session)
    cameraLayer.frame = .init(origin: .zero, size: frameSize)
    cameraLayer.videoGravity = .resizeAspectFill
    cameraLayer.masksToBounds = true
    view.layer.addSublayer(cameraLayer)
    
    return view
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {}
}
