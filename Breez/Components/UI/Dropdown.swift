import SwiftUI
import UIKit

struct Dropdown<Content: View>: View {
    let title: String
    let description: String
    let content: Content?
    
    @State private var isExpanded = false
    
    init(title: String, description: String, @ViewBuilder content: () -> Content = { EmptyView() as! Content }) {
        self.title = title
        self.description = description
        self.content = content()
    }
    
    init(title: String, description: String) where Content == EmptyView {
        self.title = title
        self.description = description
        self.content = nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with title and icon
            Button {
                let selection = UISelectionFeedbackGenerator()
                selection.selectionChanged()
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        highlightedTitleText(title)
                        
                        highlightedDescriptionText(isExpanded ? description : description.firstSentence())
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                            .animation(.easeInOut(duration: 0.3), value: isExpanded)
                    }
                    
                    Spacer()
                    
                    // Animated dropdown icon
                    Icon(
                        icon: Image(systemName: Ph.caretDown)
                            .foregroundColor(.primary)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    )
                    .animation(.easeInOut(duration: 0.3), value: isExpanded)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .buttonStyle(.plain)
            
            // Expandable content
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    if content != nil {
                        content
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
        }
    .frame(maxWidth: 380)
    .background(Color(hex: "F5F3F0"))
    .cornerRadius(18)
    .overlay(
        RoundedRectangle(cornerRadius: 18)
            .stroke(Color(hex: "D0CAB6"), lineWidth: 2)
    )
    }
}

// Simple dropdown without custom content
struct SimpleDropdown: View {
    let title: String
    let description: String
    
    @State private var isExpanded = false
    
    var body: some View {
        Dropdown(title: title, description: description)
    }
}

// Helper for getting first sentence
private extension String {
    func firstSentence() -> String {
        if let dotIndex = self.firstIndex(of: ".") {
            return String(self[...dotIndex])
        }
        return self
    }
}

// MARK: - Rendering Helpers
private extension Dropdown {
    @ViewBuilder
    func highlightedTitleText(_ text: String) -> some View {
        Text(text)
            .font(.sohne(.bold, size: 16))
            .foregroundColor(.black)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder
    func highlightedDescriptionText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .regular))
            .foregroundColor(.black.opacity(0.8))
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.leading)
    }
}