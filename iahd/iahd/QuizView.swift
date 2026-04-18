import SwiftUI

struct QuizQuestion {
    let text: String
    let options: [String]
    let correctIndex: Int
}

private let questions: [QuizQuestion] = [
    QuizQuestion(
        text: "Что означает аббревиатура REST?",
        options: [
            "Remote Execution Standard Technology",
            "Representational State Transfer",
            "Reliable Endpoint Security Transfer",
            "Recursive Execution State Tree"
        ],
        correctIndex: 1
    ),
    QuizQuestion(
        text: "Что описывает нотация O(n log n)?",
        options: [
            "Константное время выполнения",
            "Линейное время выполнения",
            "Квазилинейное время выполнения",
            "Квадратичное время выполнения"
        ],
        correctIndex: 2
    ),
    QuizQuestion(
        text: "Какой протокол гарантирует доставку пакетов?",
        options: ["UDP", "ICMP", "TCP", "ARP"],
        correctIndex: 2
    ),
    QuizQuestion(
        text: "Что такое индекс в реляционной базе данных?",
        options: [
            "Резервная копия таблицы",
            "Структура данных для ускорения поиска",
            "Уникальный идентификатор записи",
            "Ограничение внешнего ключа"
        ],
        correctIndex: 1
    ),
    QuizQuestion(
        text: "Что означает принцип «S» в SOLID?",
        options: [
            "Security Responsibility",
            "Static Binding",
            "Single Responsibility",
            "Synchronized State"
        ],
        correctIndex: 2
    ),
    QuizQuestion(
        text: "Какой паттерн проектирования гарантирует единственный экземпляр класса?",
        options: ["Factory", "Observer", "Singleton", "Decorator"],
        correctIndex: 2
    ),
    QuizQuestion(
        text: "Что такое Docker-контейнер?",
        options: [
            "Виртуальная машина с полной ОС",
            "Изолированная среда запуска приложений",
            "Облачный сервис хранения данных",
            "Система контроля версий"
        ],
        correctIndex: 1
    ),
    QuizQuestion(
        text: "Какая команда Git создаёт новую ветку и переключается на неё?",
        options: [
            "git branch new-branch",
            "git merge new-branch",
            "git checkout -b new-branch",
            "git init new-branch"
        ],
        correctIndex: 2
    ),
    QuizQuestion(
        text: "Что такое DNS?",
        options: [
            "Протокол шифрования трафика",
            "Система, преобразующая доменные имена в IP-адреса",
            "Тип базы данных",
            "Межсетевой экран"
        ],
        correctIndex: 1
    ),
    QuizQuestion(
        text: "Что означает CI/CD?",
        options: [
            "Code Integration / Code Delivery",
            "Continuous Integration / Continuous Delivery",
            "Central Infrastructure / Cloud Deployment",
            "Component Interface / Component Design"
        ],
        correctIndex: 1
    ),
    QuizQuestion(
        text: "Что такое «гонка условий» (race condition)?",
        options: [
            "Алгоритм сортировки с соревнованием потоков",
            "Ошибка, возникающая при непредсказуемом порядке выполнения конкурентных операций",
            "Техника оптимизации многопоточного кода",
            "Протокол синхронизации баз данных"
        ],
        correctIndex: 1
    ),
    QuizQuestion(
        text: "Какой HTTP-метод идемпотентен, но не безопасен?",
        options: ["GET", "POST", "PUT", "PATCH"],
        correctIndex: 2
    ),
    QuizQuestion(
        text: "Что такое нормализация базы данных?",
        options: [
            "Сжатие данных для экономии места",
            "Процесс шифрования таблиц",
            "Организация данных для минимизации дублирования",
            "Создание резервных копий"
        ],
        correctIndex: 2
    ),
    QuizQuestion(
        text: "Что описывает теорема CAP?",
        options: [
            "Три уровня кэширования: CPU, RAM, Disk",
            "Распределённая система не может одновременно обеспечить Consistency, Availability и Partition tolerance",
            "Три фазы компиляции: Code, Assembly, Process",
            "Принципы криптографической защиты"
        ],
        correctIndex: 1
    ),
    QuizQuestion(
        text: "Что такое «технический долг»?",
        options: [
            "Задолженность по лицензиям на ПО",
            "Накопленные последствия компромиссных решений в коде, требующие переработки",
            "Бюджет на покупку серверов",
            "Количество незакрытых задач в бэклоге"
        ],
        correctIndex: 1
    ),
    QuizQuestion(
        text: "Какой принцип описывает «не повторяй себя»?",
        options: ["KISS", "YAGNI", "DRY", "SOLID"],
        correctIndex: 2
    ),
    QuizQuestion(
        text: "Что такое JWT?",
        options: [
            "Язык разметки для API",
            "Компактный токен для передачи заявлений между сторонами",
            "Протокол шифрования трафика",
            "Формат хранения конфигурации"
        ],
        correctIndex: 1
    ),
    QuizQuestion(
        text: "Какова сложность поиска элемента в хеш-таблице в среднем случае?",
        options: ["O(log n)", "O(n)", "O(1)", "O(n²)"],
        correctIndex: 2
    ),
    QuizQuestion(
        text: "Что такое «микросервисная архитектура»?",
        options: [
            "Архитектура с минимальным размером кодовой базы",
            "Набор небольших независимо развёртываемых сервисов, каждый выполняет одну бизнес-функцию",
            "Паттерн для работы с микроконтроллерами",
            "Тип монолитного приложения с модульной структурой"
        ],
        correctIndex: 1
    )
]

struct QuizView: View {
    @State private var currentIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var correctCount = 0
    @State private var isFinished = false
    @State private var showAnswer = false

    var body: some View {
        NavigationView {
            Group {
                if isFinished {
                    ResultView(correctCount: correctCount, onRetry: reset)
                } else {
                    questionView
                }
            }
            .navigationTitle("Экспресс-тест")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }

    private var questionView: some View {
        VStack(spacing: 0) {
            progressBar

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Вопрос \(currentIndex + 1) из \(questions.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(questions[currentIndex].text)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(spacing: 12) {
                        ForEach(0..<questions[currentIndex].options.count, id: \.self) { i in
                            AnswerButton(
                                text: questions[currentIndex].options[i],
                                state: answerState(for: i),
                                onTap: { selectAnswer(i) }
                            )
                        }
                    }

                    if showAnswer {
                        Button(action: nextQuestion) {
                            Text(currentIndex + 1 == questions.count ? "Завершить" : "Следующий вопрос")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(20)
            }
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: geo.size.width * CGFloat(currentIndex) / CGFloat(questions.count))
                    .animation(.easeInOut, value: currentIndex)
            }
        }
        .frame(height: 4)
    }

    private func answerState(for index: Int) -> AnswerButton.AnswerState {
        guard showAnswer else {
            return selectedAnswer == index ? .selected : .normal
        }
        if index == questions[currentIndex].correctIndex { return .correct }
        if index == selectedAnswer { return .wrong }
        return .normal
    }

    private func selectAnswer(_ index: Int) {
        guard !showAnswer else { return }
        selectedAnswer = index
        showAnswer = true
        if index == questions[currentIndex].correctIndex {
            correctCount += 1
        }
    }

    private func nextQuestion() {
        if currentIndex + 1 == questions.count {
            isFinished = true
        } else {
            currentIndex += 1
            selectedAnswer = nil
            showAnswer = false
        }
    }

    private func reset() {
        currentIndex = 0
        selectedAnswer = nil
        correctCount = 0
        isFinished = false
        showAnswer = false
    }
}

struct AnswerButton: View {
    enum AnswerState { case normal, selected, correct, wrong }

    let text: String
    let state: AnswerState
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(text)
                    .font(.body)
                    .foregroundColor(foregroundColor)
                    .multilineTextAlignment(.leading)
                Spacer()
                if state == .correct {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                } else if state == .wrong {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                }
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: state == .normal ? 1 : 2)
            )
        }
        .disabled(state == .correct || state == .wrong)
    }

    private var backgroundColor: Color {
        switch state {
        case .normal: return Color.gray.opacity(0.1)
        case .selected: return Color.accentColor.opacity(0.15)
        case .correct: return Color.green.opacity(0.15)
        case .wrong: return Color.red.opacity(0.15)
        }
    }

    private var borderColor: Color {
        switch state {
        case .normal: return Color.gray.opacity(0.3)
        case .selected: return Color.accentColor
        case .correct: return Color.green
        case .wrong: return Color.red
        }
    }

    private var foregroundColor: Color {
        switch state {
        case .correct: return .green
        case .wrong: return .red
        default: return .primary
        }
    }
}

struct ResultView: View {
    let correctCount: Int
    let onRetry: () -> Void

    private var passed: Bool { correctCount >= 8 }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: passed ? "checkmark.seal.fill" : "xmark.seal.fill")
                .font(.system(size: 80))
                .foregroundColor(passed ? .green : .orange)

            VStack(spacing: 12) {
                Text(passed ? "Вы подходите!" : "Попробуйте ещё раз")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Правильных ответов: \(correctCount) из \(questions.count)")
                    .font(.title3)
                    .foregroundColor(.secondary)

                if passed {
                    Text("Поздравляем! Вы ответили на \(correctCount) из 10 вопросов верно и подходите для вступления в Ассоциацию IAHD.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    Text("Для вступления в ассоциацию необходимо ответить верно не менее чем на 8 вопросов из 10.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }

            Button(action: onRetry) {
                Text("Пройти тест заново")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
            }

            Spacer()
        }
    }
}

#Preview {
    QuizView()
}
