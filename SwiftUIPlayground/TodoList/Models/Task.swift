import Foundation

struct Task: Identifiable, Codable, Hashable {
    var id: Int
    var title: String
    var description: String
}
