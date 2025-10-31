import SwiftUI
import PhotosUI

struct NewReportView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var reportViewModel = ReportViewModel()
    @State private var currentStep = 0
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    
    private let totalSteps = 4
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress bar
                SwiftUI.ProgressView(value: Double(currentStep), total: Double(totalSteps))
                    .progressViewStyle(.linear)
                    .tint(.blue)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Content
                TabView(selection: $currentStep) {
                    UploadImageView(selectedImage: $selectedImage, showingImagePicker: $showingImagePicker)
                        .tag(0)
                    
                    ReportTypeView(selectedType: $reportViewModel.selectedType)
                        .tag(1)
                    
                    EvidenceView(evidence: $reportViewModel.evidence)
                        .tag(2)
                    
                    PreviewView(selectedType: $reportViewModel.selectedType, evidence: $reportViewModel.evidence)
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Navigation buttons
                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button(currentStep == totalSteps - 1 ? "Submit Report" : "Next") {
                        if currentStep == totalSteps - 1 {
                            submitReport()
                        } else {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    }
                    .disabled(currentStep == 0 && selectedImage == nil)
                }
                .padding()
            }
            .navigationTitle("New Report")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    private func submitReport() {
        reportViewModel.submitReport(image: selectedImage) {
            dismiss()
        }
    }
}

struct UploadImageView: View {
    @Binding var selectedImage: UIImage?
    @Binding var showingImagePicker: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: Ph.camera)
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text("Upload Photo/Video")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Take a photo or choose from gallery")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            if let image = selectedImage {
                VStack(spacing: 16) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                    
                    Button("Change Photo") {
                        showingImagePicker = true
                    }
                    .foregroundColor(.white)
                }
            } else {
                VStack(spacing: 16) {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        VStack(spacing: 12) {
                            Image(systemName: Ph.camera)
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                            
                            Text("Take Photo")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "7DC7FF"))
                        .cornerRadius(12)
                    }
                    
                    Button("Choose from Gallery") {
                        showingImagePicker = true
                    }
                    .foregroundColor(.white)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct ReportTypeView: View {
    @Binding var selectedType: String
    
    private let reportTypes = [
        "Plastic waste",
        "Oil spill",
        "Algae bloom",
        "Marine debris",
        "Beach erosion",
        "Water pollution",
        "Wildlife threat",
        "Other"
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: Ph.list)
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text("Select Report Type")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Choose the type of environmental issue")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(reportTypes, id: \.self) { type in
                    Button(action: {
                        selectedType = type
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: getIconForType(type))
                                .font(.title2)
                                .foregroundColor(selectedType == type ? .white : .white)
                            
                            Text(type)
                                .font(.caption)
                                .foregroundColor(selectedType == type ? .white : .white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedType == type ? Color(hex: "7DC7FF") : Color(hex: "7DC7FF"))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private func getIconForType(_ type: String) -> String {
        switch type {
        case "Plastic waste": return "trash.fill"
        case "Oil spill": return "drop.triangle.fill"
        case "Algae bloom": return "leaf.fill"
        case "Marine debris": return "fish.fill"
        case "Beach erosion": return "mountain.2.fill"
        case "Water pollution": return "drop.fill"
        case "Wildlife threat": return "pawprint.fill"
        default: return "questionmark.circle.fill"
        }
    }
}

struct EvidenceView: View {
    @Binding var evidence: String
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text("Additional Evidence")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Add any additional details or links")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Description (Optional)")
                    .font(.headline)
                
                TextEditor(text: $evidence)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color(hex: "7DC7FF"))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

struct PreviewView: View {
    @Binding var selectedType: String
    @Binding var evidence: String
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text("Preview Report")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Review your report before submitting")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Report Type: \(selectedType)")
                    .font(.headline)
                
                if !evidence.isEmpty {
                    Text("Evidence: \(evidence)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(hex: "7DC7FF"))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

#Preview {
    NewReportView()
}
