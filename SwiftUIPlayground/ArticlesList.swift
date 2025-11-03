import SwiftUI

struct Article: Identifiable {
  let id: String
  let title: String
  let summary: String
  var isFavorite: Bool = false
}

class ArticlesService {
  func fetchArticles() async throws -> [Article] {
    // TODO: add error case
    try await Task.sleep(nanoseconds: 1_000_000_000)
    return Array(1...20).map {
      Article(id: String($0), title: "Title \($0)", summary: "Summary \($0)")
    }
  }

}

enum ArticlesListState {
  case loading
  case error(Error)
  case loaded
}

@Observable
class ArticlesViewModel {
  let articlesService = ArticlesService()
  var state: ArticlesListState = .loading
  var articles: [Article] = []
  var selectedFilter: Filter = .all

  var filteredArticles: [Article] {
    switch selectedFilter {
    case .all:
      return articles
    case .favorites:
      return articles.filter { $0.isFavorite }
    }
  }

  @ObservationIgnored @AppStorage("articleFavoriteData") private var articleFavoriteData = Data()

  // Computed property to work with dictionary
  private var articleFavoriteMap: [String: Bool] {
    get {
      if let decoded = try? JSONDecoder().decode([String: Bool].self, from: articleFavoriteData) {
        return decoded
      }
      return [:]  // default empty dictionary
    }
    set {
      if let encoded = try? JSONEncoder().encode(newValue) {
        articleFavoriteData = encoded
      }
    }
  }

  private func saveArticleFavoriteDataToStorage() {
    var newArticleFavoriteMap: [String: Bool] = [:]
    for article in articles {
      newArticleFavoriteMap[article.id] = article.isFavorite
    }
    articleFavoriteMap = newArticleFavoriteMap
  }

  func fetchArticles() async {
    do {
      articles = try await articlesService.fetchArticles()
      for (i, article) in articles.enumerated() {
        // can't use article on left side here as it would be a copy
        articles[i].isFavorite = articleFavoriteMap[article.id] ?? false
      }
      state = .loaded
    } catch {
      state = .error(error)
    }
  }

  func toggleFavorite(forArticleWithId id: String) {
    // TODO: avoid O(n)
    if let articleIndex = articles.firstIndex(where: { $0.id == id }) {
      articles[articleIndex].isFavorite.toggle()
      saveArticleFavoriteDataToStorage()
    }
  }
}

enum Filter: String, CaseIterable {
  case all = "All"
  case favorites = "Favorites"
}

struct ArticlesList: View {
  @State private var viewModel = ArticlesViewModel()

  var body: some View {
    VStack {
      Picker("Select filter", selection: $viewModel.selectedFilter) {
        ForEach(Filter.allCases, id: \.self) { filter in
          Text(filter.rawValue)
        }
      }
      .pickerStyle(.segmented)
      switch viewModel.state {
      case .loading:
        VStack {
          Spacer()
          ProgressView()
          Spacer()
        }
      case .error(let error):
        Text("Error: \(error.localizedDescription)")
      case .loaded:
        List(viewModel.filteredArticles) { article in
          ArticleRow(article: article, viewModel: viewModel)
        }
      }
    }
    .task {
      await viewModel.fetchArticles()
    }
  }
}

struct ArticleRow: View {
  let article: Article
  let viewModel: ArticlesViewModel

  var body: some View {
    HStack {
      VStack {
        Text(article.title)
          .font(.title)
        Text(article.summary)
          .font(.caption)
      }
      Spacer()
      Button("", systemImage: article.isFavorite ? "star.fill" : "star") {
        viewModel.toggleFavorite(forArticleWithId: article.id)
      }
    }
  }
}

#Preview {
  ArticlesList()
}
