import SwiftUI
import SwiftData

struct LoadingView: View {
    
    @EnvironmentObject var settings: AppSettings
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Adaptive background gradient
            LinearGradient(
                gradient: Gradient(colors: backgroundColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Image("seizure")
                    .resizable()
                    .frame(width: 500, height: 500)
                    .foregroundStyle(.tint)
                
                ZStack {
                    HeartbeatShape()
                        .trim(from: 0, to: animate ? 1 : 0)
                        .stroke(heartbeatColor, lineWidth: 5)
                        .animation(
                            .linear(duration: 1.5).repeatForever(autoreverses: false),
                            value: animate
                        )
                }
                .frame(width: 250, height: 100)
                .background(Color.clear)
                .onAppear { animate = true }
            }
        }
        .preferredColorScheme(settings.theme == .light ? .light : .dark)
    }
    
    // MARK: - Dynamic Colors
    
    private var backgroundColors: [Color] {
        switch settings.theme {
        case .light:
            return [Color(red: 0.7, green: 0.9, blue: 1.0), Color(red: 0.7, green: 1.0, blue: 0.7)]
        case .dark:
            return [Color(.systemGray6), Color(.systemGray4)]
        }
    }
    
    private var heartbeatColor: Color {
        switch settings.theme {
        case .light: return .black
        case .dark: return .white
        }
    }
}

struct HeartbeatShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midY = rect.midY
        let width = rect.width
       
        path.move(to: CGPoint(x: 0, y: midY))
        path.addLine(to: CGPoint(x: width * 0.2, y: midY))
        path.addLine(to: CGPoint(x: width * 0.25, y: midY - 30))
        path.addLine(to: CGPoint(x: width * 0.3, y: midY + 40))
        path.addLine(to: CGPoint(x: width * 0.35, y: midY))
        path.addLine(to: CGPoint(x: width * 0.6, y: midY))
        path.addLine(to: CGPoint(x: width * 0.65, y: midY - 25))
        path.addLine(to: CGPoint(x: width * 0.7, y: midY))
        path.addLine(to: CGPoint(x: width, y: midY))
       
        return path
    }
}

#Preview {
    LoadingView()
        .environmentObject(AppSettings())
}
