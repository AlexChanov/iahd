//
//  VaultView.swift
//  iahd
//

import SwiftUI
import PhotosUI
import AVKit
import AVFoundation
import Photos

// MARK: - VaultView

struct MediaSelection: Identifiable {
    let id = UUID()
    let index: Int
}

struct VaultView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vault = VaultManager.shared

    @State private var showingPicker = false
    @State private var mediaSelection: MediaSelection?
    @State private var isImporting = false

    private let columns = [GridItem(.adaptive(minimum: 110), spacing: 2)]

    var body: some View {
        NavigationView {
            Group {
                if vault.items.isEmpty {
                    emptyState
                } else {
                    mediaGrid
                }
            }
            .navigationTitle("Хранилище")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingPicker = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.orange.gradient)
                    }
                    .disabled(isImporting)
                }
            }
            .sheet(isPresented: $showingPicker) {
                MediaPicker { images, videoURLs in
                    guard !images.isEmpty || !videoURLs.isEmpty else { return }
                    isImporting = true
                    Task.detached(priority: .userInitiated) {
                        for image in images {
                            VaultManager.shared.savePhoto(image)
                        }
                        for url in videoURLs {
                            VaultManager.shared.saveVideo(from: url)
                            try? FileManager.default.removeItem(at: url)
                        }
                        await MainActor.run { isImporting = false }
                    }
                }
            }
            .fullScreenCover(item: $mediaSelection) { selection in
                MediaDetailView(items: vault.items, startIndex: selection.index)
            }
            .overlay {
                if isImporting {
                    Color.black.opacity(0.45).ignoresSafeArea()
                    VStack(spacing: 14) {
                        ProgressView()
                            .scaleEffect(1.6)
                            .tint(.white)
                        Text("Сохранение...")
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                    }
                    .padding(32)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64))
                .foregroundStyle(.orange.gradient)

            Text("Хранилище пусто")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Нажмите + чтобы добавить\nфото или видео из галереи")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var mediaGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(Array(vault.items.enumerated()), id: \.element.id) { index, item in
                    ThumbnailView(item: item)
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                        .onTapGesture {
                            mediaSelection = MediaSelection(index: index)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                vault.delete(item)
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }
}

// MARK: - ThumbnailView

struct ThumbnailView: View {
    let item: VaultItem
    @State private var thumbnail: UIImage?

    var body: some View {
        ZStack {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
            } else {
                Color(.systemGray5)
                ProgressView()
            }

            if item.type == .video {
                LinearGradient(
                    colors: [.clear, .black.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 4)
            }
        }
        .frame(minHeight: 110)
        .onAppear { generateThumbnail() }
    }

    private func generateThumbnail() {
        guard thumbnail == nil else { return }
        let url = VaultManager.shared.fileURL(for: item)

        DispatchQueue.global(qos: .userInitiated).async {
            let image: UIImage?
            if item.type == .photo {
                image = UIImage(contentsOfFile: url.path)
            } else {
                let asset = AVAsset(url: url)
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                generator.maximumSize = CGSize(width: 300, height: 300)
                image = (try? generator.copyCGImage(at: .zero, actualTime: nil))
                    .map { UIImage(cgImage: $0) }
            }
            DispatchQueue.main.async { thumbnail = image }
        }
    }
}

// MARK: - MediaDetailView

struct MediaDetailView: View {
    let items: [VaultItem]
    let startIndex: Int

    @Environment(\.dismiss) var dismiss
    @State private var currentIndex: Int
    @State private var isSaving = false
    @State private var saveResult: SaveResult?

    init(items: [VaultItem], startIndex: Int) {
        self.items = items
        self.startIndex = startIndex
        self._currentIndex = State(initialValue: startIndex)
    }

    var currentItem: VaultItem { items[currentIndex] }

    enum SaveResult: Identifiable {
        case success, failure(String)
        var id: String {
            switch self {
            case .success: return "ok"
            case .failure(let m): return m
            }
        }
    }

    var body: some View {
        NavigationView {
            MediaPagerView(items: items, currentIndex: $currentIndex)
                .ignoresSafeArea()
                .background(Color.black.ignoresSafeArea())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 26))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, .white.opacity(0.25))
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            saveToGallery()
                        } label: {
                            if isSaving {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "square.and.arrow.down")
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(isSaving)
                    }
                }
                .toolbarBackground(.black.opacity(0.6), for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear { activateAudioSession() }
        .onDisappear { deactivateAudioSession() }
        .alert(item: $saveResult) { result in
            switch result {
            case .success:
                Alert(
                    title: Text("Сохранено"),
                    message: Text("Файл сохранён в Фото"),
                    dismissButton: .default(Text("OK"))
                )
            case .failure(let message):
                Alert(
                    title: Text("Ошибка"),
                    message: Text(message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func saveToGallery() {
        isSaving = true
        let fileURL = VaultManager.shared.fileURL(for: currentItem)
        let type = currentItem.type

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized else {
                DispatchQueue.main.async {
                    isSaving = false
                    saveResult = .failure("Нет разрешения на сохранение в Фото. Откройте Настройки → iahd → Фото.")
                }
                return
            }
            PHPhotoLibrary.shared().performChanges({
                if type == .photo {
                    PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileURL)
                } else {
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
                }
            }) { success, error in
                DispatchQueue.main.async {
                    isSaving = false
                    saveResult = success ? .success : .failure(error?.localizedDescription ?? "Не удалось сохранить")
                }
            }
        }
    }

    private func activateAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    private func deactivateAudioSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

// MARK: - MediaPagerView
//
// UIPageViewController правильно разграничивает свои жесты с AVPlayerViewController:
// его внутренний UIScrollView умеет отличать быстрый свайп (навигация)
// от медленного горизонтального перетаскивания по скрабберу (перемотка).

struct MediaPagerView: UIViewControllerRepresentable {
    let items: [VaultItem]
    @Binding var currentIndex: Int

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pvc = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: [.interPageSpacing: 16]
        )
        pvc.view.backgroundColor = .black
        pvc.dataSource = context.coordinator
        pvc.delegate = context.coordinator

        let initial = context.coordinator.viewController(at: currentIndex)
        pvc.setViewControllers([initial], direction: .forward, animated: false)
        return pvc
    }

    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(items: items, currentIndex: $currentIndex)
    }

    // MARK: Coordinator

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        let items: [VaultItem]
        @Binding var currentIndex: Int
        private var cache: [Int: UIViewController] = [:]

        init(items: [VaultItem], currentIndex: Binding<Int>) {
            self.items = items
            self._currentIndex = currentIndex
        }

        func viewController(at index: Int) -> UIViewController {
            if let cached = cache[index] { return cached }
            let vc = buildViewController(for: items[index])
            cache[index] = vc
            return vc
        }

        private func buildViewController(for item: VaultItem) -> UIViewController {
            if item.type == .photo {
                let host = UIHostingController(
                    rootView: PhotoDetailView(url: VaultManager.shared.fileURL(for: item))
                )
                host.view.backgroundColor = .black
                return host
            } else {
                let playerVC = AVPlayerViewController()
                playerVC.player = AVPlayer(url: VaultManager.shared.fileURL(for: item))
                playerVC.showsPlaybackControls = true
                playerVC.videoGravity = .resizeAspect
                playerVC.entersFullScreenWhenPlaybackBegins = false
                playerVC.exitsFullScreenWhenPlaybackEnds = false
                playerVC.view.backgroundColor = .black
                return playerVC
            }
        }

        private func index(of viewController: UIViewController) -> Int? {
            cache.first(where: { $0.value === viewController })?.key
        }

        // MARK: UIPageViewControllerDataSource

        func pageViewController(_ pageViewController: UIPageViewController,
                                viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let idx = index(of: viewController), idx > 0 else { return nil }
            return self.viewController(at: idx - 1)
        }

        func pageViewController(_ pageViewController: UIPageViewController,
                                viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let idx = index(of: viewController), idx < items.count - 1 else { return nil }
            return self.viewController(at: idx + 1)
        }

        // MARK: UIPageViewControllerDelegate

        func pageViewController(_ pageViewController: UIPageViewController,
                                didFinishAnimating finished: Bool,
                                previousViewControllers: [UIViewController],
                                transitionCompleted completed: Bool) {
            guard completed,
                  let current = pageViewController.viewControllers?.first,
                  let idx = index(of: current) else { return }

            DispatchQueue.main.async { self.currentIndex = idx }

            // Паузируем предыдущие видео
            for prev in previousViewControllers {
                (prev as? AVPlayerViewController)?.player?.pause()
            }
        }
    }
}

// MARK: - PhotoDetailView

struct PhotoDetailView: View {
    let url: URL
    @State private var image: UIImage?
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { scale = max(1, $0) }
                                .onEnded { _ in
                                    withAnimation(.spring(response: 0.35)) {
                                        scale = 1
                                        offset = .zero
                                    }
                                },
                            DragGesture()
                                .onChanged { value in
                                    if scale > 1 { offset = value.translation }
                                }
                                .onEnded { _ in
                                    if scale <= 1 {
                                        withAnimation(.spring(response: 0.35)) { offset = .zero }
                                    }
                                }
                        )
                    )
            } else {
                ProgressView().tint(.white)
            }
        }
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                let img = UIImage(contentsOfFile: url.path)
                DispatchQueue.main.async { image = img }
            }
        }
    }
}

// MARK: - MediaPicker

struct MediaPicker: UIViewControllerRepresentable {
    let onSelect: ([UIImage], [URL]) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .any(of: [.images, .videos])
        config.selectionLimit = 0
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onSelect: ([UIImage], [URL]) -> Void

        init(onSelect: @escaping ([UIImage], [URL]) -> Void) {
            self.onSelect = onSelect
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard !results.isEmpty else {
                onSelect([], [])
                return
            }

            let group = DispatchGroup()
            var images: [UIImage] = []
            var videoURLs: [URL] = []

            for result in results {
                let provider = result.itemProvider

                if provider.canLoadObject(ofClass: UIImage.self) {
                    group.enter()
                    provider.loadObject(ofClass: UIImage.self) { object, _ in
                        if let image = object as? UIImage {
                            images.append(image)
                        }
                        group.leave()
                    }
                } else if provider.hasItemConformingToTypeIdentifier("public.movie") {
                    group.enter()
                    provider.loadFileRepresentation(forTypeIdentifier: "public.movie") { url, _ in
                        if let url = url {
                            let tempURL = FileManager.default.temporaryDirectory
                                .appendingPathComponent(UUID().uuidString)
                                .appendingPathExtension(url.pathExtension)
                            try? FileManager.default.copyItem(at: url, to: tempURL)
                            videoURLs.append(tempURL)
                        }
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                self.onSelect(images, videoURLs)
            }
        }
    }
}

#Preview {
    VaultView()
}
