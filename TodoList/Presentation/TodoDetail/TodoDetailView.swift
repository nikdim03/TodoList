import SwiftUI

struct TodoDetailView: View {
    @StateObject var presenter: TodoDetailPresenter
    init(presenter: TodoDetailPresenter) {
        _presenter = StateObject(wrappedValue: presenter)
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TextField(
                    "Title",
                    text: Binding(
                        get: { presenter.title },
                        set: { presenter.onTitleChanged($0) }
                    )
                )
                .font(AppFont.largeTitle)
                .textFieldStyle(.plain)
                .accessibilityIdentifier("detail_title_field")
                .padding(.top, 12)
                Text(
                    presenter.createdAt,
                    format: Date.FormatStyle().day().month(.twoDigits).year(
                        .twoDigits
                    )
                )
                .font(AppFont.meta)
                .foregroundColor(.brandLightGray)
                .accessibilityIdentifier("detail_created_date_label")
                ZStack(alignment: .topLeading) {
                    if presenter.detail.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty {
                        Text("Notes...").font(AppFont.description)
                            .foregroundColor(.secondary).padding(.horizontal, 4)
                            .padding(.vertical, 8)
                    }
                    TextEditor(
                        text: Binding(
                            get: { presenter.detail },
                            set: { presenter.onDetailChanged($0) }
                        )
                    )
                    .font(AppFont.description)
                    .frame(minHeight: 160)
                    .accessibilityIdentifier("detail_description_editor")
                    .padding(.horizontal, 0)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar { backToolbar }
        .onAppear { presenter.onAppear() }
        .onDisappear { presenter.onClose() }
    }

    @ToolbarContentBuilder private var backToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(
                action: { presenter.onClose() },
                label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                        Text("Назад").font(AppFont.backButton)
                    }
                }
            )
            .tint(.brandYellow)
            .accessibilityIdentifier("detail_back_button")
        }
    }
}
