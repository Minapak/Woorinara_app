import SwiftUI

struct SavedDocView: View {
    @State private var documents: [Document] = [
        Document(name: "Lorem ipsum dolor.PDF", date: "9/22/24"),
        Document(name: "Lorem ipsum dolor.PDF", date: "9/22/24"),
        Document(name: "Lorem ipsum dolor.PDF", date: "9/22/24"),
        Document(name: "Lorem ipsum dolor.PDF", date: "9/22/24")
    ]
    @State private var showRenameAlert = false
    @State private var showDeleteAlert = false
    @State private var showBanner = false
    @State private var bannerMessage = ""
    @State private var selectedDocument: Document?
    @State private var newName: String = ""
    
    var body: some View {
        NavigationStack {
            VStack (alignment: .leading, spacing: 20) {
                Text("Saved \nDocuments")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.top)
                List {
                    ForEach(documents) { document in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(document.name)
                                    .font(.headline)
                                Text(document.date)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Menu {
                                Button("Rename") {
                                    selectedDocument = document
                                    newName = document.name
                                    showRenameAlert = true
                                }
                                Button(role: .destructive) {
                                    selectedDocument = document
                                    showDeleteAlert = true
                                } label: {
                                    Text("Delete")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .rotationEffect(.degrees(90))
                                    .padding(.trailing)
                                    .foregroundColor(.gray)
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .padding(.horizontal)
            .navigationTitle("")
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Are you sure you want to delete?"),
                    message: Text("The deleted files will be stored in the trash for 30 days."),
                    primaryButton: .destructive(Text("Done")) {
                        deleteDocument()
                    },
                    secondaryButton: .cancel(Text("Back"))
                )
            }
            .overlay(bannerView, alignment: .top)
            .sheet(isPresented: $showRenameAlert) {
                RenameDocumentView(newName: $newName, onSave: renameDocument)
            }
        }
    }
    
    // Rename Document Action
    private func renameDocument() {
        if let selected = selectedDocument, let index = documents.firstIndex(of: selected) {
            documents[index].name = newName
            showSuccessBanner(with: "The name change has been completed")
        }
    }
    
    // Delete Document Action
    private func deleteDocument() {
        if let selected = selectedDocument {
            documents.removeAll { $0.id == selected.id }
            showSuccessBanner(with: "The deletion is complete")
        }
    }
    
    // Show Banner with Message
    private func showSuccessBanner(with message: String) {
        bannerMessage = message
        showBanner = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showBanner = false
        }
    }
    
    // Banner View
    private var bannerView: some View {
        Group {
            if showBanner {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                    Text(bannerMessage)
                        .font(.body)
                        .bold()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .transition(.move(edge: .top))
            }
        }
    }
}

// Document Model
struct Document: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var date: String
}

// Rename Document View as a Custom Sheet
struct RenameDocumentView: View {
    @Binding var newName: String
    var onSave: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Please enter the new name for the file.")
                    .font(.headline)
                    .padding()
                
                TextField("New Document Name", text: $newName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Save") {
                    onSave()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding()
                
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                .padding(.bottom)
            }
            .padding()
            .navigationTitle("Rename")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SavedDocView_Previews: PreviewProvider {
    static var previews: some View {
        SavedDocView()
    }
}
