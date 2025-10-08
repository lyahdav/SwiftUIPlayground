import Foundation

struct Task: Identifiable, Codable, Hashable {
    var id: Int
    var title: String
    var description: String
    let createdAt: Date
    
    static let exampleTask = Task(id: 1, title: "Task Title", description: "Task Description", createdAt: Date())
}
