import SwiftUI

struct AFAutoView: View {
    let scaleFactor: CGFloat = 1
    @State private var zoomScale: CGFloat = 1.0 // Set the initial zoom scale to 1.0
    @State private var selectedBox: (title: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, text: String)?
       
    // Example values
    let exampleValues = [
        "City Plaza, 4th-7th floors, 17 Gukjegeumyung-ro 2-gil, Yeongdeungpo-gu, Seoul Special City",
        "02-1234-5677",
        "010-1234-5678",
        "5-2-1 Ginza, Chuo-ku, Tokyo, 170-3923",
        "06-1234-1234",
        "High School",
        "Fafa school",
        "06-1234-1234",
        "Unaccredited by the Office of..",
        "Fafa Inc",
        "123456789",
        "02-1234-9876",
        "",
        "",
        "5000 ten thousand won",
        "",
        "KOOKMIN, 123456-12-34566"
    ]

    var body: some View {
        GeometryReader { geometry in
            let canvasWidth: CGFloat = 298 * scaleFactor
            let canvasHeight: CGFloat = 422 * scaleFactor

            ZStack {
                Image("af")
                    .resizable()
                    .frame(width: canvasWidth, height: canvasHeight)
                    .offset(y: -30)
                    .edgesIgnoringSafeArea(.all)
                    .scaleEffect(zoomScale) // Apply zoom scale

                let boxes: [(title: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, text: String)] = [
                    ("성 Surname", 73, 145, 64, 5, "YUKI"),
                    ("명 Given names", 146, 145, 74, 5, "TANAKA"),
                    ("년 yyyy", 81, 160, 36, 5, "1987"),
                    ("월 mm", 120, 160, 12, 4, "02"),
                    ("일 dd", 140, 160, 12, 4, "01"),
                    ("남 M", 183, 153, 4, 4, "✓"),
                    ("여 F", 183, 158, 4, 4, ""),
                    ("국적 Nationality", 252, 160, 24, 21, "JAPAN"),
                    ("외국인 등록 번호 1", 97, 167, 7, 7, "J"),
                    ("외국인 등록 번호 2", 109, 167, 7, 7, "1"),
                    ("외국인 등록 번호 3", 118, 167, 7, 7, "2"),
                    ("외국인 등록 번호 4", 128, 167, 7, 7, "3"),
                    ("외국인 등록 번호 5", 138, 167, 7, 7, "7"),
                    ("외국인 등록 번호 6", 148, 167, 7, 7, "5"),
                    ("외국인 등록 번호 7", 158, 167, 7, 7, "4"),
                    ("외국인 등록 번호 8", 169, 167, 7, 7, "6"),
                    ("외국인 등록 번호 9", 176, 167, 7, 7, "7"),
                    ("외국인 등록 번호 10", 185, 167, 7, 7, "8"),
                    ("외국인 등록 번호 11", 194, 167, 7, 7, "9"),
                    ("외국인 등록 번호 12", 203, 167, 7, 7, "0"),
                    ("외국인 등록 번호 13", 211, 167, 7, 7, "0"),
                    ("여권 번호 Passport No.", 91, 180, 55, 9, "J12345678"),
                    ("여권 발급 일자 Passport Issue Date", 170, 178, 45, 8, "20290402"),
                    ("여권 유효 기간 Passport Expiry Date", 255, 178, 55, 8, "20290402"),
                    ("대한민국 내 주소", 97, 190, 243, 9, "서울시 성북구 고려대로10길 39"),
                    ("전화번호", 115, 198, 56, 6, "02-1234-5677"),
                    ("휴대전화", 240, 198, 56, 6, "010-1234-5677"),
                    ("본국 주소", 150, 206, 166, 9, "5-2-1 Ginza, Chuo-ku, Tokyo, 170-3923"),
                    ("전화번호1", 255, 206, 50, 6, "016-1234-5677"),
                    ("미취학", 82, 215, 4, 4, "✓"),
                    ("초", 108, 215, 4, 4, "✓"),
                    ("중", 125, 215, 4, 4, "✓"),
                    ("고", 140, 215, 4, 4, "✓"),
                    ("학교이름", 190, 215, 56, 9, "Fafa school"),
                    ("전화번호2", 255, 215, 50, 9, "016-7734-5677"),
                    ("교욱청인가", 187, 225, 4, 4, "✓"),
                    ("교육청비인가", 254, 225, 4, 4, "✓"),
                    ("원 근무처", 115, 240, 24, 8, "Fafa Inc"),
                    ("사업자 등록 번호1", 191, 240, 29, 8, "12345678"),
                    ("전화 번호3", 252, 240, 56, 8, "016-7734-5677"),
                    ("예정 근무처", 116, 250, 24, 8, "Fafa Inc"),
                    ("사업자 등록 번호2", 191, 250, 29, 8, "12345678"),
                    ("전화 번호4", 252, 250, 56, 8, "016-7734-5677"),
                    ("연소득금액", 115, 257, 22, 5, "5000"),
                    ("직업", 253, 257, 27, 5, "student"),
                    ("재입국신청기간", 117, 265, 29, 8, "20301212"),
                    ("email", 209, 265, 88, 5, "zypher.kr@gmail.com"),
                    ("반환용계좌번호", 221, 274, 91, 9, "KOOKMIN, 123456-12-234456"),
                    ("신청일", 130, 283, 42, 6, "20301212"),
                    ("Signature Box1", 234, 284, 36, 18, ""),
                                       ("Signature Box2", 64, 343, 36, 18, "")
                ]

                ForEach(boxes, id: \.title) { box in
                    BoxAutoView(
                        title: box.title,
                        width: box.width * scaleFactor,
                        height: box.height * scaleFactor,
                        xPosition: box.x * scaleFactor,
                        yPosition: box.y * scaleFactor - 20,
                        text: box.text,
                        isSelected: false,
                        onSelect: {
                            selectedBox = box
                        }
                    )

                }
            
        
                      if let selectedBox = selectedBox {
                          ZoomedBoxView(box: selectedBox) {
                              self.selectedBox = nil // 확대 뷰를 닫기 위해 nil로 설정
                          }
                      }
                  }
                  .frame(width: canvasWidth, height: canvasHeight)
              }
              .frame(width: 298, height: 422)
          }
}
      
struct BoxAutoView: View {
    var title: String
    var width: CGFloat
    var height: CGFloat
    var xPosition: CGFloat
    var yPosition: CGFloat
    var text: String
    var isSelected: Bool
    var onSelect: () -> Void

    var body: some View {
        ZStack {
            // 이미지가 들어갈 특정 좌표에 대해 조건 확인
                    if (xPosition == 234 && yPosition == 284 && width == 36 && height == 18) ||
                       (xPosition == 64 && yPosition == 343 && width == 36 && height == 18) {
                        // 이미지가 제대로 로드되는지 확인하기 위해 배경 색상 추가
                                      Rectangle()
                                          .fill(Color.yellow.opacity(0.3))
                                          .frame(width: width, height: height)
                                          .overlay(
                                              Image("sign") // 여기에 실제 이미지 이름
                                                  .resizable()
                                                  .scaledToFit()
                                          )
            } else {
                Text(text)
                    .font(.system(size: 5, weight: .bold))
                    .foregroundColor(.blue)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .frame(width: width, height: height)
            }
        }
        .position(x: xPosition, y: yPosition)
        .onTapGesture {
            onSelect()
        }
    }
}
struct ZoomedBoxView: View {
    var box: (title: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, text: String)
    var onClose: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: onClose) {
                    Text("닫기")
                        .padding()
                        .background(Color.red.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            Spacer()
            Text(box.text)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.blue)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 10)
            Spacer()
        }
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
    }
}
