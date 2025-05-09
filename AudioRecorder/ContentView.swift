//
//  ContentView.swift
//  AudioRecorder
//
//  Created by Joel on 08/05/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var isRecording = false
    
    var body: some View {
        VStack {
            Spacer()
            Button(action:{
                isRecording.toggle()
            }){
                Text(isRecording ? "Stop" : "Record")
                    .font(.title)
                    .padding()
                    .background(isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }
}

         struct ContentView_Previews: PreviewProvider {
             static var previews: some View {
                 
             }
    
}

