import SwiftUI
import Foundation

// MARK: - Image Cache
actor ImageCache {
    static let shared = ImageCache()

    private var cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 200
        cache.totalCostLimit = 1024 * 1024 * 100  // 100 MB
    }

    func image(for url: String) -> UIImage? {
        cache.object(forKey: url as NSString)
    }

    func store(_ image: UIImage, for url: String) {
        let cost = image.jpegData(compressionQuality: 1.0)?.count ?? 0
        cache.setObject(image, forKey: url as NSString, cost: cost)
    }
}

// MARK: - Response Cache
actor ResponseCache {
    static let shared = ResponseCache()

    private var entries: [String: CacheEntry] = [:]

    private init() {}

    struct CacheEntry {
        let data: Data
        let expiresAt: Date
    }

    func get(key: String) -> Data? {
        guard let entry = entries[key], entry.expiresAt > Date.now else {
            entries.removeValue(forKey: key)
            return nil
        }
        return entry.data
    }

    func set(key: String, data: Data, ttl: TimeInterval = 300) {
        entries[key] = CacheEntry(data: data, expiresAt: Date.now.addingTimeInterval(ttl))
    }

    func invalidate(key: String) {
        entries.removeValue(forKey: key)
    }

    func invalidateAll() {
        entries.removeAll()
    }
}
