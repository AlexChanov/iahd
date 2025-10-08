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
                .id(currentURL) // Пересоздаем WebView только при смене URL
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
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        NotificationCenter.default.post(name: .goBack, object: nil)
                    }) {
                        Image(systemName: "chevron.left")
                            .imageScale(.large)
                    }
                    .disabled(!canGoBack)

                    Spacer()

                    Button(action: {
                        NotificationCenter.default.post(name: .goForward, object: nil)
                    }) {
                        Image(systemName: "chevron.right")
                            .imageScale(.large)
                    }
                    .disabled(!canGoForward)

                    Spacer()

                    Button(action: {
                        NotificationCenter.default.post(name: .reload, object: nil)
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .imageScale(.large)
                    }
                    .disabled(isLoading)

                    Spacer()

                    Button(action: {
                        showingMenu.toggle()
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .imageScale(.large)
                    }
                }
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
                    // После загрузки страницы прокрутит к форме
                }

                Button("Отмена", role: .cancel) { }
            }
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    ContentView()
}
