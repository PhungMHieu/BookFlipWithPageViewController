//
//  LibraryView.swift
//  NovelApp
//

import SwiftUI

struct LibraryView: View {
    let books: [Book]
    @Binding var selection: Book.ID?

    var body: some View {
        List(books, selection: $selection) { book in
            LibraryRow(book: book)
        }
        .navigationTitle("Tủ sách")
    }
}

private struct LibraryRow: View {
    let book: Book
    /// Màn đọc ghi tỉ lệ đã đọc vào UserDefaults, hàng này tự cập nhật theo.
    @AppStorage private var progress: Double

    init(book: Book) {
        self.book = book
        _progress = AppStorage(wrappedValue: 0, ReaderViewModel.Keys.progress(book))
    }

    var body: some View {
        HStack(spacing: 14) {
            BookCover(book: book)
                .frame(width: 54, height: 78)

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.custom("Georgia", size: 17))
                    .lineLimit(2)
                Text(book.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if progress > 0 {
                    ProgressView(value: progress)
                        .tint(Color(hue: book.coverHue, saturation: 0.6, brightness: 0.6))
                        .padding(.top, 2)
                    Text("Đã đọc \(Int((progress * 100).rounded()))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Chưa đọc")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }
}

/// Bìa sách vẽ bằng màu theo `coverHue`: nền vải, gáy sẫm, tên sách chữ serif.
struct BookCover: View {
    let book: Book

    var body: some View {
        let base = Color(hue: book.coverHue, saturation: 0.55, brightness: 0.55)
        let dark = Color(hue: book.coverHue, saturation: 0.65, brightness: 0.32)

        ZStack(alignment: .leading) {
            LinearGradient(colors: [base, dark], startPoint: .topLeading, endPoint: .bottomTrailing)

            // Gáy sách.
            LinearGradient(colors: [.black.opacity(0.35), .black.opacity(0.05)], startPoint: .leading, endPoint: .trailing)
                .frame(width: 6)

            VStack(spacing: 4) {
                Text(book.title)
                    .font(.custom("Georgia", fixedSize: 8.5))
                    .multilineTextAlignment(.center)
                Rectangle()
                    .frame(width: 16, height: 0.5)
                Text(book.author)
                    .font(.custom("Georgia", fixedSize: 6))
            }
            .foregroundStyle(.white.opacity(0.9))
            .padding(.leading, 9)
            .padding(.trailing, 4)
            .frame(maxWidth: .infinity)
        }
        .clipShape(RoundedRectangle(cornerRadius: 3))
        .shadow(color: .black.opacity(0.25), radius: 3, x: 1, y: 2)
    }
}
