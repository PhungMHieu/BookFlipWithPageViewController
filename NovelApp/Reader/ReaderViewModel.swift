//
//  ReaderViewModel.swift
//  NovelApp
//

import PageCurlKit
import SwiftUI

@Observable
final class ReaderViewModel {

    struct ReadingPosition {
        var chapterIndex: Int
        /// Vị trí ký tự đầu trang trong chương. Lưu theo ký tự thay vì số trang
        /// để đổi cỡ chữ / xoay máy vẫn mở đúng đoạn đang đọc.
        var location: Int
    }

    static let fontSizeRange: ClosedRange<CGFloat> = 14...28

    let book: Book

    private(set) var pages: [BookPage] = []
    /// Trang đang mở. Ở chế độ 2 trang, các trang đang hiện là `visiblePages`.
    private(set) var currentPage = 0
    /// 1 trang hay 2 trang liền nhau, theo bề ngang vùng đọc.
    private(set) var layout: PageCurlLayout = .single
    /// Kích thước một trang giấy đang dùng để dàn trang.
    private(set) var pageSize: CGSize = .zero

    private(set) var theme: ReaderTheme
    private(set) var font: ReaderFont
    private(set) var fontSize: CGFloat
    var isChromeVisible = false

    @ObservationIgnored private var position: ReadingPosition
    /// Tăng sau mỗi lần dàn trang, nằm trong `BookPage.ID`.
    @ObservationIgnored private var generation = 0
    @ObservationIgnored private var pendingLayout: Task<Void, Never>?
    @ObservationIgnored private let defaults: UserDefaults

    init(book: Book, defaults: UserDefaults = .standard) {
        self.book = book
        self.defaults = defaults
        theme = defaults.string(forKey: Keys.theme).flatMap(ReaderTheme.init) ?? .paper
        font = defaults.string(forKey: Keys.font).flatMap(ReaderFont.init) ?? .georgia
        let savedSize = defaults.double(forKey: Keys.fontSize)
        fontSize = savedSize > 0 ? CGFloat(savedSize) : 18
        position = ReadingPosition(
            chapterIndex: defaults.integer(forKey: Keys.chapter(book)),
            location: defaults.integer(forKey: Keys.location(book))
        )
    }

    var isSpread: Bool { layout == .spread }

    /// Các trang đang hiển thị khi mở tới `page`: 1 trang, hoặc cặp trái–phải ở chế độ 2 trang.
    func visiblePages(for page: Int) -> ClosedRange<Int>? {
        layout.visiblePages(for: page, pageCount: pages.count)
    }

    /// Trang mở đầu của từng chương, dùng cho mục lục.
    var chapterStartPages: [Int] {
        pages.filter(\.isChapterStart).map(\.index)
    }

    // MARK: - Layout

    /// Gọi mỗi khi vùng đọc đổi kích thước. Lần đầu dàn trang ngay; các lần sau đợi kích thước
    /// đứng yên một chút, vì khi xoay máy hoặc kéo đổi kích thước cửa sổ, kích thước đổi liên tục
    /// từng khung hình.
    func updateLayout(_ geometry: BookGeometry) {
        pendingLayout?.cancel()
        guard geometry.pageSize != pageSize || geometry.layout != layout else { return }
        guard !pages.isEmpty else {
            applyLayout(geometry)
            return
        }
        pendingLayout = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(200))
            guard !Task.isCancelled else { return }
            self?.applyLayout(geometry)
        }
    }

    private func applyLayout(_ geometry: BookGeometry) {
        pageSize = geometry.pageSize
        layout = geometry.layout
        repaginate()
    }

    private func repaginate() {
        generation += 1
        pages = BookPaginator.paginate(
            book: book,
            generation: generation,
            textSize: PageMetrics.textSize(for: pageSize),
            font: font,
            fontSize: fontSize,
            theme: theme
        )
        currentPage = pageIndex(for: position)
    }

    private func pageIndex(for position: ReadingPosition) -> Int {
        pages.lastIndex {
            $0.chapterIndex == position.chapterIndex && $0.characterRange.location <= position.location
        } ?? 0
    }

    // MARK: - Navigation

    /// Người dùng lật trang xong (PageCurlView ghi lại binding).
    func pageDidChange(_ index: Int) {
        guard pages.indices.contains(index), index != currentPage else { return }
        currentPage = index
        savePosition(of: index)
    }

    /// Nhảy trang từ thanh trượt / mục lục: PageCurlView thấy `currentPage` đổi sẽ tự lật tới.
    func jump(to index: Int) {
        let target = min(max(index, 0), pages.count - 1)
        guard pages.indices.contains(target), target != currentPage else { return }
        currentPage = target
        savePosition(of: target)
    }

    func toggleChrome() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isChromeVisible.toggle()
        }
    }

    // MARK: - Settings

    func setTheme(_ newTheme: ReaderTheme) {
        guard newTheme != theme else { return }
        // Chỉ đổi màu mực trong text storage, giữ nguyên dàn trang và trang đang mở.
        var recolored = Set<ObjectIdentifier>()
        for page in pages where recolored.insert(ObjectIdentifier(page.chapterLayout)).inserted {
            page.chapterLayout.applyInk(newTheme)
        }
        theme = newTheme
        defaults.set(newTheme.rawValue, forKey: Keys.theme)
    }

    func setFont(_ newFont: ReaderFont) {
        guard newFont != font else { return }
        font = newFont
        defaults.set(newFont.rawValue, forKey: Keys.font)
        repaginate()
    }

    func changeFontSize(by delta: CGFloat) {
        let newSize = min(max(fontSize + delta, Self.fontSizeRange.lowerBound), Self.fontSizeRange.upperBound)
        guard newSize != fontSize else { return }
        fontSize = newSize
        defaults.set(Double(newSize), forKey: Keys.fontSize)
        repaginate()
    }

    // MARK: - Persistence

    private func savePosition(of index: Int) {
        let page = pages[index]
        position = ReadingPosition(chapterIndex: page.chapterIndex, location: page.characterRange.location)
        defaults.set(position.chapterIndex, forKey: Keys.chapter(book))
        defaults.set(position.location, forKey: Keys.location(book))
        defaults.set(Double(index + 1) / Double(pages.count), forKey: Keys.progress(book))
    }

    enum Keys {
        static let theme = "reader.theme"
        static let font = "reader.font"
        static let fontSize = "reader.fontSize"
        static func chapter(_ book: Book) -> String { "reader.\(book.id).chapterIndex" }
        static func location(_ book: Book) -> String { "reader.\(book.id).location" }
        /// Tỉ lệ đã đọc (0...1), tủ sách đọc qua `@AppStorage`.
        static func progress(_ book: Book) -> String { "reader.\(book.id).progress" }
    }
}
