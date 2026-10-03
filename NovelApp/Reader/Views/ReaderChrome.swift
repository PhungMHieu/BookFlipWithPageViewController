//
//  ReaderChrome.swift
//  NovelApp
//

import SwiftUI

/// Nút mở/đóng tủ sách trên thanh điều khiển của màn đọc.
struct ReaderLibraryButton {
    let systemImage: String
    let action: () -> Void
}

/// Thanh điều khiển hiện khi chạm giữa trang: tên sách, mục lục, cài đặt và thanh trượt trang.
struct ReaderChrome: View {
    let viewModel: ReaderViewModel
    let libraryButton: ReaderLibraryButton
    let onShowContents: () -> Void
    let onShowSettings: () -> Void

    /// Giá trị tạm khi đang kéo thanh trượt — chỉ nhảy trang khi thả tay.
    @State private var scrubPage: Double?

    var body: some View {
        VStack {
            topBar
            Spacer()
            bottomBar
                .frame(maxWidth: 640)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var topBar: some View {
        HStack(spacing: 4) {
            Button(action: libraryButton.action) {
                Image(systemName: libraryButton.systemImage)
                    .frame(width: 44, height: 44)
            }

            Button(action: onShowContents) {
                Image(systemName: "list.bullet")
                    .frame(width: 44, height: 44)
            }

            VStack(spacing: 2) {
                Text(viewModel.book.title)
                    .font(.subheadline.weight(.semibold))
                Text(viewModel.book.author)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity)

            Button(action: onShowSettings) {
                Text("Aa")
                    .font(.system(size: 17, weight: .semibold, design: .serif))
                    .frame(width: 44, height: 44)
            }
            // Cân với 2 nút bên trái để tên sách nằm giữa.
            Color.clear.frame(width: 44, height: 44)
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 6)
        .glassEffect(.regular, in: .capsule)
    }

    private var bottomBar: some View {
        let lastPage = max(viewModel.pages.count - 1, 1)
        let shownPage = scrubPage.map { Int($0) } ?? viewModel.currentPage
        let shownChapter = viewModel.pages.indices.contains(shownPage) ? viewModel.pages[shownPage].chapterTitle : ""

        return VStack(spacing: 6) {
            Slider(
                value: Binding(
                    get: { scrubPage ?? Double(viewModel.currentPage) },
                    set: { scrubPage = $0 }
                ),
                in: 0...Double(lastPage),
                step: 1
            ) { isEditing in
                guard !isEditing, let target = scrubPage else { return }
                viewModel.jump(to: Int(target))
                scrubPage = nil
            }

            HStack {
                Text(shownChapter)
                    .lineLimit(1)
                Spacer()
                Text("Trang \(pageLabel(for: shownPage)) / \(viewModel.pages.count)")
                    .monospacedDigit()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
    }

    private func pageLabel(for page: Int) -> String {
        guard let visible = viewModel.visiblePages(for: page) else { return "" }
        return visible.count == 1
            ? "\(visible.lowerBound + 1)"
            : "\(visible.lowerBound + 1)–\(visible.upperBound + 1)"
    }
}
