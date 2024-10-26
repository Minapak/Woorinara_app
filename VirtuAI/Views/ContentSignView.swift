import SwiftUI
import SwiftUIDigitalSignature

struct ContentSignView: View {
    @State private var image: UIImage? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink("Sign Here", destination: SignatureView(
                    availableTabs: [.draw, .image, .type],
                    onSave: { savedImage in
                        self.image = savedImage
                    },
                    onCancel: {
                        print("Signature canceled")
                    }
                ))
                
                if let savedImage = image {
                    Image(uiImage: savedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 100)
                }
            }
        }
    }
}

struct ContentSignView_Previews: PreviewProvider {
    static var previews: some View {
        ContentSignView()
    }
}
