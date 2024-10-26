//
//  AiWidget.swift
//  AiWidget
//
//  Created by Murat ÖZTÜRK on 19.12.2023.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), emoji: "😀")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, emoji: "😀")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
}

struct AiWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        HStack {
   
                HStack(){
                    Image("AppVectorIcon")
                        .resizable().scaledToFill()
                        .frame(width: 35, height: 35)
                    
                    Text("Ask me anything...").foregroundColor(Color("TextColor")).modifier(UrbanistFont(.bold, size: 14))
                    
                    Spacer()
                    
                    Image("Send")
                        .resizable().scaledToFill()
                        .frame(width: 30, height: 30)
                        .foregroundColor( Color("Green"))
                    
                    }
                    .padding(10)
                    .background(Color("Gray")).cornerRadius(99)
                    .shadow(radius: 8, x: 0, y: 5)


        }
    }
}

enum UrbanistFontType: String {
    case black = "urbanis-black"
    case bold = "urbanist-bold"
    case extra_bold = "UrbanistExtraBold"
    case extra_light = "urbanist-extra-light"
    case italic = "urbanist-italic"
    case light = "urbanist-light"
    case medium = "urbanist-medium"
    case regular = "urbanist-regular"
    case semi_bold = "Urbanist-SemiBold"
    case thin = "urbanist-thin"
}

struct UrbanistFont: ViewModifier {
    
    var type: UrbanistFontType
    var size: CGFloat
    
    init(_ type: UrbanistFontType = .regular, size: CGFloat = 16) {
        self.type = type
        self.size = size
    }
    
    func body(content: Content) -> some View {
        content.font(Font.custom(type.rawValue, size: size))
    }
}




struct AiWidget: Widget {
    let kind: String = "AiWidget"
    

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                AiWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                AiWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("VirtuAI")
        .description("VirtuAI ChatGPT widget.")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemSmall) {
    AiWidget()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
    SimpleEntry(date: .now, emoji: "🤩")
}
