import FactoryKit
import Testing
@testable import DiscoverFeature

struct ContainerPosterImageLoaderTests {
    @Test
    func posterImageLoader_whenResolvedRepeatedly_shouldReuseInstance() {
        let container = Container()

        let first = container.posterImageLoader()
        let second = container.posterImageLoader()

        #expect(first === second)
    }

    @Test
    func posterImageLoader_whenResolvedFromDifferentContainers_shouldReturnDistinctInstances() {
        let firstContainer = Container()
        let secondContainer = Container()

        let first = firstContainer.posterImageLoader()
        let second = secondContainer.posterImageLoader()

        #expect(first !== second)
    }
}
