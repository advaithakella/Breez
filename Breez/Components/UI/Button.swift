import SwiftUI
import UIKit

struct AppButton: View {
    let title: String
    var action: () -> Void
    var style: ButtonStyle = .primary
    var cornerRadius: CGFloat = 18
    var fontWeight: Font.Weight = .bold
    var fontSize: CGFloat = 18
    var height: CGFloat = 56
    var isDisabled: Bool = false

    var body: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .soft)
            impact.impactOccurred()
            action()
        } label: {
            Text(title)
                .font(.system(size: fontSize, weight: fontWeight, design: .rounded))
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(backgroundView)
                .contentShape(RoundedRectangle(cornerRadius: actualCornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 0)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1)
        .frame(width: 370)
    }
    
    // MARK: - Style Properties
    private var textColor: Color {
        return .white
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: actualCornerRadius, style: .continuous)
            .fill(backgroundColor)
            .overlay(
                Group {
                    if style == .secondary {
                        RoundedRectangle(cornerRadius: actualCornerRadius, style: .continuous)
                            .stroke(borderColor, lineWidth: 2)
                    }
                }
            )
    }
    
    private var backgroundColor: Color {
        return Color(hex: "7DC7FF")
    }
    
    private var borderColor: Color {
        Color(hex: "D0CAB6")
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return Color.white.opacity(0.25)
        case .secondary:
            return .clear
        case .card:
            return Color.black.opacity(0.25)
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .primary:
            return 4
        case .secondary:
            return 0
        case .card:
            return 4
        }
    }
    
    private var actualCornerRadius: CGFloat {
        switch style {
        case .primary:
            return cornerRadius
        case .secondary:
            return cornerRadius
        case .card:
            return 12
        }
    }
}

enum ButtonStyle {
    case primary    // White background, black text, white shadow
    case secondary  // Dark background, white text, gray border
    case card       // Dark card background, white text, black shadow
}

struct CardButton: View {
    let title: String
    var action: () -> Void
    var backgroundColor: Color = .primary
    var foregroundColor: Color = .black
    var cornerRadius: CGFloat = 20
    var fontWeight: Font.Weight = .bold
    var fontSize: CGFloat = 18
    var height: CGFloat = 50 // changed from 56
    var isDisabled: Bool = false
    var style: ButtonStyle = .primary

    var body: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            action()
        } label: {
            Text(title)
                .font(.system(size: fontSize, weight: fontWeight, design: .rounded))
                .foregroundColor(style == .primary ? (isDisabled ? Color.deactiveText : .white) : .text)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(
                    Group {
                        switch style {
                        case .primary:
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(isDisabled ? Color.deactive : Color.clear)
                                .background(
                                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                        .fill(isDisabled ? LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing) : LinearGradient.primaryVerticalGradient)
                                )
                        case .secondary:
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                        .stroke(Color(hex: "D0CAB6").opacity(0.6), lineWidth: 4.5)
                                )
                        case .card:
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                        .stroke(Color(hex: "D0CAB6").opacity(0.6), lineWidth: 4.5)
                                )
                        }
                    }
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16) // CardButton uses 16 instead of 24
        .shadow(color: style == .primary && !isDisabled ? Color.black.opacity(0.15) : (style == .secondary ? Color.black.opacity(0.35) : .clear), radius: 6, x: 0, y: 0)
        .disabled(isDisabled)
        .opacity(isDisabled ? 1 : 1) // full opacity for disabled
        .frame(width: 300)
    }
}

struct TinyButton: View {
    let title: String
    var action: () -> Void
    var backgroundColor: Color = .primary
    var foregroundColor: Color = .black
    var cornerRadius: CGFloat = 14
    var fontWeight: Font.Weight = .bold
    var fontSize: CGFloat = 20
    var height: CGFloat = 37 // changed from 56
    var isDisabled: Bool = false
    var style: ButtonStyle = .primary

    var body: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            action()
        } label: {
            Text(title)
                .font(.system(size: fontSize, weight: fontWeight, design: .rounded))
                .foregroundColor(style == .primary ? (isDisabled ? Color.deactiveText : .white) : .text)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(
                    Group {
                        switch style {
                        case .primary:
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(isDisabled ? Color.deactive : Color.clear)
                                .background(
                                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                        .fill(isDisabled ? LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing) : LinearGradient.primaryVerticalGradient)
                                )
                        case .secondary:
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                        .stroke(Color(hex: "D0CAB6").opacity(0.6), lineWidth: 4.5)
                                )
                        case .card:
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                        .stroke(Color(hex: "D0CAB6").opacity(0.6), lineWidth: 4.5)
                                )
                        }
                    }
                )
        }
        .buttonStyle(.plain)
        // .padding(.horizontal, 24)
        .padding(.leading, 40)
        .shadow(color: style == .primary && !isDisabled ? Color.black.opacity(0.15) : (style == .secondary ? Color.black.opacity(0.35) : .clear), radius: 6, x: 0, y: 0)
        .disabled(isDisabled)
        .opacity(isDisabled ? 1 : 1) // full opacity for disabled
        .frame(width: 130)
    }
}

#Preview {
    VStack(spacing: 20) {
        AppButton(title: "Get Started", action: {}, style: .primary)
        AppButton(title: "Learn More", action: {}, style: .secondary)
        AppButton(title: "View Card", action: {}, style: .card)
        CardButton(title: "open →", action: {})
        TinyButton(title: "continue", action: {})
    }
    .padding()
    .background(Color(hex: "7DC7FF"))
}