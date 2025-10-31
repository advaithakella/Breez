//
//  OnboardingContainerView.swift
//  Breez
//
//  Created by Advaith Akella on 9/19/25.
//

import SwiftUI

struct OnboardingContainerView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        OnboardingView {
            // This closure is called when onboarding is completed
            hasCompletedOnboarding = true
        }
        .onChange(of: hasCompletedOnboarding) { _, newValue in
            print("OnboardingContainer: hasCompletedOnboarding changed to: \(newValue)")
        }
    }
}

#Preview {
    OnboardingContainerView()
}