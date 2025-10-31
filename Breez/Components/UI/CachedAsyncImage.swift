//
//  CachedAsyncImage.swift
//  Breez
//
//  Created by Advaith Akella on 9/19/25.
//

import SwiftUI

// MARK: - Image Cache Service (using the one from FirebaseImageService)

// MARK: - Cached Async Image
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    @State private var isLoading = true
    
    init(url: URL?, @ViewBuilder content: @escaping (Image) -> Content, @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        // Resolve synchronously from memory cache to avoid a placeholder flash on first render
        let resolved: UIImage? = {
            if let current = image { return current }
            guard let url else { return nil }
            return ImageCache.shared.getImage(for: url.absoluteString)
        }()

        return Group {
            if let resolved {
                content(Image(uiImage: resolved))
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        guard let url = url, 
              !url.absoluteString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              image == nil else { return }
        
        // Check memory cache first
        if let cachedImage = ImageCache.shared.getImage(for: url.absoluteString) {
            self.image = cachedImage
            self.isLoading = false
            return
        }
        
        // Download from network if not cached
        Task {
            if let loadedImage = await ImageCache.shared.loadImage(url: url.absoluteString) {
                await MainActor.run {
                    ImageCache.shared.setImage(loadedImage, for: url.absoluteString)
                    self.image = loadedImage
                    self.isLoading = false
                }
            } else {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Thumbnail Helper
struct ThumbnailView: View {
    let thumbnailUrl: String
    let size: CGSize
    let cornerRadius: CGFloat
    
    init(thumbnailUrl: String, size: CGSize = CGSize(width: 40, height: 60), cornerRadius: CGFloat = 8) {
        self.thumbnailUrl = thumbnailUrl
        self.size = size
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        if thumbnailUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // Show a plain white image when thumbnail URL is empty
    Rectangle()
        .fill(Color(hex: "F5F3F0"))
                .frame(width: size.width, height: size.height)
                .cornerRadius(cornerRadius)
        } else {
            CachedAsyncImage(url: URL(string: thumbnailUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
    Rectangle()
        .fill(Color(hex: "F5F3F0"))
            }
            .frame(width: size.width, height: size.height)
            .cornerRadius(cornerRadius)
            .clipped()
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CachedAsyncImage(url: URL(string: "https://picsum.photos/200/300")) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    ProgressView()
                        .tint(.white)
                )
        }
        .frame(width: 120, height: 80)
        .clipped()
        .cornerRadius(8)
        
        ThumbnailView(
            thumbnailUrl: "https://picsum.photos/40/60",
            size: CGSize(width: 60, height: 90),
            cornerRadius: 12
        )
        
        Text("CachedAsyncImage Example")
            .font(.caption)
            .foregroundColor(.gray)
    }
    .padding()
}