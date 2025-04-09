//
//  TransparentTextEditor.swift
//  List It
//
//  Created by Abdul Moiz on 08/04/2025.
//

import Foundation
import SwiftUI

struct TransparentTextEditor: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textColor = UIColor.label
        textView.isScrollEnabled = true
        textView.delegate = context.coordinator
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TransparentTextEditor

        init(_ parent: TransparentTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}
