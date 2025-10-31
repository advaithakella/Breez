import SwiftUI
import UIKit

struct ReportsHistoryView: View {
    @StateObject private var reportsViewModel = ReportsViewModel()
    @State private var selectedReport: Report?
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isProcessing = false
    @State private var processingProgress: Double = 0.0
    @State private var reportImages: [UUID: UIImage] = [:]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "FFCC8E"), location: 0.23),
                    .init(color: Color(hex: "7DC7FF"), location: 0.82)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Scan button
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: Ph.camera)
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            Text("Scan Plastic")
                                .font(.proximaNovaSemibold(size: 18))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                        )
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    if reportsViewModel.reports.isEmpty {
                        EmptyStateView()
                    } else {
                        VStack(spacing: 12) {
                            ForEach(reportsViewModel.reports) { report in
                                ReportGlassCard(report: report, localImage: reportImages[report.id]) { selectedReport = report }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .opacity(isProcessing ? 0.3 : 1.0)
            .allowsHitTesting(!isProcessing)
            
            // Processing overlay
            if isProcessing {
                ProcessingView(progress: processingProgress, image: selectedImage)
            }
        }
        .sheet(item: $selectedReport) { report in
            ReportDetailView(report: report, localImage: reportImages[report.id])
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { oldValue, newValue in
            if let image = newValue {
                startProcessing(image: image)
            }
        }
    }
    
    private func startProcessing(image: UIImage) {
        isProcessing = true
        processingProgress = 0.0
        
        // Simulate processing with progress
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            processingProgress += 0.02
            
            if processingProgress >= 1.0 {
                timer.invalidate()
                
                // Small delay before creating report
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    createScanReport(image: image)
                    isProcessing = false
                    processingProgress = 0.0
                    selectedImage = nil
                }
            }
        }
    }
    
    private func createScanReport(image: UIImage) {
        // Create a dummy report about a plastic water bottle
        let newReport = Report(
            userId: "current_user",
            type: .waste,
            category: .marine,
            title: "Plastic Water Bottle",
            description: "Single-use plastic water bottle found at beach location. Material: PET plastic. Recommend proper disposal or recycling.",
            location: "Current Location",
            coordinates: nil,
            imageUrls: ["scan_\(UUID().uuidString).jpg"],
            evidence: "Plastic water bottle detected via scan. Material: PET (Polyethylene Terephthalate). Impact: Single-use plastic contributes to marine pollution and takes approximately 450 years to decompose.",
            status: .pending,
            priority: .medium,
            dateCreated: Date(),
            dateUpdated: Date(),
            analysis: ReportAnalysis(
                pollutionType: "Plastic Waste - Water Bottle",
                severityLevel: .medium,
                ecosystemsAffected: ["Marine", "Beach", "Coastal"],
                marineImpact: "Plastic water bottles are a major source of marine debris. When improperly disposed, they can break down into microplastics that harm marine life and enter the food chain.",
                confidence: 0.95,
                recommendations: [
                    "Dispose of bottle in designated recycling bin",
                    "Consider using a reusable water bottle",
                    "Report location to local cleanup organizations",
                    "Raise awareness about single-use plastic impact"
                ],
                estimatedCleanupCost: nil,
                estimatedCleanupTime: "Immediate action recommended",
                authoritiesNotified: [],
                nextSteps: [
                    "Properly dispose or recycle the bottle",
                    "Share report with local environmental groups",
                    "Consider organizing a cleanup event"
                ],
                relatedReports: []
            ),
            tags: ["plastic", "water-bottle", "PET", "single-use", "scan"],
            isPublic: true,
            isAnonymous: false,
            contactInfo: nil,
            followUpRequired: false,
            followUpDate: nil
        )
        
        // Store the image with the report's actual ID after creation
        reportImages[newReport.id] = image
        
        // Add to reports view model
        reportsViewModel.reports.insert(newReport, at: 0)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: Ph.docText)
                .font(.system(size: 60))
                .foregroundColor(.white)
            
            Text("No Reports Yet")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Start by creating your first environmental report")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

struct ReportGlassCard: View {
    let report: Report
    let localImage: UIImage?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                if let localImage = localImage {
                    Image(uiImage: localImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                } else {
                    AsyncImage(url: URL(string: report.imageUrls.first ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.white.opacity(0.15))
                    }
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(report.type.rawValue)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(report.location)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack {
                        Text(report.dateCreated, style: .date)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        StatusBadge(status: report.status)
                    }
                }
                
                Spacer()
                
                Image(systemName: Ph.caretRight)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(12)
            .background(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
            )
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatusBadge: View {
    let status: Report.ReportStatus
    
    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .foregroundColor(.white)
            .cornerRadius(4)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .pending: return .orange.opacity(0.2)
        case .ready: return .green.opacity(0.2)
        case .error: return .red.opacity(0.2)
        default: return .gray.opacity(0.2)
        }
    }
    
    private var textColor: Color {
        switch status {
        case .pending: return .orange
        case .ready: return .green
        case .error: return .red
        default: return .gray
        }
    }
}

struct ReportDetailView: View {
    let report: Report
    let localImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "FFCC8E"), location: 0.23),
                    .init(color: Color(hex: "7DC7FF"), location: 0.82)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            NavigationView {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Image
                        if let localImage = localImage {
                            Image(uiImage: localImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 400)
                                .cornerRadius(18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                )
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                        } else {
                            AsyncImage(url: URL(string: report.imageUrls.first ?? "")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(height: 250)
                            }
                            .frame(maxHeight: 400)
                            .cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        }
                        
                        // Title and Description
                        if !report.title.isEmpty || !report.description.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                if !report.title.isEmpty {
                                    Text(report.title)
                                        .font(.proximaNovaSemibold(size: 28))
                                        .foregroundColor(.white)
                                }
                                if !report.description.isEmpty {
                                    Text(report.description)
                                        .font(.proximaNovaSemibold(size: 16))
                                        .foregroundColor(.white.opacity(0.9))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                            )
                            .cornerRadius(18)
                            .padding(.horizontal, 20)
                        }
                        
                        // Report details card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Report Details")
                                .font(.proximaNovaSemibold(size: 24))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 16) {
                                DetailRow(label: "Type", value: report.type.rawValue)
                                DetailRow(label: "Category", value: report.category.rawValue)
                                DetailRow(label: "Location", value: report.location)
                                DetailRow(dateLabel: "Date", date: report.dateCreated, style: .date)
                                DetailRow(label: "Status", value: report.status.rawValue.capitalized)
                                DetailRow(label: "Priority", value: report.priority.rawValue)
                                
                                if !report.evidence.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Evidence")
                                            .font(.proximaNovaSemibold(size: 14))
                                            .foregroundColor(.white.opacity(0.7))
                                        Text(report.evidence)
                                            .font(.proximaNovaSemibold(size: 16))
                                            .foregroundColor(.white)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .lineSpacing(4)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                        )
                        .cornerRadius(18)
                        .padding(.horizontal, 20)
                        
                        // Analysis results - show for all reports with analysis
                        if let analysis = report.analysis {
                            AnalysisResultsView(analysis: analysis)
                                .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                            .frame(height: 40)
                    }
                }
                .navigationTitle("Report Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.clear, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                        .font(.proximaNovaSemibold(size: 16))
                        .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

struct DetailRow: View {
    let label: String
    var value: String = ""
    var date: Date? = nil
    var style: Text.DateStyle = .date
    
    init(label: String, value: String) {
        self.label = label
        self.value = value
        self.date = nil
    }
    
    init(dateLabel: String, date: Date, style: Text.DateStyle) {
        self.label = dateLabel
        self.date = date
        self.style = style
        self.value = ""
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(.proximaNovaSemibold(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 100, alignment: .leading)
            
            Spacer()
            
            if let date = date {
                Text(date, style: style)
                    .font(.proximaNovaSemibold(size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.trailing)
            } else {
                Text(value)
                    .font(.proximaNovaSemibold(size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AnalysisResultsView: View {
    let analysis: ReportAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "7DC7FF"))
                Text("Analysis Results")
                    .font(.proximaNovaSemibold(size: 24))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                DetailRow(label: "Pollution Type", value: analysis.pollutionType)
                DetailRow(label: "Severity", value: analysis.severityLevel.rawValue)
                DetailRow(label: "Confidence", value: "\(Int(analysis.confidence * 100))%")
                
                if !analysis.ecosystemsAffected.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ecosystems Affected")
                            .font(.proximaNovaSemibold(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                        HStack(spacing: 8) {
                            ForEach(analysis.ecosystemsAffected, id: \.self) { ecosystem in
                                Text(ecosystem)
                                    .font(.proximaNovaSemibold(size: 14))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.white.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                if !analysis.marineImpact.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Marine Impact")
                            .font(.proximaNovaSemibold(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                        Text(analysis.marineImpact)
                            .font(.proximaNovaSemibold(size: 16))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(4)
                    }
                }
                
                if let cleanupTime = analysis.estimatedCleanupTime {
                    DetailRow(label: "Cleanup Time", value: cleanupTime)
                }
                
                if !analysis.recommendations.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recommendations")
                            .font(.proximaNovaSemibold(size: 18))
                            .foregroundColor(.white)
                        ForEach(Array(analysis.recommendations.enumerated()), id: \.offset) { index, rec in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1).")
                                    .font(.proximaNovaSemibold(size: 16))
                                    .foregroundColor(Color(hex: "7DC7FF"))
                                    .frame(width: 24)
                                Text(rec)
                                    .font(.proximaNovaSemibold(size: 16))
                                    .foregroundColor(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                
                if !analysis.nextSteps.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Next Steps")
                            .font(.proximaNovaSemibold(size: 18))
                            .foregroundColor(.white)
                        ForEach(Array(analysis.nextSteps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "FFCC8E"))
                                    .frame(width: 24)
                                Text(step)
                                    .font(.proximaNovaSemibold(size: 16))
                                    .foregroundColor(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
        )
        .cornerRadius(18)
    }
}

struct ProcessingView: View {
    let progress: Double
    let image: UIImage?
    
    var body: some View {
        ZStack {
            // Blur background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Preview image
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                
                // Processing text
                VStack(spacing: 8) {
                    Text("Scanning Plastic...")
                        .font(.proximaNovaSemibold(size: 24))
                        .foregroundColor(.white)
                    
                    Text("Analyzing material and environmental impact")
                        .font(.proximaNovaSemibold(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Progress bar
                VStack(spacing: 12) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                            
                            // Progress fill
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "FFCC8E"),
                                            Color(hex: "7DC7FF")
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * min(progress, 1.0), height: 8)
                                .animation(.linear(duration: 0.1), value: progress)
                        }
                    }
                    .frame(height: 8)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.proximaNovaSemibold(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(width: 280)
                
                // Processing steps
                VStack(spacing: 8) {
                    ProcessingStep(
                        text: "Image recognition",
                        isComplete: progress > 0.3
                    )
                    ProcessingStep(
                        text: "Material analysis",
                        isComplete: progress > 0.6
                    )
                    ProcessingStep(
                        text: "Environmental impact",
                        isComplete: progress > 0.9
                    )
                    ProcessingStep(
                        text: "Generating report",
                        isComplete: progress >= 1.0
                    )
                }
                .padding(.top, 8)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                    )
            )
            .padding(.horizontal, 40)
        }
    }
}

struct ProcessingStep: View {
    let text: String
    let isComplete: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 16))
                .foregroundColor(isComplete ? Color(hex: "7DC7FF") : Color.white.opacity(0.3))
                .animation(.spring(response: 0.3), value: isComplete)
            
            Text(text)
                .font(.proximaNovaSemibold(size: 14))
                .foregroundColor(isComplete ? .white : .white.opacity(0.6))
                .animation(.spring(response: 0.3), value: isComplete)
            
            Spacer()
        }
    }
}

#Preview {
    ReportsHistoryView()
}
