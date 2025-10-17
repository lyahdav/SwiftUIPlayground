import SwiftUI

// MARK: - View Model
@MainActor
@Observable
final class PaginatedItemsViewModel {
  private(set) var items: [String] = []
  private(set) var isLoadingPage = false
  private(set) var reachedEnd = false
  var errorMessage: String? = nil

  private var currentPage: Int = 0
  private let pageSize: Int = 20
  private let maxPages: Int = 5  // Simulate a finite data source (100 items)

  init() {
    // Preload first page
    Task { await loadNextPageIfNeeded(currentItemIndex: nil) }
  }

  func refresh() async {
    // Reset state and load first page again
    currentPage = 0
    reachedEnd = false
    errorMessage = nil
    items.removeAll()
    await loadNextPage()
  }

  func loadNextPageIfNeeded(currentItemIndex: Int?) async {
    guard !isLoadingPage, !reachedEnd else { return }
    // Only trigger when the user reaches close to the bottom or on first load
    if currentItemIndex == nil || isNearBottom(currentItemIndex: currentItemIndex) {
      await loadNextPage()
    }
  }

  private func isNearBottom(currentItemIndex: Int?) -> Bool {
    guard let idx = currentItemIndex else { return true }
    // When the visible item is within the last 5 items, consider it near bottom
    return idx >= items.count - 5
  }

  private func loadNextPage() async {
    guard !isLoadingPage, !reachedEnd else { return }
    isLoadingPage = true
    defer { isLoadingPage = false }

    do {
      // Simulate a small network delay
      try await Task.sleep(nanoseconds: 700_000_000)  // 0.7s

      guard currentPage < maxPages else {
        reachedEnd = true
        return
      }

      let nextPage = currentPage + 1
      let start = (nextPage - 1) * pageSize + 1
      let end = start + pageSize - 1
      let newItems = (start...end).map { "Item \($0)" }

      // Append results
      items.append(contentsOf: newItems)
      currentPage = nextPage

      if currentPage >= maxPages {
        reachedEnd = true
      }
    } catch {
      errorMessage = "Failed to load data. Please try again."
    }
  }
}

// MARK: - View
struct PaginationExample: View {
  private var viewModel = PaginatedItemsViewModel()

  var body: some View {
    List {
      ForEach(Array(viewModel.items.enumerated()), id: \.element) { index, item in
        Text(item)
          .onAppear {
            Task { await viewModel.loadNextPageIfNeeded(currentItemIndex: index) }
          }
      }

      footerView
    }
    .overlay(alignment: .center) {
      if viewModel.items.isEmpty && viewModel.isLoadingPage {
        ProgressView("Loading...")
      }
    }
    .refreshable {
      await viewModel.refresh()
    }
    .animation(.default, value: viewModel.items)
    .navigationTitle("Pagination")
    .alert(
      "Error",
      isPresented: .constant(viewModel.errorMessage != nil),
      presenting: viewModel.errorMessage
    ) { _ in
      Button("OK") { viewModel.errorMessage = nil }
    } message: { message in
      Text(message)
    }
  }

  @ViewBuilder
  private var footerView: some View {
    if viewModel.isLoadingPage && !viewModel.items.isEmpty {
      HStack {
        Spacer()
        ProgressView().padding(.vertical, 12)
        Spacer()
      }
      .listRowSeparator(.hidden)
      // Required because otherwise it'll use index as id which changes as new items are inserted
      .id("FooterView - \(viewModel.items.count)")
    } else if viewModel.reachedEnd && !viewModel.items.isEmpty {
      HStack {
        Spacer()
        Text("No more items")
          .foregroundStyle(.secondary)
          .padding(.vertical, 12)
        Spacer()
      }
      .listRowSeparator(.hidden)
    } else {
      EmptyView()
    }
  }
}

#Preview("PaginationExample") {
  NavigationStack {
    PaginationExample()
  }
}
