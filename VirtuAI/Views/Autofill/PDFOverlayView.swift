import SwiftUI

struct PDFOverlayView: View {
    let imageSize = CGSize(width: 2480, height: 3508) // Original A4 size at 300 DPI
    let scaleFactor: CGFloat = 0.89 // Scale down to fit screen size

    var body: some View {
        GeometryReader { geometry in
            let scaledWidth = geometry.size.width * scaleFactor
            let scaledHeight = geometry.size.height * scaleFactor
            VStack {
                Spacer() // Pushes the content to the center vertically
                HStack {
                    Spacer() // Pushes the content to the center horizontally
                    ZStack {
                
                        Image("af")
                            .resizable()
                            .scaledToFit()
                            .frame(width: scaledWidth, height: scaledHeight)
                            .offset(y: -15 * scaleFactor)
                        
                        Image("af_ex")
                            .resizable()
                            .scaledToFit()
                            .frame(width: scaledWidth, height: scaledHeight)
                            .blendMode(.multiply) // 흰색 부분을 투명하게 처리
                          
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    Spacer()
                }
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .edgesIgnoringSafeArea(.all) // Ensures the content stretches to the edges if needed
        }
    }
}

struct PDFOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        PDFOverlayView()
    }
}
