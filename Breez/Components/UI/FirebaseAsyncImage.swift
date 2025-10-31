//
//  FirebaseAsyncImage.swift
//  Breez
//
//  Created by Advaith Akella on 10/27/25.
//

import SwiftUI

/// A drop-in replacement for `AsyncImage` / `CachedAsyncImage` when your assets live in **Firebase Storage** and you only have the *path* (e.g. "app images/pale.jpg").
///
/// Example:
/// ```swift
/// FirebaseAsyncImage(path: "app images/pale.jpg") { image in
///     image.resizable().scaledToFill()
/// } placeholder: {
///     ProgressView()
/// }
/// .frame(width: 120, height: 80)
/// ```
struct FirebaseAsyncImage<Content: View, Placeholder: View>: View {
    private let path: String?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    @State private var uiImage: UIImage?

    init(path: String?, @ViewBuilder content: @escaping (Image) -> Content, @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self.path = path
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        // Resolve synchronously from memory cache to avoid placeholder flash
        let resolved: UIImage? = {
            if let current = uiImage { return current }
            guard let path else { return nil }
            return FirebaseImageService.shared.imageFromMemoryCache(for: path)
        }()

        return Group {
            if let resolved {
                content(Image(uiImage: resolved))
            } else {
                placeholder()
                    .task {
                        await load()
                    }
            }
        }
    }

    private func load() async {
        guard uiImage == nil, let path, !path.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        if let image = await FirebaseImageService.shared.image(for: path) {
            uiImage = image
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        FirebaseAsyncImage(path: "app images/sample.jpg") { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    ProgressView()
                        .tint(.white)
                )
        }
        .frame(width: 120, height: 80)
        .clipped()
        .cornerRadius(8)
        
        Text("FirebaseAsyncImage Example")
            .font(.caption)
            .foregroundColor(.gray)
    }
    .padding()
}
