import Foundation
import Testing
@testable import DiscoverFeature

struct TraktMovieDTODecodeTests {
    @Test
    func decode_whenPosterIsPresent_shouldDecodeImagePath() throws {
        let data = Data(#"{"ids":{"trakt":1111},"title":"foo.title","images":{"poster":["images.example.com/foo.poster.webp"]}}"#.utf8)

        let result = try JSONDecoder().decode(TraktMovieDTO.self, from: data)

        #expect(result.images?.poster == ["images.example.com/foo.poster.webp"])
    }

    @Test(arguments: [
        #"{"ids":{"trakt":1111},"title":"foo.title"}"#,
        #"{"ids":{"trakt":1111},"title":"foo.title","images":null}"#,
        #"{"ids":{"trakt":1111},"title":"foo.title","images":{"poster":null}}"#,
        #"{"ids":{"trakt":1111},"title":"foo.title","images":{"poster":[]}}"#
    ])
    func decode_whenPosterIsAbsent_shouldDecodeWithoutPoster(json: String) throws {
        let data = Data(json.utf8)

        let result = try JSONDecoder().decode(TraktMovieDTO.self, from: data)

        #expect(result.images?.poster?.first == nil)
    }
}
