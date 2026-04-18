import SwiftUI
import WebKit

struct ITVideo: Identifiable {
    let id = UUID()
    let videoId: String
    let title: String
    let channel: String
    let duration: String
    let topic: String
}

private let itVideos: [ITVideo] = [
    ITVideo(
        videoId: "zOjov-2OZ0E",
        title: "Docker за 100 секунд",
        channel: "Fireship",
        duration: "1:54",
        topic: "DevOps"
    ),
    ITVideo(
        videoId: "RGOj5yH7evk",
        title: "Git и GitHub для начинающих",
        channel: "freeCodeCamp",
        duration: "1:08:29",
        topic: "Git"
    ),
    ITVideo(
        videoId: "HXV3zeQKqGY",
        title: "SQL — полный курс для начинающих",
        channel: "freeCodeCamp",
        duration: "4:20:38",
        topic: "Базы данных"
    ),
    ITVideo(
        videoId: "Oe421EPjeBE",
        title: "Node.js и Express — полный курс",
        channel: "freeCodeCamp",
        duration: "8:16:47",
        topic: "Backend"
    ),
    ITVideo(
        videoId: "nu_pCVPKzTk",
        title: "Нотация Big O — объяснение за 15 минут",
        channel: "NeetCode",
        duration: "15:06",
        topic: "Алгоритмы"
    ),
    ITVideo(
        videoId: "SqcY0GlETPk",
        title: "React за 100 секунд",
        channel: "Fireship",
        duration: "1:53",
        topic: "Frontend"
    ),
    ITVideo(
        videoId: "x7X9w_GIm1s",
        title: "Kubernetes объяснён просто",
        channel: "TechWorld with Nana",
        duration: "5:53",
        topic: "DevOps"
    ),
    ITVideo(
        videoId: "GKy7QLjnIT4",
        title: "REST API — полное введение",
        channel: "IBM Technology",
        duration: "9:29",
        topic: "API"
    ),
    ITVideo(
        videoId: "qibjQDlCJaM",
        title: "Паттерны проектирования — объяснение",
        channel: "Fireship",
        duration: "11:48",
        topic: "Архитектура"
    ),
    ITVideo(
        videoId: "UGu9unCW9ek",
        title: "Как работает интернет",
        channel: "TED-Ed",
        duration: "5:08",
        topic: "Сети"
    )
]

struct VideosView: View {
    @State private var selectedVideo: ITVideo? = nil

    var body: some View {
        NavigationView {
            List(itVideos) { video in
                VideoRow(video: video)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedVideo = video
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .navigationTitle("Образование")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(.stack)
        .fullScreenCover(item: $selectedVideo) { video in
            VideoPlayerView(video: video, onClose: { selectedVideo = nil })
        }
    }
}

struct VideoRow: View {
    let video: ITVideo

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: "https://img.youtube.com/vi/\(video.videoId)/mqdefault.jpg")) { image in
                    image
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "play.rectangle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.gray.opacity(0.5))
                        )
                }
                .frame(width: 140, height: 80)
                .clipped()
                .cornerRadius(8)

                Text(video.duration)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.75))
                    .cornerRadius(4)
                    .padding(5)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(video.channel)
                    .font(.caption)
                    .foregroundColor(.secondary)

                TopicBadge(text: video.topic)
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct TopicBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.accentColor.opacity(0.15))
            .foregroundColor(.accentColor)
            .cornerRadius(6)
    }
}

struct VideoPlayerView: View {
    let video: ITVideo
    let onClose: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                YouTubePlayerView(videoId: video.videoId)
                    .aspectRatio(16/9, contentMode: .fit)
                    .background(Color.black)

                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        TopicBadge(text: video.topic)

                        Text(video.title)
                            .font(.title3)
                            .fontWeight(.bold)

                        HStack(spacing: 4) {
                            Image(systemName: "person.crop.circle")
                                .foregroundColor(.secondary)
                            Text(video.channel)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: "clock")
                                .foregroundColor(.secondary)
                            Text(video.duration)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(16)
                }

                Spacer()
            }
            .navigationTitle(video.channel)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть", action: onClose)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct YouTubePlayerView: UIViewRepresentable {
    let videoId: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let embedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          * { margin: 0; padding: 0; background: black; }
          iframe { width: 100%; height: 100vh; border: none; }
        </style>
        </head>
        <body>
        <iframe src="https://www.youtube.com/embed/\(videoId)?playsinline=1&rel=0"
                allowfullscreen allow="autoplay"></iframe>
        </body>
        </html>
        """
        webView.loadHTMLString(embedHTML, baseURL: URL(string: "https://youtube.com"))
    }
}

#Preview {
    VideosView()
}
