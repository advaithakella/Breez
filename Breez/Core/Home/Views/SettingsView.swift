import SwiftUI

struct SettingsView: View {
    let onLogout: () -> Void
    
    var body: some View {
        ZStack {
            // Glass container
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                )

            VStack(spacing: 24) {
                Text("Settings")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                // Glass button at top
                Button(action: { onLogout() }) {
                    Text("Logout")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                        )
                        .cornerRadius(18)
                }

                Spacer()
            }
            .padding(24)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}

#Preview {
    SettingsView {
        print("Logout tapped")
    }
    .background(Color.black)
}