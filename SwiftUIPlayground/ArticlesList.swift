import SwiftUI

struct Article: Identifiable {
  let id: String
  let title: String
  let summary: String
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
  case loaded([Article])
}

@Observable
class ArticlesViewModel {
  let articlesService = ArticlesService()
  var state: ArticlesListState = .loading
  var selectedFilter: Filter = .all
  var articleFavorites: [String: Bool] = [:]

  var filteredArticles: [Article] {
    guard case let .loaded(articles) = state else { return [] }
    switch selectedFilter {
    case .all:
      return articles
    case .favorites:
      return articles.filter { articleFavorites[$0.id] == true }
    }
  }

  @ObservationIgnored @AppStorage("articleFavoriteData") private var articleFavoriteData = Data()

  func getArticleFavorites() -> [String: Bool] {
    if let decoded = try? JSONDecoder().decode([String: Bool].self, from: articleFavoriteData) {
      return decoded
    }
    return [:]  // default empty dictionary
  }

  private func saveArticleFavoriteDataToStorage() {
    if let encoded = try? JSONEncoder().encode(articleFavorites) {
      articleFavoriteData = encoded
    }
  }

  func isFavorite(article: Article) -> Bool {
    return articleFavorites[article.id, default: false]
  }

  func fetchArticles() async {
    do {
      let articles = try await articlesService.fetchArticles()
      articleFavorites = getArticleFavorites()
      state = .loaded(articles)
    } catch {
      state = .error(error)
    }
  }

  func toggleFavorite(forArticleWithId id: String) {
    articleFavorites[id, default: false].toggle()
    saveArticleFavoriteDataToStorage()
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
      Button("", systemImage: viewModel.isFavorite(article: article) ? "star.fill" : "star") {
        viewModel.toggleFavorite(forArticleWithId: article.id)
      }
    }
  }
}

#Preview {
  ArticlesList()
}
