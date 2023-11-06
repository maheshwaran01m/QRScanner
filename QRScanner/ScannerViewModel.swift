//
//  ScannerViewModel.swift
//  QRScanner
//
//  Created by MAHESHWARAN on 28/10/23.
//

import SwiftUI
import AVKit

class ScannerViewModel: NSObject, ObservableObject {
  
  var session: AVCaptureSession?
  var output = AVCaptureMetadataOutput()
  var previewLayer: AVCaptureVideoPreviewLayer?
  
  @Published var scannedCode: String?
  @Published var showCameraAlert = false
  
  override init() {
    super.init()
    setupSession()
  }
  
  private func setupSession() {
    guard session == nil,
          let device = AVCaptureDevice.default(
            .builtInWideAngleCamera, for: .video, position: .back) else {
      return
    }
    do {
      let input = try AVCaptureDeviceInput(device: device)
      let session = AVCaptureSession()
      
      guard session.canAddInput(input), session.canAddOutput(output) else {
        return
      }
      session.beginConfiguration()
      session.addInput(input)
      session.addOutput(output)
      
      output.metadataObjectTypes = [
        .qr, .ean8, .ean13, .pdf417, .upce,
        .code93, .code128, .code39, .aztec,
        .itf14, .dataMatrix
      ]
      output.setMetadataObjectsDelegate(self, queue: .main)
      output.connection(with: .video)?.preferredVideoStabilizationMode = .standard
      session.commitConfiguration()
      previewLayer = .init(session: session)
      
      self.session = session
      startSession()
    } catch {
      debugPrint("Error while capturing video input, error: \(error.localizedDescription)")
    }
  }
  
  func startSession() {
    guard !(session?.isRunning ?? false) else { return }
    DispatchQueue.global(qos: .background).async { [weak self] in
      self?.session?.startRunning()
    }
    scannedCode = nil
  }
  
  func checkAccessForCamera() {
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    
    switch status {
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { [weak self] isEnabled in
        DispatchQueue.main.async {
          if !isEnabled {
            self?.showCameraAlert = true
          }
        }
      }
    case .restricted, .denied:
      showCameraAlert = true
      debugPrint("You have explicitly denied permission for media capture")
    default: break
    }
  }
  
  func stopRunning() {
    guard session?.isRunning ?? false else { return }
    session?.stopRunning()
  }
  
  func updateOutputRectOfInterest(_ rect: CGRect) {
    guard let previewLayer else { return }
    output.rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: rect)
  }
}

extension ScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
  
  func metadataOutput(_ output: AVCaptureMetadataOutput,
                      didOutput metadataObjects: [AVMetadataObject],
                      from connection: AVCaptureConnection) {
    guard let metaData = metadataObjects.first,
          let readableObject = metaData as? AVMetadataMachineReadableCodeObject else {
      return
    }
    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    scannedCode = readableObject.stringValue
    stopRunning()
  }
}
