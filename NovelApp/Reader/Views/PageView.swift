//
//  PageView.swift
//  NovelApp
//

import PageCurlKit
import SwiftUI
import UIKit

enum PageMetrics {
    /// Header/footer co theo chiều cao trang, để trang thấp (iPhone xoay ngang) còn đủ chỗ cho chữ.
    static func headerHeight(for pageHeight: CGFloat) -> CGFloat {
        min(56, max(30, (pageHeight * 0.075).rounded()))
    }

    static func footerHeight(for pageHeight: CGFloat) -> CGFloat {
        min(52, max(28, (pageHeight * 0.07).rounded()))
    }

    static func horizontalMargin(for pageWidth: CGFloat) -> CGFloat {
        max(26, (pageWidth * 0.075).rounded())
    }

    /// Kích thước vùng chữ — dùng chung cho dàn trang và hiển thị.
    static func textSize(for pageSize: CGSize) -> CGSize {
        CGSize(
            width: floor(pageSize.width - horizontalMargin(for: pageSize.width) * 2),
            height: floor(pageSize.height - headerHeight(for: pageSize.height) - footerHeight(for: pageSize.height))
        )
    }
}

/// Một trang giấy: header, vùng chữ đã dàn sẵn, số trang.
struct PageView: View {
    let page: BookPage
    let side: PageSide
    let viewModel: ReaderViewModel

    var body: some View {
        let theme = viewModel.theme
        let pageHeight = viewModel.pageSize.height

        VStack(spacing: 0) {
            header(theme: theme)
                .frame(height: PageMetrics.headerHeight(for: pageHeight))

            PageTextView(page: page, theme: theme)
                .frame(width: page.textSize.width, height: page.textSize.height)

            footer(theme: theme)
                .frame(height: PageMetrics.footerHeight(for: pageHeight))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { PaperBackground(theme: theme, side: side) }
        .overlay { ChromeTapZone(viewModel: viewModel) }
    }

    @ViewBuilder
    private func header(theme: ReaderTheme) -> some View {
        // Sách in không đặt running header ở trang mở đầu chương.
        if !page.isChapterStart {
            // Như sách in: trang trái ghi tên sách, trang phải ghi tên chương.
            Text((side == .left ? viewModel.book.title : page.chapterTitle).uppercased())
                .font(.custom(viewModel.font.rawValue, fixedSize: 10.5))
                .tracking(1.8)
                .lineLimit(1)
                .foregroundStyle(Color(theme.faintInk))
                .frame(width: page.textSize.width)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 16)
                .padding(.top, 4)
        } else {
            Color.clear
        }
    }

    private func footer(theme: ReaderTheme) -> some View {
        // Số trang nằm ở góc ngoài khi mở 2 trang, ở giữa khi chỉ có 1 trang.
        let alignment: Alignment = switch side {
        case .single: .center
        case .left: .leading
        case .right: .trailing
        }

        return Text("\(page.index + 1)")
            .font(.custom(viewModel.font.rawValue, fixedSize: 12))
            .monospacedDigit()
            .foregroundStyle(Color(theme.faintInk))
            .frame(width: page.textSize.width, alignment: alignment)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 14)
    }
}

/// Trang trắng cuối sách, để số trang luôn chẵn ở chế độ 2 trang.
struct BlankPageView: View {
    let side: PageSide
    let viewModel: ReaderViewModel

    var body: some View {
        PaperBackground(theme: viewModel.theme, side: side)
            .overlay { ChromeTapZone(viewModel: viewModel) }
    }
}

/// Chạm giữa trang để hiện/ẩn thanh điều khiển. Hai mép trang để trống
/// cho UIPageViewController xử lý chạm để lật trang.
private struct ChromeTapZone: View {
    let viewModel: ReaderViewModel

    var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .padding(.horizontal, 72)
            .padding(.vertical, 64)
            .onTapGesture { viewModel.toggleChrome() }
    }
}

// MARK: - Paper

struct PaperBackground: View {
    let theme: ReaderTheme
    var side: PageSide = .single

    var body: some View {
        let isNight = theme == .night
        let spineOnTrailing = side.spineEdge == .trailing
        let outerRadius: CGFloat = 4
        let shape = spineOnTrailing
            ? UnevenRoundedRectangle(topLeadingRadius: outerRadius, bottomLeadingRadius: outerRadius)
            : UnevenRoundedRectangle(bottomTrailingRadius: outerRadius, topTrailingRadius: outerRadius)

        ZStack {
            Color(theme.paper)

            Image(uiImage: PaperGrain.image)
                .resizable(resizingMode: .tile)
                .opacity(isNight ? 0.35 : 1)

            // Bóng gáy sách: giấy uốn cong vào phía gáy nên tối dần về mép gáy.
            LinearGradient(
                stops: [
                    .init(color: .black.opacity(isNight ? 0.45 : 0.20), location: 0),
                    .init(color: .black.opacity(isNight ? 0.18 : 0.07), location: 0.035),
                    .init(color: .clear, location: 0.12),
                    .init(color: .clear, location: 0.94),
                    .init(color: .black.opacity(isNight ? 0.12 : 0.04), location: 1),
                ],
                startPoint: spineOnTrailing ? .trailing : .leading,
                endPoint: spineOnTrailing ? .leading : .trailing
            )

            // Ánh sáng hắt nhẹ vào giữa trang.
            RadialGradient(
                colors: [.white.opacity(isNight ? 0.03 : 0.18), .clear],
                center: UnitPoint(x: spineOnTrailing ? 0.45 : 0.55, y: 0.4),
                startRadius: 0,
                endRadius: 520
            )
        }
        .clipShape(shape)
        .ignoresSafeArea()
    }
}

/// Lớp vân giấy li ti, sinh một lần rồi lát lặp lại.
enum PaperGrain {
    static let image: UIImage = {
        let size = CGSize(width: 160, height: 160)
        return UIGraphicsImageRenderer(size: size).image { context in
            var generator = SystemRandomNumberGenerator()
            for _ in 0..<1400 {
                let point = CGPoint(
                    x: CGFloat.random(in: 0..<size.width, using: &generator),
                    y: CGFloat.random(in: 0..<size.height, using: &generator)
                )
                let isDark = Bool.random(using: &generator)
                let alpha = CGFloat.random(in: 0.015...0.05, using: &generator)
                (isDark ? UIColor.black : UIColor.white).withAlphaComponent(alpha).setFill()
                let length = CGFloat.random(in: 0.6...2.2, using: &generator)
                context.fill(CGRect(origin: point, size: CGSize(width: length, height: 0.6)))
            }
        }
    }()
}

// MARK: - Text

/// Vẽ đúng phần glyph của container trang từ layout manager dùng chung của chương.
struct PageTextView: UIViewRepresentable {
    let page: BookPage
    /// Không dùng trực tiếp — có mặt để `updateUIView` chạy lại và vẽ lại khi đổi theme.
    let theme: ReaderTheme

    func makeUIView(context: Context) -> PageTextUIView {
        let view = PageTextUIView()
        view.backgroundColor = .clear
        view.isOpaque = false
        view.isUserInteractionEnabled = false
        view.contentMode = .redraw
        return view
    }

    func updateUIView(_ view: PageTextUIView, context: Context) {
        view.page = page
        view.setNeedsDisplay()
    }
}

final class PageTextUIView: UIView {
    var page: BookPage?

    override func draw(_ rect: CGRect) {
        guard let page else { return }
        let layoutManager = page.chapterLayout.layoutManager
        let glyphRange = layoutManager.glyphRange(for: page.textContainer)
        layoutManager.drawBackground(forGlyphRange: glyphRange, at: .zero)
        layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: .zero)
    }
}
