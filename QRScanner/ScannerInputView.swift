//
//  ScannerInputView.swift
//  QRScanner
//
//  Created by MAHESHWARAN on 28/10/23.
//

import SwiftUI
import AVKit

struct ScannerInputView: UIViewControllerRepresentable {
  
  var frameSize: CGSize
  var cameraLayer: AVCaptureVideoPreviewLayer
  
  func makeUIViewController(context: Context) -> UIViewController {
    Coordinator(frameSize, cameraLayer: cameraLayer)
  }
  
  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    .init(frameSize, cameraLayer: cameraLayer)
  }
  
  class Coordinator: UIViewController {
    var frameSize: CGSize
    var cameraLayer: AVCaptureVideoPreviewLayer
    
    init(_ frameSize: CGSize, cameraLayer: AVCaptureVideoPreviewLayer) {
      self.frameSize = frameSize
      self.cameraLayer = cameraLayer
      super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      cameraLayer.frame = view.bounds
      cameraLayer.videoGravity = .resizeAspectFill
      cameraLayer.backgroundColor = UIColor.black.cgColor
      cameraLayer.masksToBounds = true
      view.layer.addSublayer(cameraLayer)
      updateOrientation()
    }
    
    override func viewWillLayoutSubviews() {
      super.viewWillLayoutSubviews()
      cameraLayer.frame = view.frame
      updateOrientation()
    }
    
    override func viewWillTransition(
      to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateOrientation()
      }
    
    func updateOrientation() {
      let orientation = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .first?.interfaceOrientation ?? .portrait
      
      cameraLayer.connection?.videoOrientation = orientation.videoOrientation
    }
  }
}

extension UIInterfaceOrientation {
  
  var videoOrientation: AVCaptureVideoOrientation {
    switch self {
    case .landscapeLeft: return .landscapeLeft
    case .landscapeRight: return .landscapeRight
    case .portrait: return .portrait
    case .portraitUpsideDown: return .portraitUpsideDown
    case .unknown: return .portrait
    @unknown default: return .portrait
    }
  }
}
