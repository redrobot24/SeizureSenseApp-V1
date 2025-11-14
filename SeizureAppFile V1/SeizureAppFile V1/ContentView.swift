//
//  ContentView.swift
//  Seizure Sense UI
//
//  Created by Sarah Yonosh on 11/7/25.
//

import SwiftUI
import SwiftData

import SwiftUI
import Charts


struct ContentView: View {
    
    @State var showSettings = false
    @Environment(\.dismiss) var dismiss
    
    @State var seizureDetected = false

    // Animation for flashing
    @State private var flash = false
    
    var body: some View {
        
        ZStack {
            Color(red: 0.7, green: 0.9, blue: 1.0) //background color ratio can be changed
                .ignoresSafeArea()
        
        NavigationStack {
            
            VStack(spacing: 20) {
                
                Spacer()
                 //LOGO
                Image("seizure")
                    .resizable()
                    .frame(width:300, height: 300)
                    .foregroundStyle(.tint)
                
                // Buttons
                
                Button("SEIZURE DETECTED") {
                    seizureDetected.toggle()    // for testing
                }
                .font(.system(size: 36, weight: .bold))
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .background(
                    seizureDetected
                    ? (flash ? Color.red : Color.red.opacity(0.5))
                    : Color.gray.opacity(0.6)
                )
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
                .onChange(of: seizureDetected) {
                    if seizureDetected {
                        startFlashing()
                    } else {
                        stopFlashing()
                    }
                }
                
                Spacer()
                Spacer()
                
                HStack(spacing: 12) {
                    Button("ACCEPT ") {}
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.cyan)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    
                    Button("MUTE ") {}
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.4))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                    
                    Button("RAISE ") {}
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    
                }
                .padding(.horizontal)
                Spacer()
                Spacer()
                
            }
            
            .sheet(isPresented: $showSettings) {
                SettingsView()   // opens when gear button clicked
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showSettings = true // will open settings view
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 36, height: 36) // icon area
                        .contentShape(Rectangle())    // whole area can be tapped
                }
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white)
                        .frame(width: 56, height: 56) // size of the rounded square
                )
                .buttonStyle(RoundedSquareToolbarButtonStyle())
                .buttonBorderShape(.roundedRectangle) // want to keep shape
                .controlSize(.regular)
            }
        }
        }
        func startFlashing() {
            flash = true
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                flash.toggle()
            }
        }

        func stopFlashing() {
            flash = false
        }
    }
    
    // trying to make the corner button look normal
    struct RoundedSquareToolbarButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
                .opacity(configuration.isPressed ? 0.85 : 1.0)
                .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
        }
    }
    }
    
    #Preview {
        NavigationStack{
            ContentView()
        }
    
    }
