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
    @Published var normalizedSamples: [Float] = []
    @Published var isRecording = false
    @Published var errorMessage: String?
    private let maxSampleCount = 1000
    private let downsampleFactor = 10
    
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
                print(errorMessage!)
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
        
        // Log format details
        print("Input format: \(format.sampleRate) Hz, \(format.channelCount) channels")
        
        // Validate format
        guard format.sampleRate > 0, format.channelCount > 0 else {
            errorMessage = "Invalid audio format: sampleRate=\(format.sampleRate), channels=\(format.channelCount)"
            print(errorMessage!)
            isRecording = false
            return
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, time in
            guard let channelData = buffer.floatChannelData else {
                print("No channel data in buffer")
                return
            }
            let frameLength = Int(buffer.frameLength)
            let samples = Array(UnsafeBufferPointer(start: channelData[0], count: frameLength))
            print("Captured \(frameLength) samples, first sample: \(samples.first ?? 0)")
            
            DispatchQueue.main.async {
                self.audioSamples.append(contentsOf: samples)
                if self.audioSamples.count > self.maxSampleCount {
                    self.audioSamples.removeFirst(self.audioSamples.count - self.maxSampleCount)
                }
                
                // Normalize and downsample
                let normalized = samples.map { abs($0) / 2.0 }
                let downsampled = stride(from: 0, to: normalized.count, by: self.downsampleFactor).map { normalized[$0] }
                self.normalizedSamples.append(contentsOf: downsampled)
                if self.normalizedSamples.count > self.maxSampleCount / self.downsampleFactor {
                    self.normalizedSamples.removeFirst(self.normalizedSamples.count - (self.maxSampleCount / self.downsampleFactor))
                }
                print("Normalized samples: \(self.normalizedSamples.count), first: \(self.normalizedSamples.first ?? 0)")
            }
        }
        
        do {
            try audioEngine.start()
            isRecording = true
            print("Audio engine started")
        } catch {
            errorMessage = "Audio engine failed to start: \(error)"
            print(errorMessage!)
            isRecording = false
        }
    }
}
