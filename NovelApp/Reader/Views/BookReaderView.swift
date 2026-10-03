//
//  BookReaderView.swift
//  NovelApp
//

import PageCurlKit
import SwiftUI

struct BookReaderView: View {
    @State private var viewModel: ReaderViewModel
    @State private var activePanel: ReaderPanel?
    /// 1 trang / 2 trang do màn chứa quyết định (theo cả cửa sổ), màn đọc chỉ tính kích thước trang.
    private let layout: PageCurlLayout
    private let libraryButton: ReaderLibraryButton

    init(book: Book, layout: PageCurlLayout, libraryButton: ReaderLibraryButton) {
        _viewModel = State(initialValue: ReaderViewModel(book: book))
        self.layout = layout
        self.libraryButton = libraryButton
    }

    var body: some View {
        ZStack {
            viewModel.theme.desk
                .ignoresSafeArea()

            GeometryReader { proxy in
                book(in: proxy.size)
            }
            // Khi thanh điều khiển / panel đang mở, trang sách không nhận chạm: UIPageViewController
            // nằm dưới đôi khi giành mất cú chạm của các nút phía trên (nút quay lại ở mép trái).
            .allowsHitTesting(!viewModel.isChromeVisible && activePanel == nil)

            if viewModel.isChromeVisible && activePanel == nil {
                // Chạm vào trang (ngoài hai thanh) để ẩn thanh điều khiển.
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture { viewModel.toggleChrome() }

                ReaderChrome(
                    viewModel: viewModel,
                    libraryButton: libraryButton,
                    onShowContents: { show(.contents) },
                    onShowSettings: { show(.settings) }
                )
                .transition(.opacity)
            }

            if let activePanel {
                panel(activePanel)
            }
        }
        .preferredColorScheme(viewModel.theme.colorScheme)
    }

    // MARK: - Book

    private func book(in available: CGSize) -> some View {
        let target = BookGeometry.reader(layout: layout, fitting: available)
        // Khung sách theo layout đã áp dụng (không theo từng khung hình khi sidebar đang trượt),
        // để trang không bị kéo giãn trong lúc chờ dàn trang lại.
        let pageSize = viewModel.pageSize
        let bookWidth = pageSize.width * CGFloat(viewModel.layout.pagesPerView)
        let fillsWidth = !viewModel.isSpread && pageSize.width >= available.width - BookGeometry.stackMargin - 1

        return ZStack {
            PageStackEdges(viewModel: viewModel)

            if viewModel.pages.isEmpty {
                PaperBackground(theme: viewModel.theme)
            } else {
                PageCurlView(
                    viewModel.pages,
                    currentPage: Binding(
                        get: { viewModel.currentPage },
                        set: { viewModel.pageDidChange($0) }
                    ),
                    layout: viewModel.layout
                ) { page, side in
                    PageView(page: page, side: side, viewModel: viewModel)
                } blankPage: { side in
                    BlankPageView(side: side, viewModel: viewModel)
                }
            }
        }
        .frame(width: bookWidth, height: pageSize.height)
        // Một trang chiếm hết bề ngang thì gáy sách sát mép trái màn hình; còn lại đặt giữa bàn.
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: fillsWidth ? .leading : .center)
        .onChange(of: target, initial: true) {
            viewModel.updateLayout(target)
        }
    }

    // MARK: - Panels

    private func panel(_ panel: ReaderPanel) -> some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture { show(nil) }
                .transition(.opacity)

            Group {
                switch panel {
                case .settings:
                    ReaderSettingsPanel(viewModel: viewModel)
                case .contents:
                    ReaderContentsPanel(viewModel: viewModel) { page in
                        show(nil)
                        viewModel.isChromeVisible = false
                        viewModel.jump(to: page)
                    }
                }
            }
            .frame(maxWidth: 520)
            .padding(12)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private func show(_ panel: ReaderPanel?) {
        withAnimation(.spring(duration: 0.35)) {
            activePanel = panel
        }
    }
}

extension BookGeometry {
    /// Chỗ chừa cho mép giấy xếp chồng ở mỗi bên.
    static let stackMargin: CGFloat = 7
    private static let verticalMargin: CGFloat = 6

    /// Kích thước trang cho màn đọc theo bố cục đã chọn, chừa chỗ cho mép giấy xếp chồng
    /// (một bên khi 1 trang, hai bên khi 2 trang).
    static func reader(layout: PageCurlLayout, fitting available: CGSize) -> BookGeometry {
        let stackMargins = layout == .spread ? stackMargin * 2 : stackMargin
        return BookGeometry(
            layout: layout,
            fitting: CGSize(width: available.width - stackMargins, height: available.height - verticalMargin * 2)
        )
    }
}

/// Mép các trang giấy xếp chồng phía sau: bên phải là phần chưa đọc, bên trái (khi mở 2 trang)
/// là phần đã đọc.
private struct PageStackEdges: View {
    let viewModel: ReaderViewModel

    var body: some View {
        let total = max(viewModel.pages.count - 1, 1)
        let readFraction = Double(viewModel.currentPage) / Double(total)
        let paper = Color(viewModel.theme.paper)

        ZStack {
            if viewModel.isSpread {
                StackLayers(count: layerCount(readFraction), towardsTrailing: false, paper: paper)
            }
            StackLayers(count: layerCount(1 - readFraction), towardsTrailing: true, paper: paper)
        }
        .shadow(color: .black.opacity(0.35), radius: 6, x: 2, y: 2)
    }

    private func layerCount(_ fraction: Double) -> Int {
        Int((fraction * 4).rounded(.up))
    }
}

private struct StackLayers: View {
    let count: Int
    let towardsTrailing: Bool
    let paper: Color

    var body: some View {
        let shape = towardsTrailing
            ? UnevenRoundedRectangle(bottomTrailingRadius: 4, topTrailingRadius: 4)
            : UnevenRoundedRectangle(topLeadingRadius: 4, bottomLeadingRadius: 4)

        ForEach((0..<count).reversed(), id: \.self) { layer in
            let step = CGFloat(layer + 1)
            shape
                .fill(paper)
                .overlay { Color.black.opacity(0.06 + 0.05 * Double(layer)).clipShape(shape) }
                .overlay { shape.stroke(.black.opacity(0.12), lineWidth: 0.5) }
                .padding(.vertical, step * 0.8)
                .offset(x: (towardsTrailing ? 1 : -1) * step * 1.6)
        }
    }
}

#Preview {
    BookReaderView(book: .lighthouse, layout: .single, libraryButton: ReaderLibraryButton(systemImage: "chevron.backward") {})
}
