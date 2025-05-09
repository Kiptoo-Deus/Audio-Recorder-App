//
//  AudioRecorderViewModel.swift
//  AudioRecorder
//
//  Created by Joel on 09/05/2025.
//

import Foundation
import AVFoundation

class AudioRecorderViewModel: ObservableObject {
    private let audioEngine = AVAudioEngine()
    @Published var audioSamples: [Float] = []
    @Published var normalizedSamples: [Float] = [] // For visualization
    @Published var isRecording = false
    @Published var errorMessage: String?
    private let maxSampleCount = 1000 // Limit for visualization
    private let downsampleFactor = 10 // Take every 10th sample for rendering
    
    init() {
        configureAudioSession()
    }
    
    func toggleRecording() {
        if isRecording {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioSamples.removeAll()
            normalizedSamples.removeAll()
            isRecording = false
            do {
                try AVAudioSession.sharedInstance().setActive(false)
            } catch {
                errorMessage = "Failed to deactivate audio session: \(error)"
            }
        } else {
            setupAudioEngine()
        }
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default, options: [])
            try audioSession.setActive(true)
            print("Audio session configured: \(audioSession.sampleRate) Hz")
        } catch {
            errorMessage = "Failed to configure audio session: \(error)"
            print(errorMessage!)
        }
    }
    
    private func setupAudioEngine() {
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        
        // Validate format
        guard format.sampleRate > 0, format.channelCount > 0 else {
            errorMessage = "Invalid audio format: sampleRate=\(format.sampleRate), channels=\(format.channelCount)"
            print(errorMessage!)
            isRecording = false
            return
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, time in
            guard let channelData = buffer.floatChannelData else { return }
            let frameLength = Int(buffer.frameLength)
            let samples = Array(UnsafeBufferPointer(start: channelData[0], count: frameLength))
            DispatchQueue.main.async {
                self.audioSamples.append(contentsOf: samples)
                if self.audioSamples.count > self.maxSampleCount {
                    self.audioSamples.removeFirst(self.audioSamples.count - self.maxSampleCount)
                }
                
                // Normalize and downsample for visualization
                let normalized = samples.map { abs($0) / 2.0 } // Scale to 0-0.5 for visibility
                let downsampled = stride(from: 0, to: normalized.count, by: self.downsampleFactor).map { normalized[$0] }
                self.normalizedSamples.append(contentsOf: downsampled)
                if self.normalizedSamples.count > self.maxSampleCount / self.downsampleFactor {
                    self.normalizedSamples.removeFirst(self.normalizedSamples.count - (self.maxSampleCount / self.downsampleFactor))
                }
                print("Captured \(frameLength) samples at \(buffer.format.sampleRate) Hz")
            }
        }
        
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            errorMessage = "Audio engine failed to start: \(error)"
            print(errorMessage!)
            isRecording = false
        }
    }
}
