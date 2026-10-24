import Foundation
import CoreGraphics
import ImageIO

actor PosterImageLoader {
    private let cache: URLCache
    private let session: URLSession
    
    init() {
        /// Start with AlamofireImage's URLCache defaults for compressed responses:
        /// 20 MiB in memory and 150 MiB on disk. These are reference defaults,
        /// rather than benchmarked limits for this app's workload.
        /// https://github.com/Alamofire/AlamofireImage#image-caching
        cache = URLCache(memoryCapacity: 20 * 1024 * 1024,
                         diskCapacity: 150 * 1024 * 1024,
                         directory: URL.cachesDirectory.appending(path: "MoviePosters"))
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = nil
        configuration.httpShouldSetCookies = false
        session = URLSession(configuration: configuration)
    }
    
    func image(for url: URL) async throws -> CGImage {
        let request = URLRequest(url: url)
        
        if let cached = cache.cachedResponse(for: request) {
            return try decode(cached.data)
        }
        
        let (data, response) = try await session.data(for: request)
        try Task.checkCancellation()
        guard let response = response as? HTTPURLResponse,
              (200..<300).contains(response.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let image = try decode(data)
        try Task.checkCancellation()
        cache.storeCachedResponse(CachedURLResponse(response: response,
                                                    data: data,
                                                    storagePolicy: .allowed),
                                  for: request)
        return image
    }
    
    private func decode(_ data: Data) throws -> CGImage {
        let options = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                         kCGImageSourceCreateThumbnailWithTransform: true,
                                kCGImageSourceThumbnailMaxPixelSize: 1024] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else {
            throw URLError(.cannotDecodeContentData)
        }
        return image
    }
}
