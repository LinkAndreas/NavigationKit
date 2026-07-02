import SwiftUI

struct MailView: View {
    let email: String
    let subject: String
    let onDismiss: () -> Void
    
    @State private var messageBody: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("to")
                    .foregroundColor(.secondary)
                    .frame(width: 70, alignment: .leading)
                Text(email)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            Divider()
                .padding(.leading, 16)
            
            HStack {
                Text("ccbcc")
                    .foregroundColor(.secondary)
                    .frame(width: 70, alignment: .leading)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            Divider()
                .padding(.leading, 16)
            
            HStack {
                Text("subject")
                    .foregroundColor(.secondary)
                    .frame(width: 70, alignment: .leading)
                Text(subject)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            Divider()
                .padding(.leading, 16)
            
            TextEditor(text: $messageBody)
                .padding()
        }
        .navigationTitle("new_message")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("cancel") {
                    onDismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    onDismiss()
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
        }
    }
}
