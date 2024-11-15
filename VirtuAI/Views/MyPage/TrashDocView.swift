import SwiftUI

struct TrashDocView: View {
    @State private var showActionSheet = false
    @State private var showDeleteAlert = false
    @State private var showRestoreAlert = false
    @State private var showDeleteBanner = false
    @State private var showRestoreBanner = false
    @State private var selectedDocument: String? = nil

    let documents = [
        "Lorem ipsum dolor.PDF",
        "Document 2.PDF",
        "Sample File 3.PDF"
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Trash")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.top)
                    .padding(.bottom, 20)
                Text("Files stored in the trash will be permanently deleted automatically after 30 days.")
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)

                List {
                    ForEach(documents, id: \.self) { document in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(document)
                                    .font(.body)
                                Text("9/22/24")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: {
                                selectedDocument = document
                                showActionSheet = true
                            }) {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .actionSheet(isPresented: $showActionSheet) {
                    ActionSheet(
                        title: Text("Options"),
                        buttons: [
                            .default(Text("Restore")) {
                                showRestoreAlert = true
                            },
                            .destructive(Text("Delete")) {
                                showDeleteAlert = true
                            },
                            .cancel()
                        ]
                    )
                }
                .alert(isPresented: $showDeleteAlert) {
                    Alert(
                        title: Text("Are you sure you want to delete?"),
                        message: Text("Files deleted from the trash cannot be restored."),
                        primaryButton: .default(Text("Back")),
                        secondaryButton: .destructive(Text("Done"), action: deleteDocument)
                    )
                }
                .alert(isPresented: $showRestoreAlert) {
                    Alert(
                        title: Text("Are you sure you want to restore?"),
                        message: Text("The restored files can be found in My Document Folder."),
                        primaryButton: .default(Text("Back")),
                        secondaryButton: .default(Text("Saved Documents"), action: restoreDocument)
                    )
                }
            }
            .navigationTitle("")
            .navigationBarBackButtonHidden(false)
            .padding(.horizontal)
            .banner(data: $showDeleteBanner, text: "The deletion is complete.")
            .banner(data: $showRestoreBanner, text: "Restoration was successful.")
        }
    }
    
    private func deleteDocument() {
        // Perform deletion logic
        showDeleteBanner = true
    }
    
    private func restoreDocument() {
        // Perform restoration logic
        showRestoreBanner = true
    }
}

extension View {
    func banner(data: Binding<Bool>, text: String) -> some View {
        self.overlay(
            VStack {
                if data.wrappedValue {
                    Text(text)
                        .font(.system(size: 14, weight: .bold))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                data.wrappedValue = false
                            }
                        }
                }
                Spacer()
            }
            .padding(.top)
        )
    }
}

struct TrashDocView_Previews: PreviewProvider {
    static var previews: some View {
        TrashDocView()
    }
}
