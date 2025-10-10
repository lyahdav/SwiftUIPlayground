import Foundation

struct PhotosResponse: Decodable {
    let photos: [Photo]
}

struct Photo: Identifiable, Decodable {
    let id: Int
    let url: String
    let title: String
    let description: String
    
    static let examplePhoto = Photo(id: 1, url: "https://api.slingacademy.com/public/sample-photos/1.jpeg", title: "Defense the travel audience hand", description: "Leader structure safe or black late wife newspaper her pick central forget single likely.")
}
