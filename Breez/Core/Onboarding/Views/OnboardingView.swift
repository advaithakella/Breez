import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct OnboardingView: View {
    let onComplete: () -> Void
    
    @State private var currentStep = 1
    @State private var userName = ""
    @State private var userAge = 25
    @State private var environmentalConcern = ""
    @State private var motivation = ""
    @State private var currentHabits = ""
    @State private var location = ""
    @State private var showProgressBar = true
    @State private var showCharacterCard = false
    @State private var generatedQuote = ""
    @State private var userPhoto: UIImage?
    @State private var showPhotoPicker = false
    
    // Assessment data
    @State private var hasMovedAgeSlider = false
    @State private var hasSelectedConcern = false
    @State private var hasSelectedMotivation = false
    @State private var hasSelectedHabits = false
    @State private var hasEnteredLocation = false
    
    private let totalSteps = 8
    
    var body: some View {
        GeometryReader { geometry in
        ZStack {
            // Background gradient
            LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(hex: "FFCC8E"), location: 0.23),
                        .init(color: Color(hex: "7DC7FF"), location: 0.82)
                    ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                    // Progress bar and navigation
                    if showProgressBar {
                        HStack {
                            Spacer()
                            
                // Progress bar
                            ZStack(alignment: .leading) {
                                // Background
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 300, height: 8)
                                
                                // Progress
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .frame(width: 280 * getProgress(), height: 8)
                                    .shadow(color: Color.white.opacity(0.6), radius: 4, x: 0, y: 0)
                            }
                            .frame(width: 300, height: 8)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    }
                    
                    // Main content
                    VStack(spacing: 0) {
                        // Title
                        if !getStepTitle().isEmpty {
                            StaggeredAppear(index: 0) {
                                if currentStep == 1 {
                                    // Special title for step 1 with Frijole font for BREEZ
                                    HStack(spacing: 4) {
                                        Text("Welcome to")
                                            .font(.proximaNovaSemibold(size: 28))
                                        Text("BREEZ")
                                            .font(.frijole(size: 28))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 20)
                                } else {
                                    Text(getStepTitle())
                                        .font(.proximaNovaSemibold(size: 28))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(3)
                                        .frame(maxWidth: .infinity)
                                        .padding(.top, 20)
                                }
                            }
                        }
                        
                        // Content - centered
                        Spacer()
                        getStepContent()
                            .id(currentStep)
                            .transition(.opacity.combined(with: .move(edge: .leading)))
                            .animation(.easeInOut(duration: 0.4), value: currentStep)
                            .frame(maxWidth: .infinity)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Bottom button
                    VStack {
                        if shouldShowBottomButton() {
                            if currentStep == 1 {
                                // Glass style button for first step
                                Button {
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred(intensity: 0.6)
                                    handleNextStep()
                                } label: {
                                    Text(getButtonText())
                                        .font(.proximaNovaSemibold(size: 18))
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
                                .disabled(!isCurrentStepCompleted())
                                .opacity(isCurrentStepCompleted() ? 1 : 0.6)
                            } else {
                                // Glass style button for all other steps
                                Button {
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred(intensity: 0.6)
                                    handleNextStep()
                                } label: {
                                    Text(getButtonText())
                                        .font(.proximaNovaSemibold(size: 18))
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
                                .disabled(!isCurrentStepCompleted())
                                .opacity(isCurrentStepCompleted() ? 1 : 0.6)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 50)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker(selectedImage: $userPhoto)
        }
    }
    
    // MARK: - Step Management
    
    private func getStepTitle() -> String {
        switch currentStep {
        case 1: return "Welcome to Breez"
        case 2: return "What's your name?"
        case 3: return "How old are you?"
        case 4: return "What environmental issue\nconcerns you most?"
        case 5: return "What motivates you to\nprotect the environment?"
        case 6: return "What are your current\nenvironmental habits?"
        case 7: return "Where are you located?"
        case 8: return "Your Environmental Profile"
        default: return ""
        }
    }
    
    private func getStepContent() -> some View {
        switch currentStep {
        case 1: return AnyView(welcomeSlide)
        case 2: return AnyView(nameInputSlide)
        case 3: return AnyView(ageSelectionSlide)
        case 4: return AnyView(concernSelectionSlide)
        case 5: return AnyView(motivationSelectionSlide)
        case 6: return AnyView(habitsSelectionSlide)
        case 7: return AnyView(locationInputSlide)
        case 8: return AnyView(profileSummarySlide)
        default: return AnyView(EmptyView())
        }
    }
    
    private func getButtonText() -> String {
        switch currentStep {
        case 1: return "Get Started →"
        case 2...7: return "Next →"
        case 8: return "Complete Setup →"
        default: return "Next"
        }
    }
    
    private func shouldShowBottomButton() -> Bool {
        return currentStep <= 8
    }
    
    private func isCurrentStepCompleted() -> Bool {
        switch currentStep {
        case 1: return true
        case 2: return !userName.isEmpty
        case 3: return hasMovedAgeSlider
        case 4: return hasSelectedConcern
        case 5: return hasSelectedMotivation
        case 6: return hasSelectedHabits
        case 7: return hasEnteredLocation
        case 8: return true
        default: return true
        }
    }
    
    private func handleNextStep() {
        if currentStep < totalSteps {
            withAnimation(.easeInOut(duration: 0.4)) {
                currentStep += 1
            }
        } else {
            // Save user data and complete onboarding
            Task {
                await saveUserData()
                onComplete()
            }
        }
    }
    
    private func getProgress() -> Double {
        let progress = Double(currentStep - 1) / Double(totalSteps - 1)
        return max(0, min(1, progress))
    }
    
    // MARK: - Step Views
    
    private var welcomeSlide: some View {
        VStack(spacing: 30) {
            StaggeredAppear(index: 1) {
                VStack(spacing: 20) {
                    Text("Join the movement to protect our planet")
                        .font(.proximaNovaSemibold(size: 20))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            
            StaggeredAppear(index: 2) {
                VStack(spacing: 16) {
                    Text("🌊 Clean our oceans")
                    Text("🌱 Reduce waste")
                    Text("🌍 Fight climate change")
                }
                .font(.proximaNovaSemibold(size: 18))
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var nameInputSlide: some View {
        VStack(spacing: 30) {
            StaggeredAppear(index: 1) {
                TextField("Enter your name", text: $userName)
                    .font(.proximaNovaSemibold(size: 24))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                    )
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
    }
    
    private var ageSelectionSlide: some View {
        VStack(spacing: 20) {
            StaggeredAppear(index: 1) {
                AgePickerView(selectedAge: $userAge)
                    .onChange(of: userAge) { _, _ in
                        hasMovedAgeSlider = true
                    }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var concernSelectionSlide: some View {
        VStack(spacing: 16) {
            let concerns = [
                "Ocean pollution and plastic waste",
                "Climate change and global warming",
                "Deforestation and habitat loss",
                "Air pollution and health impacts",
                "Water scarcity and contamination"
            ]
            
            ForEach(Array(concerns.enumerated()), id: \.element) { index, concern in
                StaggeredAppear(index: index + 1) {
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred(intensity: 0.4)
                        environmentalConcern = concern
                        hasSelectedConcern = true
                    }) {
                        Text(concern)
                            .font(.proximaNovaSemibold(size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(environmentalConcern == concern ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(environmentalConcern == concern ? Color.white.opacity(0.5) : Color.white.opacity(0.3), lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
    }
    
    private var motivationSelectionSlide: some View {
        VStack(spacing: 16) {
            let motivations = [
                "For future generations",
                "To protect wildlife",
                "To improve air quality",
                "To reduce my carbon footprint",
                "To inspire others"
            ]
            
            ForEach(Array(motivations.enumerated()), id: \.element) { index, motivation in
                StaggeredAppear(index: index + 1) {
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred(intensity: 0.4)
                        self.motivation = motivation
                        hasSelectedMotivation = true
                    }) {
                        Text(motivation)
                            .font(.proximaNovaSemibold(size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(self.motivation == motivation ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(self.motivation == motivation ? Color.white.opacity(0.5) : Color.white.opacity(0.3), lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
    }
    
    private var habitsSelectionSlide: some View {
        VStack(spacing: 16) {
            let habits = [
                "Recycling regularly",
                "Using reusable bags",
                "Conserving water",
                "Using public transport",
                "Buying sustainable products"
            ]
            
            ForEach(Array(habits.enumerated()), id: \.element) { index, habit in
                StaggeredAppear(index: index + 1) {
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred(intensity: 0.4)
                        currentHabits = habit
                        hasSelectedHabits = true
                    }) {
                        Text(habit)
                            .font(.proximaNovaSemibold(size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(currentHabits == habit ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(currentHabits == habit ? Color.white.opacity(0.5) : Color.white.opacity(0.3), lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
    }
    
    private var locationInputSlide: some View {
        VStack(spacing: 30) {
            StaggeredAppear(index: 1) {
                TextField("Enter your city or region", text: $location)
                    .font(.proximaNovaSemibold(size: 20))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                    )
                    .onChange(of: location) { _, newValue in
                        hasEnteredLocation = !newValue.isEmpty
                    }
            }
            
            StaggeredAppear(index: 2) {
                Text("This helps us provide local environmental data and connect you with nearby initiatives")
                    .font(.proximaNovaSemibold(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
    }
    
    private var profileSummarySlide: some View {
        VStack(spacing: 30) {
            StaggeredAppear(index: 1) {
                VStack(spacing: 20) {
                    // Profile photo placeholder
                    Button(action: {
                        showPhotoPicker = true
                    }) {
                        if let photo = userPhoto {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 4)
                                )
                        } else {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Text("Tap to add photo")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            StaggeredAppear(index: 2) {
                VStack(spacing: 16) {
                    Text("Welcome, \(userName)!")
                        .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    
                    Text("Your environmental journey starts now")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
            }
            
            StaggeredAppear(index: 3) {
                VStack(spacing: 12) {
                    Text("🌊 \(environmentalConcern)")
                    Text("💚 \(motivation)")
                    Text("♻️ \(currentHabits)")
                    Text("📍 \(location)")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Data Management
    
    private func saveUserData() async {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.uid)
        
        let userData: [String: Any] = [
            "name": userName,
            "age": userAge,
            "environmentalConcern": environmentalConcern,
            "motivation": motivation,
            "currentHabits": currentHabits,
            "location": location,
            "onboardingCompletedAt": Timestamp(date: Date()),
            "updatedAt": Timestamp(date: Date())
        ]
        
        do {
            try await userRef.updateData(userData)
            print("User data saved successfully")
        } catch {
            print("Error saving user data: \(error)")
        }
    }
}

// MARK: - Supporting Views

struct StaggeredAppear<Content: View>: View {
    let index: Int
    let content: Content
    @State private var visible = false
    
    init(index: Int, @ViewBuilder content: () -> Content) {
        self.index = index
        self.content = content()
    }
    
    var body: some View {
        content
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : 20)
            .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.1), value: visible)
            .onAppear {
                visible = true
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred(intensity: 0.3)
            }
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    OnboardingView {
        print("Onboarding completed")
    }
    .background(Color.black)
}