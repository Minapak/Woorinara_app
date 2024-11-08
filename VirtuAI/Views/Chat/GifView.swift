//import SwiftUI
//import Lottie
//
//struct GifView: UIViewRepresentable {
//    var animationName: String
//    var loopMode: LottieLoopMode = .loop
//
//    func makeUIView(context: UIViewRepresentableContext<GifView>) -> UIView {
//        let view = UIView(frame: .zero)
//        
//        let animationView = LottieAnimationView(name: animationName)
//        animationView.contentMode = .scaleAspectFit
//        animationView.loopMode = loopMode
//        animationView.play()
//        
//        animationView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(animationView)
//        
//        NSLayoutConstraint.activate([
//            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
//            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
//        ])
//        
//        return view
//    }
//
//    func updateUIView(_ uiView: UIView, context: Context) {
//        // 업데이트가 필요할 때 처리
//    }
//}
//
//struct ContentGifView: View {
//    var body: some View {
//        HStack {
//                   Image("chatLogo")
//                       .resizable()
//                       .scaledToFit()
//                       .frame(width: 32, height: 32)
//
//                   ZStack {
//                       // Background with specified color and size
//                       Color(hex: "#C2DBFF")
//                           .frame(width: 58, height: 32)
//                           .cornerRadius(24)
//
//                       GifView(animationName: "loading")
//                           .frame(width: 26, height: 8)
//                   }
//                   .padding()
//
//                   Spacer()
//               }
//    }
//}
//
//
//
