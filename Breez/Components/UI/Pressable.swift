import SwiftUI

struct SelectablePressable: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var cornerRadius: CGFloat = 22
    var height: CGFloat = 60
    
    private var borderColor: Color {
        isSelected ? Color(hex: "4E4E4E") : Color.stroke
    }
    
    private var backgroundColor: Color {
        isSelected ? Color.text.opacity(0.02) : Color.clear
    }
    
    var body: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
            action()
        } label: {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color.text)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(Color.block)
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: 2.5)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
    }
}

// Convenience initializer for binding
struct SelectablePressable_Binding: View {
    let title: String
    @Binding var isSelected: Bool
    
    var body: some View {
        SelectablePressable(title: title, isSelected: isSelected) {
            isSelected.toggle()
        }
    }
}

// Previews removed for production build stability
