//
//  ScannerInputView.swift
//  QRScanner
//
//  Created by MAHESHWARAN on 28/10/23.
//

import SwiftUI
import AVKit

struct ScannerInputView: UIViewRepresentable {
  
  var frameSize: CGSize
  var cameraLayer: AVCaptureVideoPreviewLayer
  
  init(frameSize: CGSize, cameraLayer: AVCaptureVideoPreviewLayer) {
    self.cameraLayer = cameraLayer
    self.frameSize = frameSize
  }
  
  func makeUIView(context: Context) -> UIView {
    let view = UIViewType(frame: .init(origin: .zero, size: frameSize))
    view.backgroundColor = .clear
    
    cameraLayer.frame = view.layer.bounds
    cameraLayer.videoGravity = .resizeAspectFill
    cameraLayer.backgroundColor = UIColor.black.cgColor
    cameraLayer.masksToBounds = true
    view.layer.addSublayer(cameraLayer)
    
    return view
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {}
}
