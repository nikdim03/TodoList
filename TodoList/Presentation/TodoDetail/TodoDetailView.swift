import SwiftUI

struct TodoDetailView: View {
    @StateObject var presenter: TodoDetailPresenter
    init(presenter: TodoDetailPresenter) {
        _presenter = StateObject(wrappedValue: presenter)
    }
    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: LayoutMetrics.vStackDetailSpacing
            ) {
                TextField(
                    Strings.detailTitlePlaceholder,
                    text: Binding(
                        get: { presenter.title },
                        set: { presenter.onTitleChanged($0) }
                    )
                )
                .font(AppFont.largeTitle)
                .textFieldStyle(.plain)
                .accessibilityIdentifier(A11yId.detailTitleField)
                .padding(.top, LayoutMetrics.detailTopPadding)
                Text(
                    presenter.createdAt.formatted(
                        Date.FormatStyle().day().month(.twoDigits).year(
                            .twoDigits
                        ).locale(Locale.enUSPOSIX)
                    )
                )
                .font(AppFont.meta)
                .foregroundColor(.brandLightGray)
                .accessibilityIdentifier(A11yId.detailCreatedDateLabel)
                ZStack(alignment: .topLeading) {
                    if presenter.detail.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty {
                        Text(Strings.detailNotesPlaceholder).font(
                            AppFont.description
                        )
                        .foregroundColor(.brandLightGray)
                        .padding(
                            .horizontal,
                            Metrics.detailNotesPlaceholderHorizontal
                        )
                        .padding(
                            .vertical,
                            Metrics.detailNotesPlaceholderVertical
                        )
                    }
                    TextEditor(
                        text: Binding(
                            get: { presenter.detail },
                            set: { presenter.onDetailChanged($0) }
                        )
                    )
                    .font(AppFont.description)
                    .frame(minHeight: Metrics.detailNotesMinHeight)
                    .accessibilityIdentifier(A11yId.detailDescriptionEditor)
                    .padding(.horizontal, Metrics.zero)
                }
            }
            .padding(.horizontal, Metrics.detailHorizontalPadding)
            .padding(.bottom, LayoutMetrics.detailBottomPadding)
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
                    HStack(spacing: LayoutMetrics.backButtonSpacing) {
                        Image(systemName: Icons.backChevron)
                        Text(Strings.detailBack).font(AppFont.backButton)
                    }
                }
            )
            .tint(.brandYellow)
            .accessibilityIdentifier(A11yId.detailBackButton)
        }
    }
}
