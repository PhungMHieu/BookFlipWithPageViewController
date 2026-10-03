//
//  ReaderPanels.swift
//  NovelApp
//

import SwiftUI

/// Panel cài đặt và mục lục được vẽ ngay trong màn đọc thay vì dùng `.sheet`:
/// khi present sheet, UIKit gửi appearance transition xuống các UIHostingController con
/// của UIPageViewController và các trang bị mất chữ cho đến khi sheet đóng.
enum ReaderPanel {
    case settings
    case contents
}

struct ReaderSettingsPanel: View {
    let viewModel: ReaderViewModel

    var body: some View {
        VStack(spacing: 22) {
            fontSizeRow
            fontRow
            themeRow
        }
        .padding(20)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
    }

    private var fontSizeRow: some View {
        HStack {
            Button {
                viewModel.changeFontSize(by: -1)
            } label: {
                Text("A")
                    .font(.system(size: 15, design: .serif))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .disabled(viewModel.fontSize <= ReaderViewModel.fontSizeRange.lowerBound)

            Text("\(Int(viewModel.fontSize))")
                .font(.headline.monospacedDigit())
                .frame(width: 48)

            Button {
                viewModel.changeFontSize(by: 1)
            } label: {
                Text("A")
                    .font(.system(size: 24, design: .serif))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .disabled(viewModel.fontSize >= ReaderViewModel.fontSizeRange.upperBound)
        }
        .buttonStyle(.glass)
    }

    private var fontRow: some View {
        HStack(spacing: 10) {
            ForEach(ReaderFont.allCases) { font in
                let isSelected = font == viewModel.font
                Button {
                    viewModel.setFont(font)
                } label: {
                    Text(font.rawValue)
                        .font(.custom(font.rawValue, fixedSize: 15))
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.accentColor : .secondary.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                        }
                        .contentShape(Rectangle())
                }
                .foregroundStyle(.primary)
            }
        }
    }

    private var themeRow: some View {
        HStack(spacing: 20) {
            ForEach(ReaderTheme.allCases) { theme in
                let isSelected = theme == viewModel.theme
                Button {
                    viewModel.setTheme(theme)
                } label: {
                    VStack(spacing: 6) {
                        Circle()
                            .fill(Color(theme.paper))
                            .overlay { Text("Aa").font(.custom("Georgia", fixedSize: 15)).foregroundStyle(Color(theme.ink)) }
                            .overlay { Circle().stroke(.secondary.opacity(0.3), lineWidth: 1) }
                            .padding(3)
                            .overlay { Circle().stroke(isSelected ? Color.accentColor : .clear, lineWidth: 2) }
                            .frame(width: 54, height: 54)
                        Text(theme.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct ReaderContentsPanel: View {
    let viewModel: ReaderViewModel
    let onSelect: (Int) -> Void

    var body: some View {
        let startPages = viewModel.chapterStartPages

        VStack(alignment: .leading, spacing: 4) {
            Text("Mục lục")
                .font(.headline)
                .padding(.horizontal, 8)
                .padding(.bottom, 6)

            ForEach(Array(zip(viewModel.book.chapters, startPages).enumerated()), id: \.offset) { _, item in
                let (chapter, startPage) = item
                let isCurrent = viewModel.pages.indices.contains(viewModel.currentPage)
                    && viewModel.pages[viewModel.currentPage].chapterTitle == chapter.title

                Button {
                    onSelect(startPage)
                } label: {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(chapter.label.uppercased())
                                .font(.caption2)
                                .tracking(1.2)
                                .foregroundStyle(.secondary)
                            Text(chapter.title)
                                .font(.custom(viewModel.font.rawValue, size: 18))
                        }
                        Spacer()
                        Text("\(startPage + 1)")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                    .background {
                        if isCurrent {
                            RoundedRectangle(cornerRadius: 14).fill(.primary.opacity(0.07))
                        }
                    }
                    .contentShape(Rectangle())
                }
                .foregroundStyle(.primary)
            }
        }
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
    }
}
