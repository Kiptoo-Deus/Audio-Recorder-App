//
//  ContentView.swift
//  AudioRecorder
//
//  Created by Joel on 08/05/2025.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var viewModel = AudioRecorderViewModel()
    @State private var showPermissionAlert = false
    
    var body: some View {
        VStack {
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                    .multilineTextAlignment(.center)
            } else {
                WaveformView(samples: viewModel.normalizedSamples)
                    .padding()
            }
            Spacer()
            Button(action: {
                viewModel.toggleRecording()
            }) {
                Text(viewModel.isRecording ? "Stop" : "Record")
                    .font(.title)
                    .padding()
                    .background(viewModel.isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .disabled(!AVAudioSession.sharedInstance().recordPermission.isAuthorized)
            .alert(isPresented: $showPermissionAlert) {
                Alert(
                    title: Text("Microphone Access Denied"),
                    message: Text("Please enable microphone access in Settings to record audio."),
                    primaryButton: .default(Text("Settings"), action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }),
                    secondaryButton: .cancel()
                )
            }
        }
        .onAppear {
            requestMicrophonePermission()
        }
    }
    
    private func requestMicrophonePermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                DispatchQueue.main.async {
                    if !granted {
                        self.showPermissionAlert = true
                    }
                }
            }
        case .denied:
            showPermissionAlert = true
        case .granted:
            break
        @unknown default:
            break
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension AVAudioSession.RecordPermission {
    var isAuthorized: Bool {
        return self == .granted
    }
}
