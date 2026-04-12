//
//  VaultManager.swift
//  iahd
//

import Foundation
import UIKit

struct VaultItem: Identifiable, Codable {
    let id: UUID
    let filename: String
    let type: MediaType
    let date: Date

    enum MediaType: String, Codable {
        case photo, video
    }
}

class VaultManager: ObservableObject {
    static let shared = VaultManager()

    @Published var items: [VaultItem] = []

    private var vaultDirectory: URL
    private let metadataFileURL: URL

    private init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        vaultDirectory = docs.appendingPathComponent(".vault", isDirectory: true)
        metadataFileURL = docs.appendingPathComponent(".vault_meta")

        try? FileManager.default.createDirectory(at: vaultDirectory, withIntermediateDirectories: true)
        // Исключаем папку из iCloud бэкапа
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        try? vaultDirectory.setResourceValues(resourceValues)

        loadMetadata()
    }

    func fileURL(for item: VaultItem) -> URL {
        vaultDirectory.appendingPathComponent(item.filename)
    }

    func savePhoto(_ image: UIImage) {
        let id = UUID()
        let filename = "\(id.uuidString).jpg"
        let fileURL = vaultDirectory.appendingPathComponent(filename)

        guard let data = image.jpegData(compressionQuality: 0.92) else { return }
        try? data.write(to: fileURL, options: .atomic)

        let item = VaultItem(id: id, filename: filename, type: .photo, date: Date())
        DispatchQueue.main.async {
            self.items.insert(item, at: 0)
            self.saveMetadata()
        }
    }

    func saveVideo(from sourceURL: URL) {
        let id = UUID()
        let ext = sourceURL.pathExtension.isEmpty ? "mov" : sourceURL.pathExtension
        let filename = "\(id.uuidString).\(ext)"
        let destURL = vaultDirectory.appendingPathComponent(filename)

        do {
            try FileManager.default.copyItem(at: sourceURL, to: destURL)
        } catch {
            return
        }

        let item = VaultItem(id: id, filename: filename, type: .video, date: Date())
        DispatchQueue.main.async {
            self.items.insert(item, at: 0)
            self.saveMetadata()
        }
    }

    func delete(_ item: VaultItem) {
        try? FileManager.default.removeItem(at: fileURL(for: item))
        items.removeAll { $0.id == item.id }
        saveMetadata()
    }

    private func saveMetadata() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: metadataFileURL, options: .atomic)
    }

    private func loadMetadata() {
        guard let data = try? Data(contentsOf: metadataFileURL),
              let loaded = try? JSONDecoder().decode([VaultItem].self, from: data) else { return }
        items = loaded.filter { FileManager.default.fileExists(atPath: fileURL(for: $0).path) }
    }
}
