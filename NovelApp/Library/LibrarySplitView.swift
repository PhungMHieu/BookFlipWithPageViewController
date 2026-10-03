//
//  LibrarySplitView.swift
//  NovelApp
//

import PageCurlKit
import SwiftUI

/// Màn gốc: tủ sách và sách đang đọc.
///
/// Trên mọi màn hình, tủ sách nổi đè lên sách nên mở/đóng tủ sách không làm sách đổi kích thước
/// hay dàn trang lại:
/// - Màn rộng: `NavigationSplitView` với `.prominentDetail`.
/// - Màn hẹp: NavigationSplitView sẽ gộp thành stack (đẩy màn đọc vào, đổi kích thước), nên dùng
///   một ngăn tủ sách trượt ra từ mép trái, đè lên sách.
struct LibrarySplitView: View {
    @State private var selectedBookID: Book.ID?
    /// Tủ sách đang mở — dùng chung cho cả hai kiểu bày.
    @State private var isLibraryVisible = true
    /// 1 trang hay 2 trang, chọn theo cả cửa sổ chứ không theo cột detail, để bố cục chỉ đổi khi xoay máy
    /// hoặc đổi kích thước cửa sổ.
    @State private var bookLayout: PageCurlLayout = .single
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let books = Book.library

    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                compactLayout
            } else {
                splitLayout
            }
        }
        // Tủ sách nổi đè lên sách nên chọn xong thì tự đóng, để sách hiện ra.
        .onChange(of: selectedBookID) { _, newValue in
            guard newValue != nil else { return }
            setLibraryVisible(false)
        }
        .onGeometryChange(for: PageCurlLayout.self) { proxy in
            PageCurlLayout.preferred(for: proxy.size)
        } action: { layout in
            bookLayout = layout
        }
        // Ẩn suốt lúc đọc, không bật/tắt theo thanh điều khiển: safe area đổi sẽ làm sách dàn trang lại.
        .statusBarHidden(selectedBookID != nil)
        .persistentSystemOverlays(selectedBookID != nil ? .hidden : .automatic)
    }

    // MARK: - Màn rộng

    private var splitLayout: some View {
        NavigationSplitView(columnVisibility: columnVisibility) {
            LibraryView(books: books, selection: $selectedBookID)
        } detail: {
            detail
        }
        .navigationSplitViewStyle(.prominentDetail)
    }

    private var columnVisibility: Binding<NavigationSplitViewVisibility> {
        Binding(
            get: { isLibraryVisible ? .all : .detailOnly },
            set: { isLibraryVisible = $0 != .detailOnly }
        )
    }

    // MARK: - Màn hẹp

    private var compactLayout: some View {
        ZStack(alignment: .leading) {
            NavigationStack {
                detail
            }
            // Sách nằm dưới ngăn tủ sách không nhận chạm (UIPageViewController có thể giành chạm
            // ở mép trái, đúng chỗ ngăn tủ sách).
            .allowsHitTesting(!isLibraryVisible)

            if isLibraryVisible {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { setLibraryVisible(false) }
                    .transition(.opacity)

                LibraryDrawer(books: books, selection: $selectedBookID) {
                    setLibraryVisible(false)
                }
                .transition(.move(edge: .leading))
            }
        }
    }

    // MARK: - Chung

    @ViewBuilder
    private var detail: some View {
        if let book = books.first(where: { $0.id == selectedBookID }) {
            BookReaderView(book: book, layout: bookLayout, libraryButton: libraryButton)
                // Mỗi cuốn một view model riêng.
                .id(book.id)
                // Màn đọc tự có thanh điều khiển, ẩn navigation bar cho trang sách tràn màn hình.
                .toolbar(.hidden, for: .navigationBar)
        } else {
            ContentUnavailableView {
                Label("Chọn một cuốn sách", systemImage: "books.vertical")
            } description: {
                Text("Sách bạn chọn trong tủ sách sẽ mở ở đây.")
            } actions: {
                Button("Mở tủ sách") { setLibraryVisible(true) }
                    .buttonStyle(.glass)
            }
        }
    }

    private var libraryButton: ReaderLibraryButton {
        ReaderLibraryButton(systemImage: "sidebar.leading") {
            setLibraryVisible(!isLibraryVisible)
        }
    }

    private func setLibraryVisible(_ visible: Bool) {
        withAnimation(.snappy(duration: 0.3)) {
            isLibraryVisible = visible
        }
    }
}

/// Ngăn tủ sách nổi trên màn hẹp, trông như sidebar nổi của `.prominentDetail`.
private struct LibraryDrawer: View {
    let books: [Book]
    @Binding var selection: Book.ID?
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            LibraryView(books: books, selection: $selection)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Đóng", systemImage: "sidebar.leading", action: onClose)
                    }
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.25), radius: 20, x: 4, y: 0)
        .containerRelativeFrame(.horizontal) { width, _ in
            min(width * 0.85, 360)
        }
        .padding(8)
    }
}

#Preview {
    LibrarySplitView()
}
