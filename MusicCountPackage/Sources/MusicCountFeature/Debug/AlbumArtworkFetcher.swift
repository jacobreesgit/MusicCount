#if DEBUG
import Foundation
import UIKit

/// Fetches album artwork from iTunes Search API
@MainActor
final class AlbumArtworkFetcher {
    enum FetchError: Error {
        case invalidURL
        case noResults
        case networkError
        case invalidImageData
    }

    private var cache: [String: UIImage] = [:]

    /// Fetch album artwork for a given artist and album
    /// - Parameters:
    ///   - artist: Artist name
    ///   - album: Album name
    /// - Returns: UIImage of album artwork (50x50pt)
    func fetchArtwork(artist: String, album: String) async throws -> UIImage {
        let cacheKey = "\(artist)|\(album)"

        // Check cache first
        if let cached = cache[cacheKey] {
            return cached
        }

        // Build iTunes Search API URL
        let searchTerm = "\(artist) \(album)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        guard let url = URL(string: "https://itunes.apple.com/search?term=\(searchTerm)&entity=album&limit=1") else {
            throw FetchError.invalidURL
        }

        // Fetch search results
        let (data, _) = try await URLSession.shared.data(from: url)

        // Parse JSON
        let decoder = JSONDecoder()
        let response = try decoder.decode(iTunesSearchResponse.self, from: data)

        guard let firstResult = response.results.first,
              let artworkURLString = firstResult.artworkUrl100 else {
            throw FetchError.noResults
        }

        // Download artwork image
        guard let artworkURL = URL(string: artworkURLString) else {
            throw FetchError.invalidURL
        }

        let (imageData, _) = try await URLSession.shared.data(from: artworkURL)

        guard let image = UIImage(data: imageData) else {
            throw FetchError.invalidImageData
        }

        // Resize to 50x50pt (matches real app size)
        let resizedImage = await resizeImage(image, to: CGSize(width: 50, height: 50))

        // Cache it
        cache[cacheKey] = resizedImage

        return resizedImage
    }

    /// Fetch all artwork for mock songs
    /// - Parameter albums: List of (artist, album) tuples
    /// - Returns: Dictionary of artwork keyed by "artist|album"
    func fetchAllArtwork(for albums: [(artist: String, album: String)]) async -> [String: UIImage] {
        NSLog("🎨 AlbumArtworkFetcher: Starting to fetch \(albums.count) albums")
        var results: [String: UIImage] = [:]

        for (artist, album) in albums {
            let key = "\(artist)|\(album)"
            do {
                let artwork = try await fetchArtwork(artist: artist, album: album)
                results[key] = artwork
                NSLog("✅ Fetched artwork for: \(artist) - \(album)")
                // Small delay to avoid rate limiting
                try? await Task.sleep(for: .milliseconds(100))
            } catch {
                NSLog("⚠️ Failed to fetch artwork for \(artist) - \(album): \(error)")
                // Use fallback - generate colored placeholder
                results[key] = generatePlaceholder(for: album)
            }
        }

        NSLog("🎨 AlbumArtworkFetcher: Completed fetching \(results.count) artworks")
        return results
    }

    /// Resize image to specific size
    private func resizeImage(_ image: UIImage, to size: CGSize) async -> UIImage {
        await Task.detached {
            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: size))
            }
        }.value
    }

    /// Generate colored placeholder when artwork fetch fails
    private func generatePlaceholder(for album: String) -> UIImage {
        let size = CGSize(width: 50, height: 50)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // Generate color based on album name hash
            let hash = abs(album.hashValue)
            let hue = CGFloat(hash % 360) / 360.0
            let color = UIColor(hue: hue, saturation: 0.7, brightness: 0.8, alpha: 1.0)

            // Fill background
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // Add music note icon
            let iconSize: CGFloat = 30
            let iconRect = CGRect(
                x: (size.width - iconSize) / 2,
                y: (size.height - iconSize) / 2,
                width: iconSize,
                height: iconSize
            )

            let config = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .regular)
            if let musicIcon = UIImage(systemName: "music.note", withConfiguration: config) {
                UIColor.white.withAlphaComponent(0.8).setFill()
                musicIcon.draw(in: iconRect, blendMode: .normal, alpha: 1.0)
            }
        }
    }
}

// MARK: - iTunes Search API Models

private struct iTunesSearchResponse: Codable {
    let results: [iTunesAlbum]
}

private struct iTunesAlbum: Codable {
    let artworkUrl100: String?
}
#endif
