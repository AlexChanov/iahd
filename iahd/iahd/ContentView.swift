//
//  ContentView.swift
//  iahd
//
//  Created by Alexey Chanov on 08.10.2025.
//

import SwiftUI
import CoreData

extension Notification.Name {
    static let goBack = Notification.Name("goBack")
    static let goForward = Notification.Name("goForward")
    static let reload = Notification.Name("reload")
}

import SwiftUI

import SwiftUI

struct ContentView: View {
    @State private var currentURL = URL(string: "https://iahd.cc")!
    @State private var isLoading = false
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var showingMenu = false

    var body: some View {
        NavigationView {
            ZStack {
                WebView(
                    url: currentURL,
                    isLoading: $isLoading,
                    canGoBack: $canGoBack,
                    canGoForward: $canGoForward
                )
                .id(currentURL)
                .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            .navigationTitle("IAHD")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                CustomBottomBar(
                    canGoBack: canGoBack,
                    canGoForward: canGoForward,
                    isLoading: isLoading,
                    onBack: {
                        NotificationCenter.default.post(name: .goBack, object: nil)
                    },
                    onForward: {
                        NotificationCenter.default.post(name: .goForward, object: nil)
                    },
                    onReload: {
                        NotificationCenter.default.post(name: .reload, object: nil)
                    },
                    onMenu: {
                        showingMenu.toggle()
                    }
                )
            }
            .confirmationDialog("Меню", isPresented: $showingMenu, titleVisibility: .visible) {
                Button("Главная") {
                    currentURL = URL(string: "https://iahd.cc")!
                }

                Button("О нас") {
                    currentURL = URL(string: "https://iahd.cc/about")!
                }

                Button("Участники") {
                    currentURL = URL(string: "https://iahd.cc/members")!
                }

                Button("Новости") {
                    currentURL = URL(string: "https://iahd.cc/news")!
                }

                Button("Статьи") {
                    currentURL = URL(string: "https://iahd.cc/articles")!
                }

                Button("Вступить в ассоциацию") {
                    currentURL = URL(string: "https://iahd.cc")!
                }

                Button("Отмена", role: .cancel) { }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct CustomBottomBar: View {
    let canGoBack: Bool
    let canGoForward: Bool
    let isLoading: Bool
    let onBack: () -> Void
    let onForward: () -> Void
    let onReload: () -> Void
    let onMenu: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            BottomBarButton(
                icon: "chevron.left",
                isEnabled: canGoBack,
                action: onBack
            )

            Spacer()

            BottomBarButton(
                icon: "chevron.right",
                isEnabled: canGoForward,
                action: onForward
            )

            Spacer()

            BottomBarButton(
                icon: isLoading ? "stop.fill" : "arrow.clockwise",
                isEnabled: true,
                action: onReload
            )
            .rotationEffect(.degrees(isLoading ? 0 : 0))

            Spacer()

            BottomBarButton(
                icon: "line.3.horizontal",
                isEnabled: true,
                action: onMenu
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 6)
        .background(
            ZStack {
                // Glassmorphism эффект
                Color(.orange)
                    .opacity(0.8)

                // Тонкая линия сверху
                VStack {
                    Divider()
                    Spacer()
                }
            }
        )
        .background(.ultraThinMaterial)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
}

struct BottomBarButton: View {
    let icon: String
    let isEnabled: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            if isEnabled {
                // Haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                action()
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(isEnabled ? .primary : .gray.opacity(0.4))
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(isPressed ? Color.gray.opacity(0.2) : Color.clear)
                )
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .disabled(!isEnabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if isEnabled && !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

#Preview {
    ContentView()
}
