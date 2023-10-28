//
//  ContentView.swift
//  QRScanner
//
//  Created by MAHESHWARAN on 28/10/23.
//

import SwiftUI
import AVKit

struct ContentView: View {
  
  @Environment(\.dismiss) private var dismiss
  @State private var isScanning = false
  @State private var session = AVCaptureSession()
  @State private var qrOutput = AVCaptureMetadataOutput()
  
  @State private var errorMessage: String?
  @StateObject private var qrOutputDelegate = QRScannerDelegate()
  @State private var outpuQRCode: String?
  
  var body: some View {
    mainView
  }
  
  private var mainView: some View {
    VStack(spacing: 8) {
      closeButton
      placeholderTextView
      qrCodeTextView
      
      scannerView
      scanButton
    }
    .padding(.horizontal, 10)
    .frame(maxWidth: .infinity, alignment: .topLeading)
    .alert("Settings", isPresented: errorBinding) {
      Button("Cancel", action: {})
      
      if let url = URL(string: UIApplication.openSettingsURLString) {
        Link("Open", destination: url)
      }
    } message: {
      Text(errorMessage ?? "")
    }
    .onAppear {
      checkForCameraPermissions()
    }
    .onChange(of: qrOutputDelegate.scannedCode) {
      guard let value = $0 else { return }
      session.stopRunning()
      resetAnimationView()
      qrOutputDelegate.scannedCode = .none
      outpuQRCode = value
    }
  }
  
  private var closeButton: some View {
    Button {
      dismiss()
    } label: {
      Image(systemName: "xmark")
        .renderingMode(.template)
        .font(.title3)
        .foregroundStyle(Color.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
  
  private var placeholderTextView: some View {
    Text("Place the QR code inside the frame")
      .font(.headline)
      .foregroundStyle(Color.primary)
  }
  
  @ViewBuilder
  private var qrCodeTextView: some View {
    if let scannedCode = outpuQRCode {
      Text(scannedCode)
        .font(.headline)
        .foregroundStyle(Color.primary)
        .padding()
        .background(Color.blue.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 25.0))
        .padding(.top, 25)
    }
  }
  
  // MARK: - Scanner View
  
  private var scannerView: some View {
    GeometryReader { proxy in
      
      ZStack {
        CameraView(frameSize: .init(width: proxy.size.width/2,
                                    height: proxy.size.width/2), session: $session)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        
        
        ForEach(0...3, id: \.self) { index in
          RoundedRectangle(cornerRadius: 8, style: .circular)
            .trim(from: 0.58, to: 0.66)
            .stroke(Color.primary,
                    style: .init(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
            .rotationEffect(.init(degrees: Double(index) * 90))
          
        }
      }
      .frame(width: proxy.size.width/2, height: proxy.size.width/2)
      .overlay(alignment: .top) { overlayScannerView(proxy) }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }
  
  private func overlayScannerView(_ proxy: GeometryProxy) -> some View {
    RoundedRectangle(cornerRadius: 25.0)
      .fill(.primary)
      .frame(height: 1)
      .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: isScanning ? 15 : -15)
      .offset(y: isScanning ? proxy.size.width/2 : 0)
      .padding(.horizontal, 5)
  }
  
  private func scanAnimationView() {
    withAnimation(.easeInOut(duration: 0.85).delay(0.2).repeatForever(autoreverses: true)) {
      isScanning = true
    }
  }
  
  private func resetAnimationView() {
    withAnimation(.easeInOut(duration: 0.85)) {
      isScanning = false
    }
  }
  
  private var scanButton: some View {
    Button {
      if !session.isRunning {
        activateCameraView()
        scanAnimationView()
      }
    } label: {
      Image(systemName: "qrcode.viewfinder")
        .font(.largeTitle)
        .foregroundStyle(Color.primary)
    }
  }
  
  // MARK: - Camera
  
  private func setupCamera() {
    do {
      guard let device = AVCaptureDevice
        .DiscoverySession(
          deviceTypes: [.builtInWideAngleCamera],
          mediaType: .video, position: .back).devices.first else {
        return
      }
      let input = try AVCaptureDeviceInput(device: device)
      
      guard session.canAddInput(input), session.canAddOutput(qrOutput) else {
        return
      }
      session.beginConfiguration()
      session.addInput(input)
      session.addOutput(qrOutput)
      
      qrOutput.metadataObjectTypes = [.qr]
      qrOutput.setMetadataObjectsDelegate(qrOutputDelegate, queue: .main)
      session.commitConfiguration()
      
      activateCameraView()
      scanAnimationView()
    } catch {
      errorMessage = error.localizedDescription
    }
  }
  
  private func activateCameraView() {
    DispatchQueue.global(qos: .background).async {
      session.startRunning()
    }
  }
  
  // MARK: - Error
  
  private var errorBinding: Binding<Bool> {
    Binding {
      errorMessage != nil
    } set: {
      if !$0 {
        errorMessage = nil
      }
    }
  }
  
  private func checkForCameraPermissions() {
    Task {
      switch AVCaptureDevice.authorizationStatus(for: .video) {
      case .authorized:
        if session.inputs.isEmpty {
          setupCamera()
        } else {
          session.startRunning()
        }
      case .notDetermined:
        if await AVCaptureDevice.requestAccess(for: .video) {
          setupCamera()
        } else {
          errorMessage = "Please provide camera access to scan QR codes"
        }
      case .denied, .restricted:
        errorMessage = "Please provide camera access to scan QR codes"
      default: break
      }
    }
  }
}

#Preview {
  ContentView()
}
