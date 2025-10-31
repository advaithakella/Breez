import SwiftUI
import UIKit

struct AgePickerView: View {
    @Binding var selectedAge: Int
    @State private var age: Int = 25
    
    var body: some View {
        GeometryReader { gp in
            let circleSize: CGFloat = 205
            let startAngleDeg: Double = -90 // start at top (12 o'clock position)
            
            ZStack {
                // Circular wheel centered vertically at 40%
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 20)
                        .frame(width: circleSize, height: circleSize)
                    
                    let p = CGFloat(min(1.0, max(0.0, Double(age - 13) / 67.0))) // Age range 13-80
                    Circle()
                        .trim(from: 0, to: p)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .rotationEffect(.degrees(startAngleDeg))
                        .frame(width: circleSize, height: circleSize)
                        .shadow(color: Color.white.opacity(0.3), radius: 4, x: 0, y: 0)
                    
                    Text("\(age) y/o")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                .frame(width: circleSize, height: circleSize)
                .position(x: gp.size.width / 2, y: gp.size.height * 0.4 - 10)
                
                // Custom slider bar positioned lower on screen (~78% height)
                GeometryReader { sp in
                    let trackWidth: CGFloat = 280
                    let trackHeight: CGFloat = 12
                    let originX = (sp.size.width - trackWidth) / 2
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.2))
                            .frame(width: trackWidth, height: trackHeight)
                            .position(x: originX + trackWidth/2, y: trackHeight/2)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white)
                            .frame(width: CGFloat(min(1.0, Double(age - 13)/67.0)) * trackWidth, height: trackHeight)
                            .shadow(color: Color.white.opacity(0.4), radius: 3, x: 0, y: 0)
                            .position(x: originX + (CGFloat(min(1.0, Double(age - 13)/67.0)) * trackWidth)/2, y: trackHeight/2)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 30, height: 30)
                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                            .position(x: originX + CGFloat(min(1.0, Double(age - 13)/67.0)) * trackWidth, y: trackHeight/2)
                    }
                    .frame(maxWidth: .infinity, maxHeight: trackHeight, alignment: .leading)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                var x = value.location.x - originX
                                x = max(0, min(trackWidth, x))
                                let ratio = x / trackWidth
                                let newAge = Int(13 + ratio * 67) // Age range 13-80
                                
                                if newAge != age {
                                    age = newAge
                                    selectedAge = age
                                    
                                    // Haptic feedback for age change
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                                    impactFeedback.impactOccurred(intensity: 0.5)
                                }
                            }
                    )
                    .position(x: sp.size.width / 2, y: sp.size.height * 0.78)
                }
                .frame(height: gp.size.height)
            }
        }
        .onAppear {
            age = selectedAge
        }
    }
}

// Previews removed for production build stability
