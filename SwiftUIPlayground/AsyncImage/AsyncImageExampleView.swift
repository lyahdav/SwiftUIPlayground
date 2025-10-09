import SwiftUI

// TODO: Break into many files

// TODO: push to GH

struct PhotosResponse: Decodable {
    let photos: [Photo]
}

struct Photo: Identifiable, Decodable {
    let id: Int
    let url: String
    let title: String
    let description: String
}

enum AIError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

struct AsyncImageExampleView: View {
    @State private var photos: [Photo] = []
    @State private var isLoading = true
    @State private var error: Error?
    
    private static let photosUrl = "https://api.slingacademy.com/v1/sample-data/photosz"
    
    var body: some View {
        // TODO: Extract subviews
        ZStack {
            if isLoading {
                LoadingView()
                    .transition(.opacity.combined(with: .scale))
            } else if let error {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.yellow)
                    Text("Failed to load: \(error.localizedDescription)")
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        isLoading = true
                        self.error = nil
                        Task { await fetch() }
                    }
                }
                .padding()
            } else {
                List(photos) { photo in
                    // TODO: extract to cell class
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: photo.url)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                        } placeholder: {
                            Circle().fill(Color.secondary.opacity(0.3))
                        }
                        .frame(width: 64, height: 64)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(photo.title).font(.headline)
                            Text(photo.description).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                        }
                    }
                }
            }
        }
        .task { await fetch() }
    }
    
    private func fetch() async {
        do {
            try await getPhotos()
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    // TODO: Move to view model
    func getPhotos() async throws {
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
        self.photos = photosResponse.photos
    }
}

#Preview {
    AsyncImageExampleView()
}
