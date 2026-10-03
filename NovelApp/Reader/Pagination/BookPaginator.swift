//
//  BookPaginator.swift
//  NovelApp
//

import UIKit

/// Một trang sách đã được dàn chữ sẵn.
///
/// Mỗi trang là một `NSTextContainer` thuộc chung `NSLayoutManager` của chương,
/// nên ngắt dòng, căn đều và thụt đầu dòng giữa các trang luôn liền mạch như sách in.
struct BookPage: Identifiable {
    /// Gồm cả lượt dàn trang: dàn lại thì id đổi, nên view lật trang biết nội dung đã khác.
    struct ID: Hashable {
        let generation: Int
        let index: Int
    }

    let id: ID
    let chapterIndex: Int
    let chapterTitle: String
    let pageInChapter: Int
    let characterRange: NSRange
    let textContainer: NSTextContainer
    /// Giữ strong reference: text storage sở hữu layout manager, layout manager sở hữu container.
    let chapterLayout: ChapterLayout

    /// Số thứ tự trang trong cả cuốn, bắt đầu từ 0.
    var index: Int { id.index }
    var isChapterStart: Bool { pageInChapter == 0 }
    var textSize: CGSize { textContainer.size }
}

final class ChapterLayout {
    let textStorage: NSTextStorage
    let layoutManager: NSLayoutManager

    init(text: NSAttributedString) {
        textStorage = NSTextStorage(attributedString: text)
        layoutManager = NSLayoutManager()
        layoutManager.allowsNonContiguousLayout = false
        textStorage.addLayoutManager(layoutManager)
    }

    /// Đổi màu mực theo theme mà không phải dàn trang lại.
    func applyInk(_ theme: ReaderTheme) {
        let fullRange = NSRange(location: 0, length: textStorage.length)
        textStorage.beginEditing()
        textStorage.enumerateAttribute(.readerInkRole, in: fullRange) { value, range, _ in
            let color = (value as? String) == InkRole.faint.rawValue ? theme.faintInk : theme.ink
            textStorage.addAttribute(.foregroundColor, value: color, range: range)
        }
        textStorage.endEditing()
    }
}

enum InkRole: String {
    case main
    case faint
}

extension NSAttributedString.Key {
    static let readerInkRole = NSAttributedString.Key("NovelApp.readerInkRole")
}

enum BookPaginator {

    static func paginate(
        book: Book,
        generation: Int,
        textSize: CGSize,
        font: ReaderFont,
        fontSize: CGFloat,
        theme: ReaderTheme
    ) -> [BookPage] {
        guard textSize.width > 0, textSize.height > 0 else { return [] }

        var pages: [BookPage] = []
        for (chapterIndex, chapter) in book.chapters.enumerated() {
            let layout = ChapterLayout(text: attributedText(for: chapter, font: font, size: fontSize))
            layout.applyInk(theme)

            let layoutManager = layout.layoutManager
            var pageInChapter = 0
            while true {
                let container = NSTextContainer(size: textSize)
                container.lineFragmentPadding = 0
                layoutManager.addTextContainer(container)

                let glyphRange = layoutManager.glyphRange(for: container)
                // Trang quá nhỏ không chứa nổi một dòng: dừng để tránh lặp vô hạn.
                guard glyphRange.length > 0 else {
                    layoutManager.removeTextContainer(at: layoutManager.textContainers.count - 1)
                    break
                }

                pages.append(BookPage(
                    id: BookPage.ID(generation: generation, index: pages.count),
                    chapterIndex: chapterIndex,
                    chapterTitle: chapter.title,
                    pageInChapter: pageInChapter,
                    characterRange: layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil),
                    textContainer: container,
                    chapterLayout: layout
                ))
                pageInChapter += 1

                if NSMaxRange(glyphRange) >= layoutManager.numberOfGlyphs { break }
            }
        }
        return pages
    }

    // MARK: - Typography

    private static func attributedText(for chapter: Chapter, font: ReaderFont, size: CGFloat) -> NSAttributedString {
        let text = NSMutableAttributedString()

        let labelStyle = NSMutableParagraphStyle()
        labelStyle.alignment = .center
        labelStyle.paragraphSpacingBefore = size * 3.5
        labelStyle.paragraphSpacing = size * 0.7
        text.append(NSAttributedString(
            string: chapter.label.uppercased() + "\n",
            attributes: [
                .font: font.uiFont(size: size * 0.72),
                .kern: size * 0.18,
                .paragraphStyle: labelStyle,
                .readerInkRole: InkRole.faint.rawValue,
            ]
        ))

        let titleStyle = NSMutableParagraphStyle()
        titleStyle.alignment = .center
        titleStyle.lineHeightMultiple = 1.1
        titleStyle.paragraphSpacing = size * 0.5
        text.append(NSAttributedString(
            string: chapter.title + "\n",
            attributes: [
                .font: font.uiFont(size: size * 1.6),
                .paragraphStyle: titleStyle,
                .readerInkRole: InkRole.main.rawValue,
            ]
        ))

        let ornamentStyle = NSMutableParagraphStyle()
        ornamentStyle.alignment = .center
        ornamentStyle.paragraphSpacing = size * 2
        text.append(NSAttributedString(
            string: "❦\n",
            attributes: [
                .font: font.uiFont(size: size * 1.1),
                .paragraphStyle: ornamentStyle,
                .readerInkRole: InkRole.faint.rawValue,
            ]
        ))

        for (index, paragraph) in chapter.paragraphs.enumerated() {
            let style = NSMutableParagraphStyle()
            style.alignment = .justified
            style.lineHeightMultiple = 1.3
            style.paragraphSpacing = size * 0.15
            // Như sách in: đoạn đầu chương không thụt dòng.
            style.firstLineHeadIndent = index == 0 ? 0 : size * 1.5

            let isLast = index == chapter.paragraphs.count - 1
            text.append(NSAttributedString(
                string: paragraph + (isLast ? "" : "\n"),
                attributes: [
                    .font: font.uiFont(size: size),
                    .paragraphStyle: style,
                    .readerInkRole: InkRole.main.rawValue,
                ]
            ))
        }
        return text
    }
}
