//
//  AlarmView.swift
//  
//
//  Created by Kenzie MacGillivray on 11/13/25.
//
import SwiftUI
struct ContentView: View {
    @State private var volume: Double=0
    @State private var brightness: Double=0
    private let range: ClosedRange<Double> = 0...100
    private let step: Double = 10
    
    @State private var showVolumeInfo = false
    
   
    @State private var showBrightnessInfo = false
    
    var body: some View {
        
        ZStack {
            Color(red: 0.85, green: 0.93, blue: 1.0)
                .ignoresSafeArea()
            
            NavigationStack {
                ZStack {
                    Color(red: 0.85, green: 0.93, blue: 1.0)
                        .ignoresSafeArea()
                    
                    Text("")
                        .navigationTitle("Alarm Settings")
                }
            }
            
            VStack {
                
                
                VStack {
                    HStack(spacing: 6) {
                        Text("Volume \(Int(volume))%")
                        
                       
                        Button {
                            showVolumeInfo = true
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack {
                        decreaseVol
                        Slider(value: $volume, in: range, step: step)
                        increaseVol
                    }
                    .padding()
                }
                .position(x: 200, y: 200)
                
                
               
                VStack {
                    HStack(spacing: 6) {
                        Text("Brightness \(Int(brightness))%")
                        
                       
                        Button {
                            showBrightnessInfo = true
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack {
                        decreaseBtn
                        Slider(value: $brightness, in: range, step: step)
                        increaseBtn
                    }
                    .padding()
                }
                .position(x: 200, y: -50)
            }
        }
        
        
      
        .sheet(isPresented: $showVolumeInfo) {
            VStack(spacing: 20) {
                Text("Volume Settings")
                    .font(.title2)
                    .bold()
                
                Text("""
The volume setting controls how loud the seizure alert sound will be.
""")
                .padding()
                
                Button("Close") {
                    showVolumeInfo = false
                }
                .padding(.top, 20)
            }
            .presentationDetents([.medium])
        }
        
        
     
        .sheet(isPresented: $showBrightnessInfo) {
            VStack(spacing: 20) {
                Text("Brightness Settings")
                    .font(.title2)
                    .bold()
                
                Text("""
The brightness setting controls how bright the flashing SEIZURE alert will appear in the event of a seizure.
""")
                .padding()
                
                Button("Close") {
                    showBrightnessInfo = false
                }
                .padding(.top, 20)
            }
            .presentationDetents([.medium])
        }
    }
}
    }

#Preview {
    AlarmView()
}

private extension ContentView{
    func increaseV() {
        guard volume <= range.upperBound - step else {return}
        volume += step
    }
    func decreaseV() {
        guard volume >= range.lowerBound + step else {return}
        volume -= step
    }
}

private extension ContentView{
    var increaseVol: some View {
        Button {
            withAnimation {
                increaseV()
            }
        } label: {
            Image(systemName: "plus")
        }
    }
    var decreaseVol: some View {
        Button {
            withAnimation {
                decreaseV()
            }
        } label: {
            Image(systemName: "minus")
        }
    }
}

private extension ContentView{
    func increaseB() {
        guard brightness <= range.upperBound - step else {return}
        brightness += step
    }
    func decreaseB() {
        guard brightness >= range.lowerBound + step else {return}
        brightness -= step
    }
}

private extension ContentView{
    var increaseBtn: some View {
        Button {
            withAnimation {
                increaseB()
            }
        } label: {
            Image(systemName: "plus")
        }
    }
    var decreaseBtn: some View {
        Button {
            withAnimation {
                decreaseB()
            }
        } label: {
            Image(systemName: "minus")
        }
    }
}
