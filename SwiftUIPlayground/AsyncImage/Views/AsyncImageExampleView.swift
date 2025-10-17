import SwiftUI

struct AsyncImageExampleView: View {
  @State var viewModel = AsyncImageExampleViewModel()

  var body: some View {
    ZStack {
      if viewModel.isLoading {
        LoadingView()
          .transition(.opacity)
      } else if let error = viewModel.error {
        ErrorView(error: error, onRetry: viewModel.retry)
      } else {
        List(viewModel.photos) { photo in
          PhotoCellView(photo: photo)
        }
      }
    }
    .task { await viewModel.fetch() }
  }
}

#Preview {
  AsyncImageExampleView()
}
