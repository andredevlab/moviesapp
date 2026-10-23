import Foundation

enum JSONFixture {
    static func load(_ name: String) throws -> Foundation.Data {
        guard let url = Bundle.module.url(forResource: name,
                                          withExtension: "json",
                                          subdirectory: "JSON") else {
            throw CocoaError(.fileNoSuchFile,
                             userInfo: [NSFilePathErrorKey: name + ".json"])
        }
        return try Foundation.Data(contentsOf: url)
    }
}
