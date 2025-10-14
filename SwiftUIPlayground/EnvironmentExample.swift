import SwiftUI

@Observable class Session {

  var username: String = "default username"
}

struct EnvironmentExample: View {
  @Environment(Session.self) private var session

  var body: some View {
        Text("Hello, \(session.username.isEmpty ? "World" : session.username)!")
    }
}

struct EnvironmentExampleWrapper: View {
  var body: some View {
    EnvironmentExample()
      .environment(Session())
  }
}

#Preview {
    EnvironmentExampleWrapper()
}
