//
//  FirebaseImageService.swift
//  Breez
//
//  Created by Advaith Akella on 9/19/25.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseAuth

// Simple in-memory cache for images
class ImageCache {
    static let shared = ImageCache()
    private var cache: [String: UIImage] = [:]
    private let queue = DispatchQueue(label: "ImageCache", attributes: .concurrent)
    
    private init() {}
    
    func getImage(for key: String) -> UIImage? {
        queue.sync { cache[key] }
    }
    
    func setImage(_ image: UIImage, for key: String) {
        queue.async(flags: .barrier) { [weak self] in
            self?.cache[key] = image
        }
    }
    
    func loadImage(url: String) async -> UIImage? {
        guard let imageURL = URL(string: url) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
}

@MainActor
final class FirebaseImageService: ObservableObject {
    static let shared = FirebaseImageService()

    /// In-memory image cache that we already use elsewhere in the app.
    private let cache = ImageCache.shared
    private let storage: Storage
    private let fileManager = FileManager.default
    private let diskDirectory: URL

    /// Prevents duplicate downloads for the same path.
    private var inFlightTasks: [String: Task<UIImage?, Never>] = [:]

    private init() {
        self.storage = Storage.storage()

        // Create a caches subfolder dedicated to Storage images
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = caches.appendingPathComponent("StorageImages", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        self.diskDirectory = dir
    }

    /// Public entry point – fetches an image for a Storage path (e.g. "app images/pale.jpg").
    /// – First checks the in-memory cache
    /// – If missing, downloads the bytes from Firebase Storage (5 MB hard-limit)
    /// – Saves successful downloads back to the shared cache so future calls are instant
    /// – Multiple simultaneous requests for the same path will share a single network call
    ///
    /// - Parameter path: The reference path *inside* the bucket (do **not** include gs:// or a full URL).
    /// - Returns: A `UIImage` if the download & decoding succeeded, otherwise `nil`.
    func image(for path: String) async -> UIImage? {
        // 1️⃣ Memory cache
        if let cached = cache.getImage(for: path) {
            return cached
        }

        // 2️⃣ Check disk cache
        if let disk = imageFromDisk(for: path) {
            cache.setImage(disk, for: path)
            return disk
        }

        // 3️⃣ If another Task is already fetching the same asset, just await it
        if let task = inFlightTasks[path] {
            return await task.value
        }

        // 4️⃣ Create a new download Task
        let downloadTask = Task<UIImage?, Never> {
            defer { inFlightTasks[path] = nil } // Clean-up when done

            do {
                let ref = storage.reference(withPath: path)
                let data = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
                    // 5 MB – adjust if you have larger assets
                    ref.getData(maxSize: 5 * 1024 * 1024) { data, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let data = data {
                            continuation.resume(returning: data)
                        } else {
                            continuation.resume(throwing: URLError(.badServerResponse))
                        }
                    }
                }

                guard let image = UIImage(data: data) else {
                    return nil
                }

                cache.setImage(image, for: path)

                // Persist to disk for future cold launches
                let url = diskURL(for: path)
                try? data.write(to: url)
                return image
            } catch {
                return nil
            }
        }

        inFlightTasks[path] = downloadTask
        return await downloadTask.value
    }

    /// Fast path to read from in-memory cache only (no disk or network).
    func imageFromMemoryCache(for path: String) -> UIImage? {
        cache.getImage(for: path)
    }

    /// Convenience helper for pre-loading a batch of images (e.g. onboarding flow).
    func preload(paths: [String]) async {
        await withTaskGroup(of: Void.self) { group in
            for path in paths {
                group.addTask {
                    _ = await self.image(for: path)
                }
            }
        }
    }

    // MARK: - Upload helpers

    /// Uploads a user image to Firebase Storage under `users/{uid}/{folder}/{uuid}.jpg` and returns the Storage path.
    func uploadUserImage(_ image: UIImage, folder: String) async throws -> String {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }

        guard let jpeg = image.jpegData(compressionQuality: 0.9) else {
            throw NSError(domain: "FirebaseImageService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to encode JPEG"])
        }

        let uuid = UUID().uuidString
        let path = "users/\(userId)/\(folder)/\(uuid).jpg"
        let ref = storage.reference(withPath: path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            ref.putData(jpeg, metadata: metadata) { _, error in
                if let error { continuation.resume(throwing: error) }
                else { continuation.resume(returning: ()) }
            }
        }

        // Cache locally for instant load later
        if let uiImage = UIImage(data: jpeg) {
            cache.setImage(uiImage, for: path)
        }
        try? jpeg.write(to: diskURL(for: path))
        return path
    }
    
    /// Uploads a report image/video to Firebase Storage under `reports/{uid}/{reportId}/{uuid}.jpg` and returns the Storage path.
    func uploadReportMedia(_ image: UIImage, reportId: String) async throws -> String {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }

        guard let jpeg = image.jpegData(compressionQuality: 0.9) else {
            throw NSError(domain: "FirebaseImageService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to encode JPEG"])
        }

        let uuid = UUID().uuidString
        let path = "reports/\(userId)/\(reportId)/\(uuid).jpg"
        let ref = storage.reference(withPath: path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            ref.putData(jpeg, metadata: metadata) { _, error in
                if let error { continuation.resume(throwing: error) }
                else { continuation.resume(returning: ()) }
            }
        }

        // Cache locally for instant load later
        if let uiImage = UIImage(data: jpeg) {
            cache.setImage(uiImage, for: path)
        }
        try? jpeg.write(to: diskURL(for: path))
        return path
    }

    // MARK: - Disk helpers

    private func diskURL(for path: String) -> URL {
        // Encode the path to a safe filename (no spaces / slashes)
        let encoded = path.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
        return diskDirectory.appendingPathComponent(encoded)
    }

    private func imageFromDisk(for path: String) -> UIImage? {
        let url = diskURL(for: path)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
