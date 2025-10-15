import SwiftUI

// Object to be stored in environment
@Observable class Session {
  var username: String = "default username"
}

// Old API
private struct FavoriteColorKey: EnvironmentKey {
  static let defaultValue: Color = .blue
}

extension EnvironmentValues {
  // Old API
  var favoriteColor: Color {
    get { self[FavoriteColorKey.self] }
    set { self[FavoriteColorKey.self] = newValue }
  }

  // New API
  @Entry var altColor: Color = .yellow
}

struct EnvironmentExample: View {
  // Reading environment variable by type
  @Environment(Session.self) private var session

  // Reading environment variables by keypath
  @Environment(\.favoriteColor) private var favoriteColor
  @Environment(\.altColor) private var altColor

  var body: some View {
    Text("Hello, \(session.username.isEmpty ? "World" : session.username)!")
      .foregroundStyle(favoriteColor)
    Text("Alt color").background(altColor)
  }
}

struct EnvironmentExampleWrapper: View {
  @Environment(\.altColor) private var altColor

  var body: some View {
    Text("Reading alt color default value")
      .background(altColor)
    EnvironmentExample()
      // Setting environment variable by type
      .environment(Session())

      // Setting environment variables by keypath
      .environment(\.favoriteColor, .green)
      .environment(\.altColor, .red)
  }
}

#Preview {
  EnvironmentExampleWrapper()
}
