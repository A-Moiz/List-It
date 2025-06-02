//
//  TransparentTextEditor.swift
//  List It
//
//  Created by Abdul Moiz on 08/04/2025.
//

import Foundation
import SwiftUI

struct TransparentTextEditor: UIViewRepresentable {
    // MARK: - Properties
    @Binding var text: String
    
    /// Creates and configures the `UITextView` instance
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
    
    /// Update the `UITextView` with the latest value from SwiftUI
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    /// Creates the coordinator used to handle `UITextViewDelegate` callbacks
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// A delegate class that synchronizes text changes between `UITextView` and the SwiftUI binding
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TransparentTextEditor
        
        init(_ parent: TransparentTextEditor) {
            self.parent = parent
        }
        
        /// Updates the binding whenever the text changes in `UITextView`
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}
