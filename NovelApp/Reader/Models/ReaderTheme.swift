//
//  ReaderTheme.swift
//  NovelApp
//

import SwiftUI
import UIKit

enum ReaderTheme: String, CaseIterable, Identifiable {
    case paper
    case sepia
    case night

    var id: String { rawValue }

    var name: String {
        switch self {
        case .paper: "Giấy"
        case .sepia: "Cổ điển"
        case .night: "Ban đêm"
        }
    }

    /// Màu giấy, dùng cho cả UIKit (vẽ chữ) và SwiftUI.
    var paper: UIColor {
        switch self {
        case .paper: UIColor(red: 0.985, green: 0.970, blue: 0.940, alpha: 1)
        case .sepia: UIColor(red: 0.957, green: 0.910, blue: 0.808, alpha: 1)
        case .night: UIColor(red: 0.145, green: 0.137, blue: 0.129, alpha: 1)
        }
    }

    var ink: UIColor {
        switch self {
        case .paper: UIColor(red: 0.13, green: 0.12, blue: 0.11, alpha: 1)
        case .sepia: UIColor(red: 0.30, green: 0.22, blue: 0.14, alpha: 1)
        case .night: UIColor(red: 0.80, green: 0.77, blue: 0.72, alpha: 1)
        }
    }

    /// Màu chữ phụ: header, số trang, nhãn chương.
    var faintInk: UIColor { ink.withAlphaComponent(0.55) }

    /// Màu "mặt bàn" phía sau cuốn sách.
    var desk: Color {
        switch self {
        case .paper: Color(red: 0.36, green: 0.27, blue: 0.20)
        case .sepia: Color(red: 0.30, green: 0.22, blue: 0.15)
        case .night: Color(red: 0.05, green: 0.05, blue: 0.05)
        }
    }

    var colorScheme: ColorScheme { self == .night ? .dark : .light }
}

enum ReaderFont: String, CaseIterable, Identifiable {
    case georgia = "Georgia"
    case palatino = "Palatino"
    case baskerville = "Baskerville"

    var id: String { rawValue }

    // Cả ba font đều có đủ dấu tiếng Việt.
    func uiFont(size: CGFloat, bold: Bool = false) -> UIFont {
        let base = UIFont(name: rawValue, size: size) ?? .systemFont(ofSize: size)
        guard bold, let descriptor = base.fontDescriptor.withSymbolicTraits(.traitBold) else { return base }
        return UIFont(descriptor: descriptor, size: size)
    }
}
