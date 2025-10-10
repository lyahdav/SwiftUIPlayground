import SwiftUI

@Observable
class AsyncImageExampleViewModel {
    var photos: [Photo] = []
    var isLoading = true
    var error: Error?
    
    private static let photosUrl = "https://api.slingacademy.com/v1/sample-data/photos"
    
    func fetch() async {
        do {
            photos = try await getPhotos()
        } catch {
            self.error = error
        }
        withAnimation {
            isLoading = false
        }
    }
    
    private func getPhotos() async throws -> [Photo] {
        guard let url = URL(string: Self.photosUrl) else {
            throw AIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw AIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let photosResponse = try? decoder.decode(PhotosResponse.self, from: data) else {
            throw AIError.invalidData
        }
        return photosResponse.photos
    }
    
    func retry() {
        withAnimation {
            isLoading = true
            error = nil
        }
        Task { await fetch() }
    }
}
