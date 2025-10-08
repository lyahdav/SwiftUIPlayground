import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isSentByUser: Bool
}

struct ChatView: View {
    @State private var messages: [Message] = [
        Message(text: "Hello! How can I help you today?", isSentByUser: false),
        Message(text: "Can you tell me a joke?", isSentByUser: true),
        Message(text: "Sure! Why don’t scientists trust atoms? Because they make up everything!", isSentByUser: false),
        Message(text: "Can you tell me another joke?", isSentByUser: true),
    ]
    
    @State private var currentInput: String = ""
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { message in
                            HStack {
                                if message.isSentByUser {
                                    Spacer()
                                    Text(message.text)
                                        .padding()
                                        .background(Color.blue.opacity(0.8))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                        .frame(maxWidth: 250, alignment: .trailing)
                                } else {
                                    Text(message.text)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .foregroundColor(.primary)
                                        .cornerRadius(12)
                                        .frame(maxWidth: 250, alignment: .leading)
                                    Spacer()
                                }
                            }
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) {
                    if let lastID = messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            HStack {
                TextField("Type a message...", text: $currentInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
                .disabled(currentInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
    }
    
    private func sendMessage() {
        let trimmed = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        messages.append(Message(text: trimmed, isSentByUser: true))
        currentInput = ""
        
        // Simulate bot reply
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            messages.append(Message(text: "You said: \(trimmed)", isSentByUser: false))
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
