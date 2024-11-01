import Foundation
import UIKit

struct GameModel: Codable {
    var id: UUID
    var nameGame: String
    var players: String
    var gameTime: String
    var rules: String
    var cards: [Int]
}
