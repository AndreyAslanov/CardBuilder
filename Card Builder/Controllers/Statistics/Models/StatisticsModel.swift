import Foundation
import UIKit

struct StatisticsModel: Codable {
    var id: UUID
    var wins: String
    var defeats: String
    var hours: String
    var game: String
}
