import SwiftUI

enum ArticlesListError: String, Error {
  case networkError = "Network error, try again"
}

struct Article: Identifiable {
  let id: String
  let title: String
  let summary: String
}

protocol ArticlesServiceProtocol {
  func fetchArticles() async throws -> [Article]
}

class MockErrorArticlesService: ArticlesServiceProtocol {
  func fetchArticles() async throws -> [Article] {
    throw ArticlesListError.networkError
  }
}

class ArticlesService: ArticlesServiceProtocol {
  func fetchArticles() async throws -> [Article] {
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
  let articlesService: ArticlesServiceProtocol
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

  @ObservationIgnored @AppStorage("articleFavoriteData") private var articleFavoritesData = Data()

  init(articlesService: ArticlesServiceProtocol = ArticlesService()) {
    self.articlesService = articlesService
  }

  func getArticleFavorites() -> [String: Bool] {
    if let decoded = try? JSONDecoder().decode([String: Bool].self, from: articleFavoritesData) {
      return decoded
    }
    return [:]  // default empty dictionary
  }

  private func saveArticleFavoriteDataToStorage() {
    if let encoded = try? JSONEncoder().encode(articleFavorites) {
      articleFavoritesData = encoded
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

  func errorTextFor(_ error: Error) -> String {
    let details = {
      if let error = error as? ArticlesListError {
        error.rawValue
      } else {
        error.localizedDescription
      }
    }()

    return "⚠️ Error:\n\(details)"
  }
}

enum Filter: String, CaseIterable {
  case all = "All"
  case favorites = "Favorites"
}

struct ArticlesList: View {
  @State private var viewModel: ArticlesViewModel

  init(initialViewModel: ArticlesViewModel = ArticlesViewModel()) {
    _viewModel = State(initialValue: initialViewModel)
  }

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
        VStack(alignment: .center) {
          Spacer()
          Text(viewModel.errorTextFor(error))
            .multilineTextAlignment(.center)
          Spacer()
        }

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

#Preview {
  ArticlesList(initialViewModel: ArticlesViewModel(articlesService: MockErrorArticlesService()))
}
