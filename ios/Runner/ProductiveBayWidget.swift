import WidgetKit
import SwiftUI

// MARK: - Productive Bay Widget
struct ProductiveBayProvider: TimelineProvider {
    func placeholder(in context: Context) -> ImageEntry {
        ImageEntry(date: Date(), imagePath: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (ImageEntry) -> ()) {
        completion(ImageEntry(date: Date(), imagePath: nil))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ImageEntry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.example.meducyte_app")
        let imagePath = userDefaults?.string(forKey: "schedule_image_path")
        
        let entry = ImageEntry(date: Date(), imagePath: imagePath)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct ImageEntry: TimelineEntry {
    let date: Date
    let imagePath: String?
}

struct ProductiveBayWidgetView : View {
    var entry: ProductiveBayProvider.Entry

    var body: some View {
        Group {
            if let path = entry.imagePath, let uiImage = UIImage(contentsOfFile: path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                VStack {
                    Text("Meducyte")
                        .font(.headline)
                    Text("Syncing data...")
                        .font(.caption)
                }
            }
        }
        .containerBackground(.white, for: .widget)
    }
}

struct ProductiveBayWidget: Widget {
    let kind: String = "ProductiveBayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProductiveBayProvider()) { entry in
            ProductiveBayWidgetView(entry: entry)
        }
        .configurationDisplayName("Study Schedule")
        .description("Your clinical sessions synced from the app.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Study Stats Widget
struct StudyStatsProvider: TimelineProvider {
    func placeholder(in context: Context) -> ImageEntry {
        ImageEntry(date: Date(), imagePath: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (ImageEntry) -> ()) {
        completion(ImageEntry(date: Date(), imagePath: nil))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ImageEntry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.example.meducyte_app")
        let imagePath = userDefaults?.string(forKey: "stats_image_path")
        
        let entry = ImageEntry(date: Date(), imagePath: imagePath)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct StudyStatsWidgetView : View {
    var entry: StudyStatsProvider.Entry

    var body: some View {
        Group {
            if let path = entry.imagePath, let uiImage = UIImage(contentsOfFile: path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                VStack {
                    Text("Analytics")
                        .font(.headline)
                    Text("Loading stats...")
                        .font(.caption)
                }
            }
        }
        .containerBackground(.white, for: .widget)
    }
}

struct StudyStatsWidget: Widget {
    let kind: String = "StudyStatsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StudyStatsProvider()) { entry in
            StudyStatsWidgetView(entry: entry)
        }
        .configurationDisplayName("Academic Stats")
        .description("Your exams and goals synced from the app.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Bundle
@main
struct MeducyteWidgetBundle: WidgetBundle {
    var body: some Widget {
        ProductiveBayWidget()
        StudyStatsWidget()
    }
}
