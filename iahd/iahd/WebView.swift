//
//  WebView.swift
//  iahd
//
//  Created by Alexey Chanov on 08.10.2025.
//

import Foundation
import SwiftUI
import WebKit
import SwiftUI
import WebKit

import SwiftUI
import WebKit

import SwiftUI
import WebKit

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        context.coordinator.webView = webView

        // Подписка на уведомления
        NotificationCenter.default.addObserver(
            forName: .goBack,
            object: nil,
            queue: .main
        ) { _ in
            context.coordinator.goBack()
        }

        NotificationCenter.default.addObserver(
            forName: .goForward,
            object: nil,
            queue: .main
        ) { _ in
            context.coordinator.goForward()
        }

        NotificationCenter.default.addObserver(
            forName: .reload,
            object: nil,
            queue: .main
        ) { _ in
            context.coordinator.reload()
        }

        let request = URLRequest(url: url)
        webView.load(request)

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // КРИТИЧНО: загружаем ТОЛЬКО если URL действительно изменился
        // Игнорируем все остальные изменения (isLoading, canGoBack, canGoForward)
        guard let currentURL = webView.url else {
            let request = URLRequest(url: url)
            webView.load(request)
            return
        }

        // Проверяем, что URL реально изменился
//        if currentURL.absoluteString != url.absoluteString {
//            print("🔄 Loading new URL: \(url.absoluteString)")
//            let request = URLRequest(url: url)
//            webView.load(request)
//        } else {
//            print("⏭️ Skipping update - URL hasn't changed")
//        }
    }

    // ВАЖНО: Сообщаем SwiftUI сравнивать только URL
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        NotificationCenter.default.removeObserver(coordinator)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        weak var webView: WKWebView?
        private var isUpdating = false

        init(parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            guard !isUpdating else { return }
            isUpdating = true

            DispatchQueue.main.async { [weak self] in
                self?.parent.isLoading = true
                self?.isUpdating = false
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard !isUpdating else { return }
            isUpdating = true

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.parent.isLoading = false
                self.parent.canGoBack = webView.canGoBack
                self.parent.canGoForward = webView.canGoForward
                self.isUpdating = false
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            guard !isUpdating else { return }
            isUpdating = true

            DispatchQueue.main.async { [weak self] in
                self?.parent.isLoading = false
                self?.isUpdating = false
            }
        }

        func goBack() {
            webView?.goBack()
        }

        func goForward() {
            webView?.goForward()
        }

        func reload() {
            webView?.reload()
        }
    }
}
