import Foundation

// Not named Task to prevent conflict with Swift type Task.
struct TodoListTask: Identifiable, Codable, Hashable {
    var id: Int
    var title: String
    var description: String
    let createdAt: Date
    var modifiedAt: Date
    
    static let exampleTask = TodoListTask(id: 1, title: "Task Title", description: "Task Description", createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), modifiedAt: Date())
}
