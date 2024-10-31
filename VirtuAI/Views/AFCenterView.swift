//
//  AFCenterView.swift
//  Example
//
//  Created by 박은민 on 10/31/24.
//

import SwiftUI

struct AFCenterView: View {
    let scaleFactor: CGFloat = 1
    var passportData: [String: String]
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
                
                let boxes: [(title: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, text: String)] = [
                    ("성 Surname", 69, 145, 64, 5, passportData["surName"] ?? ""),
                    ("명 Given names", 139, 145, 74, 5, passportData["givenName"] ?? ""),
                    ("년 yyyy", 78, 160, 36, 5, getBirthYear(from: passportData["dateOfBirth"] ?? "")),
                    ("월 mm", 120, 160, 12, 4, getBirthMonth(from: passportData["dateOfBirth"] ?? "")),
                    ("일 dd", 140, 160, 12, 4, getBirthDay(from: passportData["dateOfBirth"] ?? "")),
                    ("남 M", 183, 153, 4, 4, passportData["gender"] == "M" ? "✓" : ""),
                    ("여 F", 183, 158, 4, 4, passportData["gender"] == "F" ? "✓" : ""),
                    ("국적 Nationality", 245, 153, 24, 21, passportData["nationality"] ?? ""),
                    ("여권 번호 Passport No.", 78, 180, 55, 9, passportData["documentNumber"] ?? ""),
                    ("여권 유효 기간 Passport Expiry Date", 248, 178, 55, 8, passportData["dateOfExpiry"] ?? "")
                ]

                ForEach(boxes, id: \.title) { box in
                    BoxCenterView(
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

struct BoxCenterView: View {
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
                    .fixedSize(horizontal:  true, vertical: true)
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
