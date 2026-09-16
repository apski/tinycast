import SwiftUI

/// The single-field prompt's state; reference semantics are what let the caller read it back.
@MainActor
@Observable
final class TextPromptState {
    var text: String
    let placeholder: String

    init(text: String, placeholder: String) {
        self.text = text
        self.placeholder = placeholder
    }
}

/// One text field, focused on appear — the whole of a generic text-prompt dialog.
struct TextPromptFields: View {
    @Bindable var state: TextPromptState
    @FocusState private var focused: Bool

    var body: some View {
        TextField("", text: $state.text, prompt: Text(state.placeholder))
            .focused($focused)
            .dialogTextField()
            .onAppear { focused = true }
    }
}
