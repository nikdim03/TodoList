import Foundation
import SwiftUI

// ONLY user-facing localized (or localizable) strings & text formatting helpers.
public enum Strings {
    public static let navTasksTitle: LocalizedStringKey = "Задачи"
    public static let searchPlaceholder: LocalizedStringKey = "Search"
    public static let detailTitlePlaceholder: LocalizedStringKey = "Название"
    public static let detailNotesPlaceholder: LocalizedStringKey = "Описание..."
    public static let contextEdit: LocalizedStringKey = "Редактировать"
    public static let contextShare: LocalizedStringKey = "Поделиться"
    public static let contextDelete: LocalizedStringKey = "Удалить"
    public static let detailBack: LocalizedStringKey = "Назад"

    public static func shareStatus(_ status: TodoItem.Status) -> String {
        status == .completed ? "✅ Выполнено" : "⭕ Нужно выполнить"
    }
    public static func shareLineTitle(_ value: String) -> String {
        "Название: \(value)"
    }
    public static func shareLineDate(_ value: String) -> String {
        "Дата: \(value)"
    }
    public static func shareLineStatus(_ value: String) -> String {
        "Статус: \(value)"
    }

    public static func taskCountLabel(_ count: Int) -> String {
        let word: String = {
            let rem100 = count % 100
            if rem100 >= 11 && rem100 <= 14 { return "Задач" }
            switch count % 10 {
            case 1: return "Задача"
            case 2, 3, 4: return "Задачи"
            default: return "Задач"
            }
        }()
        return "\(count) \(word)"
    }
}
