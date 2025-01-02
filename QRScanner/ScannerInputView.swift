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
    CameraViewController(frameSize, cameraLayer: cameraLayer)
  }
  
  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
  
  private class CameraViewController: UIViewController {
    
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
      setupCameraView()
      configurePinchGesture()
    }
    
    private func setupCameraView() {
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
    
    // MARK: - Pinch Gesture
    
    private func configurePinchGesture() {
      let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                  action: #selector(handlePinch(_:)))
      view.addGestureRecognizer(pinchGesture)
    }
    
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
      guard let device = AVCaptureDevice.default(for: .video) else { return }
      do {
        try device.lockForConfiguration()
        let maxZoomFactor = device.activeFormat.videoMaxZoomFactor
        let pinchVelocityDividerFactor: CGFloat = 10.0
        let desiredZoomFactor = device.videoZoomFactor + atan2(gesture.velocity, pinchVelocityDividerFactor)
        device.videoZoomFactor = max(1.0, min(desiredZoomFactor, maxZoomFactor))
        device.unlockForConfiguration()
      } catch {
        debugPrint("Error locking configuration while scanning.")
      }
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
