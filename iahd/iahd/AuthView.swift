//
//  AuthView.swift
//  iahd
//
//  Created by Alexey Chanov on 08.10.2025.
//

import Foundation
import SwiftUI
import UIKit

struct AuthView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isAuthenticated: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            ScrollView {
                if isAuthenticated {
                    // Экран профиля после успешной авторизации
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.fill.badge.checkmark")
                                .font(.system(size: 70))
                                .foregroundStyle(.green.gradient)

                            Text("Вы вошли в IAHD")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 60)

                        Button(action: signOut) {
                            Text("Выйти")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(.systemGray5))
                                .foregroundColor(.red)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    }
                } else {
                    VStack(spacing: 24) {
                        // Логотип
                        VStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.fill.badge.checkmark")
                                .font(.system(size: 70))
                                .foregroundStyle(.orange.gradient)

                            Text("Вход в IAHD")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("Международная ассоциация\nвысококвалифицированных разработчиков")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 20)

                        // Форма входа
                        VStack(spacing: 16) {
                            // Email поле
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(.gray)

                                    TextField("developer@example.com", text: $email)
                                        .textContentType(.emailAddress)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .autocorrectionDisabled()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }

                            // Password поле
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Пароль")
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.gray)

                                    SecureField("••••••••", text: $password)
                                        .textContentType(.password)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }

                            // Забыли пароль
                            HStack {
                                Spacer()
                                Button("Забыли пароль?") {
                                    alertMessage = "You dont have account"
                                    showingAlert = true
                                }
                                .font(.caption)
                                .foregroundColor(.orange)
                            }
                        }
                        .padding(.horizontal, 24)

                        // Кнопка входа
                        Button(action: login) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Войти")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    colors: [.orange, .orange.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                        // Разделитель
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(.systemGray4))

                            Text("или")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)

                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(.systemGray4))
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)

                        // Регистрация
                        HStack(spacing: 4) {
                            Text("Нет аккаунта?")
                                .foregroundColor(.secondary)

                            Button("Подать заявку") {
                                dismiss()
                                // Здесь можно открыть страницу регистрации
                            }
                            .foregroundColor(.orange)
                            .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                        .padding(.top, 16)

                        // Информация о членстве
                        VStack(spacing: 8) {
                            Text("Требования для вступления")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)

                            Text("• Экспертность в IT\n• Вклад в open source\n• Рекомендация участника\n• Членский взнос $500/год")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .alert("Информация", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func signOut() {
        isAuthenticated = false
        email = ""
        password = ""
    }

    private func login() {
        // Имитация входа
        isLoading = true

        // Мок-данные для тестирования
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false

            if email == "test@iahd.cc" && password == "password" {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)

                isAuthenticated = true
                alertMessage = "Добро пожаловать в IAHD!"
                showingAlert = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dismiss()
                }
            } else {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)

                alertMessage = "Неверный email или пароль" //\n\nДля теста используйте:\nEmail: test@iahd.cc\nПароль: password"
                showingAlert = true
            }
        }
    }
}

struct SocialLoginButton: View {
    let icon: String
    let title: String
    let backgroundColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))

                Text(title)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}

#Preview {
    AuthView(isAuthenticated: .constant(false))
}
