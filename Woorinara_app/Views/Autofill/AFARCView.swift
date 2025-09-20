import SwiftUI

struct AFARCView: View {
    let scaleFactor: CGFloat = 1
    var data: [String: String]
    @State private var zoomScale: CGFloat = 1.0

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
                
                // Data fields and positions
                let boxes: [(title: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, text: String)] = [
                    ("명 Given names", 139, 145, 74, 5, data["name"] ?? ""),
                    ("년 yyyy", 78, 160, 36, 5, getBirthYear(from: data["dateOfBirth"] ?? "")),
                    ("월 mm", 120, 160, 12, 4, getBirthMonth(from: data["dateOfBirth"] ?? "")),
                    ("일 dd", 140, 160, 12, 4, getBirthDay(from: data["dateOfBirth"] ?? "")),
                    ("남 M", 183, 153, 4, 4, data["gender"] == "M" ? "✓" : ""),
                    ("여 F", 183, 158, 4, 4, data["gender"] == "F" ? "✓" : ""),
                    ("국적 Nationality", 245, 153, 24, 21, data["nationality"] ?? ""),
                    ("비자 visa", 248, 178, 55, 8, data["visa"] ?? "")
                ]
                
                // Display each box with the appropriate coordinates and text
                ForEach(boxes, id: \.title) { box in
                    BoxARCView(
                        title: box.title,
                        width: box.width * scaleFactor,
                        height: box.height * scaleFactor,
                        xPosition: box.x * scaleFactor,
                        yPosition: (box.y * scaleFactor) - 20,
                        text: box.text,
                        isSelected: false,
                        onSelect: { }
                    )
                }
                
                // Display each character of 외국인 등록 번호 separately
                if let alienRegNum = data["alienRegNum"], alienRegNum.count == 13 {
                    let xOffsets: [CGFloat] = [97, 109, 118, 128, 138, 148, 158, 169, 176, 185, 194, 203, 211]
                    ForEach(Array(alienRegNum.enumerated()), id: \.offset) { (index, character) in
                        BoxARCView(
                            title: "외국인 등록 번호 \(index + 1)",
                            width: 7 * scaleFactor,
                            height: 7 * scaleFactor,
                            xPosition: xOffsets[index] * scaleFactor,
                            yPosition: 167 * scaleFactor,
                            text: String(character),
                            isSelected: false,
                            onSelect: { }
                        )
                    }
                }
            }
            .frame(width: canvasWidth, height: canvasHeight)
            .scaleEffect(zoomScale)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        zoomScale = value.magnitude
                    }
            )
        }
        .frame(width: 298, height: 422)
    }
    
    private func getBirthYear(from date: String) -> String {
        return String(date.prefix(4))
    }
    
    private func getBirthMonth(from date: String) -> String {
        return String(date.dropFirst(4).prefix(2))
    }
    
    private func getBirthDay(from date: String) -> String {
        return String(date.suffix(2))
    }
}

struct BoxARCView: View {
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
            if title == "국적 Nationality" {
                Text(text)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.blue)
                    .lineLimit(nil)
                    .fixedSize(horizontal: true, vertical: true)
                    .multilineTextAlignment(.leading)
                    .frame(width: width, alignment: .leading)
            } else {
                Text(text)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.blue)
                    .frame(width: width, height: height)
            }
        }
        .position(x: xPosition, y: yPosition)
        .onTapGesture {
            onSelect()
        }
    }
}
