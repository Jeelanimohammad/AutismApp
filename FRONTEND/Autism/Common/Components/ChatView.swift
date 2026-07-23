import SwiftUI

struct ChatView: View {
    let currentUserRole: String // "doctor" or "patient"
    let currentUserID: String
    let otherUserID: String
    let otherUserName: String
    
    @State private var messages: [Message] = []
    @State private var newMessage: String = ""
    @State private var isLoading = true
    @State private var isOtherUserOnline = false
    @State private var timer: Timer?
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(otherUserName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(isOtherUserOnline ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)
                        
                        Text(isOtherUserOnline ? "Online" : "Offline")
                            .font(.caption)
                            .foregroundColor(isOtherUserOnline ? .green : .gray)
                    }
                }
                Spacer()
                
                Button(action: fetchMessages) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 5)
            
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if isLoading && messages.isEmpty {
                            ProgressView()
                                .padding()
                        } else {
                            ForEach(messages) { message in
                                MessageBubble(
                                    text: message.message_text,
                                    isCurrentUser: message.sender_id == currentUserID,
                                    time: formatTime(message.created_at)
                                )
                                .id(message.id)
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { old, newValue in
                    if let lastId = messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    if let lastId = messages.last?.id {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
            
            // Input Area
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $newMessage)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .focused($isFocused)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(newMessage.isEmpty ? Color.gray : Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(newMessage.isEmpty)
                }
                .padding()
                .background(Color(.systemBackground))
            }
        }
        .navigationTitle("")
        .onAppear {
            fetchMessages()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func fetchMessages() {
        NetworkManager.shared.getMessages(user1: currentUserID, user2: otherUserID, role: currentUserRole) { result in
            isLoading = false
            if case .success(let response) = result {
                if let msgs = response.messages {
                    self.messages = msgs
                }
                if let online = response.is_online {
                    self.isOtherUserOnline = online
                }
            }
        }
    }
    
    private func sendMessage() {
        let text = newMessage
        newMessage = ""
        isFocused = false
        
        let params: [String: AnyEncoded] = [
            "sender_id": AnyEncoded(currentUserID),
            "receiver_id": AnyEncoded(otherUserID),
            "sender_role": AnyEncoded(currentUserRole),
            "message_text": AnyEncoded(text)
        ]
        
        NetworkManager.shared.sendMessage(parameters: params) { result in
            if case .success(let response) = result, response.success {
                fetchMessages()
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            fetchMessages()
        }
    }
    
    private func formatTime(_ dateString: String) -> String {
        // Simple extraction of HH:mm from "YYYY-MM-DD HH:mm:ss"
        let parts = dateString.split(separator: " ")
        if parts.count >= 2 {
            let timeParts = parts[1].split(separator: ":")
            if timeParts.count >= 2 {
                return "\(timeParts[0]):\(timeParts[1])"
            }
        }
        return ""
    }
}

struct MessageBubble: View {
    let text: String
    let isCurrentUser: Bool
    let time: String
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(isCurrentUser ? Color.blue : Color(.systemGray5))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .clipShape(BubbleShape(isCurrentUser: isCurrentUser))
                
                Text(time)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            
            if !isCurrentUser { Spacer() }
        }
    }
}

struct BubbleShape: Shape {
    let isCurrentUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [
            .topLeft, .topRight, isCurrentUser ? .bottomLeft : .bottomRight
        ], cornerRadii: CGSize(width: 16, height: 16))
        return Path(path.cgPath)
    }
}
