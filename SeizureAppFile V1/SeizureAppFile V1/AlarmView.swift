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
    
    var body: some View {
        
        ZStack{
            Color(red: 0.85, green: 0.93, blue: 1.0)
                .ignoresSafeArea()
            
            NavigationStack{
                ZStack{
                    Color(red: 0.85, green: 0.93, blue: 1.0)
                        .ignoresSafeArea()
                    
                    Text("")
                        .navigationTitle("Alarm Settings")
                        .toolbar{
                            ToolbarItem(placement: .topBarLeading) {
                                Button("Back", systemImage: "arrow.left", action: {})
                                    .labelStyle(.iconOnly)
                            }
                        }
                }
            }
            
            VStack{
                VStack{
                    Text("Volume \(Int(volume))%")
                    HStack{
                        decreaseVol
                        Slider(value: $volume, in: range, step: step)
                        increaseVol
                    }
                    .padding()
                }
                .position(x:200,y:200)
                
                VStack{
                    Text("Brightness \(Int(brightness))%")
                    HStack{
                        decreaseBtn
                        Slider(value: $brightness, in: range, step: step)
                        increaseBtn
                    }
                    .padding()
                }
                .position(x:200,y:-50)
            }
        }
    }
}

#Preview {
    ContentView()
}

private extension ContentView{
    func increaseV() {
        guard volume < range.upperBound - step else {return}
        volume += step
    }
    func decreaseV() {
        guard volume > range.lowerBound + step else {return}
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
        guard brightness < range.upperBound - 10 else {return}
        brightness += step
    }
    func decreaseB() {
        guard brightness > range.lowerBound + 10 else {return}
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

