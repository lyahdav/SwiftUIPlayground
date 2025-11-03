import SwiftUI

// Same as ArticlesList except uses UserDefaults instead of @AppStorage
struct ArticlesList2 {

  struct Article: Identifiable {
    let id: Int
    let title: String
    let summary: String
  }

  struct ArticleService {
    static func fetchArticles(completion: @escaping ([Article]) -> Void) {
      // Simulate async network fetch with a delay
      DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
        let sampleArticles = [
          Article(
            id: 1,
            title: "SwiftUI Tips",
            summary: "Learn how to build better UIs with SwiftUI."
          ),
          Article(
            id: 2,
            title: "Concurrency in Swift",
            summary: "Understand async/await and structured concurrency."
          ),
          Article(
            id: 3,
            title: "Combine Basics",
            summary: "Reactive programming in Swift explained simply."
          ),
          Article(
            id: 4,
            title: "UIKit vs SwiftUI",
            summary: "Tradeoffs between declarative and imperative UI frameworks."
          ),
        ]
        completion(sampleArticles)
      }
    }
  }

  @Observable
  class ArticleViewModel {
    var articles: [Article] = []
    var favorites: Set<Int> = []
    var filter: Filter = .all

    enum Filter: String, CaseIterable {
      case all = "All Articles"
      case favorites = "Favorites Only"
    }

    private let favoritesKey = "favoriteArticles"

    init() {
      loadFavorites()
      fetchArticles()
    }

    func fetchArticles() {
      ArticleService.fetchArticles { [weak self] fetched in
        DispatchQueue.main.async {
          self?.articles = fetched
        }
      }
    }

    func toggleFavorite(for article: Article) {
      if favorites.contains(article.id) {
        favorites.remove(article.id)
      } else {
        favorites.insert(article.id)
      }
      saveFavorites()
    }

    func isFavorite(_ article: Article) -> Bool {
      favorites.contains(article.id)
    }

    private func saveFavorites() {
      UserDefaults.standard.set(Array(favorites), forKey: favoritesKey)
    }

    private func loadFavorites() {
      if let saved = UserDefaults.standard.array(forKey: favoritesKey) as? [Int] {
        favorites = Set(saved)
      }
    }

    var filteredArticles: [Article] {
      switch filter {
      case .all:
        return articles
      case .favorites:
        return articles.filter { favorites.contains($0.id) }
      }
    }
  }

  struct ArticleListView: View, CustomTitleConforming {
    @State private var viewModel = ArticleViewModel()

    var title: String {
      "ArticlesList2"
    }

    var body: some View {
      VStack {
        Picker("Filter", selection: $viewModel.filter) {
          ForEach(ArticleViewModel.Filter.allCases, id: \.self) { filter in
            Text(filter.rawValue).tag(filter)
          }
        }
        .pickerStyle(.segmented)
        .padding()

        List(viewModel.filteredArticles) { article in
          ArticleRow(
            article: article,
            isFavorite: viewModel.isFavorite(article),
            toggleFavorite: { viewModel.toggleFavorite(for: article) }
          )
        }
        .listStyle(.plain)
      }
    }
  }

  struct ArticleRow: View {
    let article: Article
    let isFavorite: Bool
    let toggleFavorite: () -> Void

    var body: some View {
      HStack {
        VStack(alignment: .leading) {
          Text(article.title)
            .font(.headline)
          Text(article.summary)
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        Spacer()
        Button(action: toggleFavorite) {
          Image(systemName: isFavorite ? "star.fill" : "star")
            .foregroundColor(.yellow)
        }
        .buttonStyle(.plain)
      }
      .padding(.vertical, 4)
    }
  }
}

#Preview {
  ArticlesList2.ArticleListView()
}
