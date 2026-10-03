//
//  Book.swift
//  NovelApp
//

import Foundation

struct Book: Identifiable {
    let id: String
    let title: String
    let author: String
    /// Sắc độ (0...1) của màu bìa, dùng để vẽ bìa sách trong tủ sách.
    let coverHue: Double
    let chapters: [Chapter]
}

struct Chapter {
    /// Nhãn nhỏ phía trên tên chương, ví dụ "Chương Một".
    let label: String
    let title: String
    let paragraphs: [String]
}
