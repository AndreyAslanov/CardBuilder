import Foundation

struct AppLinks {
    static let appShareURL: URL = {
        guard let url = URL(string: "https://apps.apple.com/us/app/card-builder-create-a-game/id6737691823") else {
            fatalError("Invalid URL for appShareURL")
        }
        return url
    }()

    static let appStoreReviewURL: URL = {
        guard let url = URL(string: "https://apps.apple.com/us/app/card-builder-create-a-game/id6737691823") else {
            fatalError("Invalid URL for appStoreReviewURL")
        }
        return url
    }()

    static let usagePolicyURL: URL = {
        guard let url = URL(string: "https://www.termsfeed.com/live/b41b1666-bbbf-4d3d-a2c1-e0a9a6a0b98d") else {
            fatalError("Invalid URL for usagePolicyURL")
        }
        return url
    }()
}
