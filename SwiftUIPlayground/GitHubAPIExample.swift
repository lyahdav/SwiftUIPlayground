import SwiftUI

struct GitHubAPIExample: View, CustomTitleConforming {

    @State private var user: GitHubUser?
    @State private var repo: GitHubRepo?
    @State private var isNight = false

    var title: String {
        "GitHub API Example"
    }

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(Color.blue.gradient)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFit().aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .foregroundColor(.secondary)
                }
                .frame(width: 120, height: 120)
                
                Text(user?.login ?? "Login Placeholder")
                    .bold()
                    .font(.title3)
                
                Text(user?.bio ?? "No bio")
                    .padding()
                
                Text("Repo: \(repo?.name ?? "")")
                    .padding()
                
                Text("Repo watchers: \(repo?.watchersCount ?? 0)")
                    .padding()
                
                Button("Tap me!") {
                    print("button tapped")
                    isNight.toggle()
                }
                
                ChildView(isNight: isNight)
                
                Text("TextLast")
                    .background(.blue)
                    .cornerRadius(3)
                    .padding(.bottom, 10)

                Rectangle()
                    .fill(.red.gradient)
                    .frame(width: 200, height: 70)
                
                TimerView()
                
            }
            .padding()
            .task {
                do {
                    user = try await getGitHubObject(from: "https://api.github.com/users/lyahdav")
                    repo = try await getGitHubObject(from: "https://api.github.com/repos/lyahdav/ai-invoice-uploader")
                } catch GHError.invalidURL {
                    print("invalid URL")
                } catch GHError.invalidResponse {
                    print("invalid response")
                } catch GHError.invalidData {
                    print("invalid data")
                } catch {
                    print("Unexpected error: \(error)")
                }
            }
        }
    }
    
    func getGitHubObject<T: Decodable>(from endpoint: String) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Error: \(error)")
            throw GHError.invalidData
        }
    }
}

@Observable
class TimerViewModel {
    var seconds = 0
    
    init() {
        // Start a timer that increments every second
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.seconds += 1
        }
    }
}

struct TimerLabel: View {
    let viewModel: TimerViewModel

    var body: some View {
        Text("Seconds: \(viewModel.seconds)")
    }
}

struct TimerView: View {
    @State private var viewModel = TimerViewModel()

    var body: some View {
        TimerLabel(viewModel: viewModel)
    }
}

struct ChildView: View {
    let isNight: Bool
    
    var body: some View {
        Text(isNight ? "night" : "day")
    }
}

struct GitHubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio: String?
}

struct GitHubRepo: Codable {
    let watchersCount: Int
    let name: String
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

#Preview {
  GitHubAPIExample()
}
