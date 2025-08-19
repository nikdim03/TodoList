import SwiftUI

struct TodoListView: View {
    @StateObject var presenter: TodoListPresenter
    @StateObject var router: TodoListRouter
    @State private var search: String = ""
    @State private var shareText: String = ""
    @State private var showShare: Bool = false
    @State private var activeContextMenuTaskId: Int64?

    init(presenter: TodoListPresenter, router: TodoListRouter) {
        _presenter = StateObject(wrappedValue: presenter)
        _router = StateObject(wrappedValue: router)
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            ZStack {
                VStack(spacing: 0) {
                    searchBar
                    Spacer().frame(height: Metrics.listTopSpacer)
                    listContent
                }
                if presenter.isLoading && !presenter.isRefreshing {
                    loadingOverlay
                }
            }
            .navigationTitle(Strings.navTasksTitle)
            .navigationBarTitleDisplayMode(.large)
            .onAppear { presenter.onAppear() }
            .navigationDestination(for: TodoListRoute.self) { route in
                router.destination(for: route, presenter: presenter)
            }
            .toolbar { bottomToolbar }
            .toolbarBackground(Color.brandDarkGray, for: .bottomBar)
            .toolbarBackground(.visible, for: .bottomBar)
        }
    }

    // MARK: - UI Components
    private var searchBar: some View {
        HStack(spacing: Metrics.taskTextStackSpacing * 2) {
            Image(systemName: Icons.search).foregroundStyle(
                .brandLightGray
            )
            ZStack(alignment: .leading) {
                if search.isEmpty {
                    Text(Strings.searchPlaceholder).font(AppFont.search)
                        .foregroundColor(
                            .brandLightGray
                        )
                }
                TextField("", text: $search)
                    .font(AppFont.search)
                    .textFieldStyle(.plain)
                    .onChange(of: search) { _, newValue in
                        presenter.onSearch(newValue)
                    }
                    .accessibilityIdentifier(A11yId.searchField)
            }
            if !search.isEmpty {
                Button {
                    search = ""
                    presenter.onSearch("")
                } label: {
                    Image(systemName: Icons.clearText).foregroundStyle(
                        .tertiary
                    )
                }
                .buttonStyle(.plain)
            }
            Button {
                presenter.onMicTapped()
            } label: {
                Image(
                    systemName: presenter.isDictating
                        ? Icons.micStop : Icons.mic
                )
                .font(IconFont.mic)
                .frame(
                    width: Metrics.searchMicFrame,
                    height: Metrics.searchMicFrame
                )
                .foregroundStyle(.brandLightGray)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Metrics.searchBarHorizontalPad)
        .padding(.vertical, Metrics.searchBarVerticalPad)
        .background(
            RoundedRectangle(cornerRadius: Metrics.searchBarCornerRadius).fill(
                Color.brandDarkGray
            )
        )
        .padding(.horizontal, LayoutPadding.screenHorizontal)
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(Metrics.loadingOverlayOpacity).ignoresSafeArea()
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.brandYellow)
                .scaleEffect(Metrics.loadingOverlayScale)
                .accessibilityIdentifier(A11yId.loadingIndicator)
        }
        .transition(.opacity)
        .animation(
            .easeInOut(duration: Timings.loadingAnimation),
            value: presenter.isLoading
        )
    }

    private var listContent: some View {
        List {
            ForEach(presenter.items.indices, id: \.self) { index in
                let viewModel = presenter.items[index]
                VStack(spacing: 0) {
                    TaskRow(
                        viewModel: viewModel,
                        isActive: activeContextMenuTaskId == viewModel.id
                    ) {
                        presenter.onToggle(id: viewModel.id)
                    } open: {
                        presenter.onSelect(id: viewModel.id)
                    }
                    .blur(
                        radius: activeContextMenuTaskId != nil
                            ? Metrics.blurRadiusActiveContextMenu : 0
                    )
                    .id(viewModel.id)
                    .contentShape(Rectangle())
                    .onTapGesture { presenter.onSelect(id: viewModel.id) }
                    .contextMenu {
                        Button {
                            presenter.onSelect(id: viewModel.id)
                        } label: {
                            Label {
                                Text(Strings.contextEdit)
                            } icon: {
                                Image(Icons.edit).renderingMode(.template)
                            }
                        }
                        Button {
                            shareText = presenter.shareText(for: viewModel.id)
                            showShare = true
                        } label: {
                            Label {
                                Text(Strings.contextShare)
                            } icon: {
                                Image(Icons.share).renderingMode(.template)
                            }
                        }
                        Button(role: .destructive) {
                            presenter.onDelete(id: viewModel.id)
                        } label: {
                            Label {
                                Text(Strings.contextDelete)
                            } icon: {
                                Image(Icons.delete).renderingMode(.template)
                            }
                        }
                    } preview: {
                        VStack(spacing: 0) {
                            TaskRow(
                                viewModel: viewModel,
                                isActive: true,
                                toggle: {},
                                open: {}
                            )
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, Metrics.contextMenuPreviewH)
                            .padding(.vertical, Metrics.contextMenuPreviewV)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.clear)
                            ContextMenuPreviewLifecycle(
                                onOpen: {
                                    activeContextMenuTaskId = viewModel.id
                                },
                                onClose: {
                                    if activeContextMenuTaskId == viewModel.id {
                                        activeContextMenuTaskId = nil
                                    }
                                }
                            )
                            .frame(width: Metrics.zero, height: Metrics.zero)
                        }
                        .frame(
                            idealWidth: UIScreen.main.bounds.width
                                * Metrics.previewIdealWidthFactor,
                            maxWidth: UIScreen.main.bounds.width
                                * Metrics.previewMaxWidthFactor,
                            alignment: .leading
                        )
                        .background(Color.brandDarkGray)
                        .scrollDisabled(true)
                    }

                    // Custom divider (design-system color + spacing) except after last cell
                    if index < presenter.items.count - 1 {
                        Rectangle().fill(Color.dividerGray).frame(
                            height: Metrics.dividerHeight
                        )
                        .padding(.top, LayoutPadding.cellGapVertical)
                        Spacer().frame(height: LayoutPadding.cellGapVertical)
                    }
                }
                .padding(.horizontal, LayoutPadding.listRowHorizontal)
                .listRowInsets(
                    .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                )
                .listRowBackground(Color.black)
                .background(Color.black)
                .listRowSeparator(.hidden)
            }
            .onDelete { indexSet in
                indexSet.map { presenter.items[$0].id }.forEach {
                    presenter.onDelete(id: $0)
                }
            }
        }
        .accessibilityIdentifier(A11yId.todoList)
        .refreshable { await presenter.refresh() }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .background(Color.black)
        .sheet(isPresented: $showShare) {
            ShareSheet(activityItems: [shareText])
        }
        .overlay(alignment: .center) {
            if activeContextMenuTaskId != nil { Color.clear }
        }
    }

    @ToolbarContentBuilder
    private var bottomToolbar: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            ZStack {
                Text(presenter.taskCountLabel)
                    .font(AppFont.tinyMeta)
                    .foregroundStyle(.taskCountGray)
                    .accessibilityIdentifier(A11yId.taskCountLabel)
                HStack {
                    Spacer()
                    Button {
                        presenter.onAddTapped()
                    } label: {
                        Image(systemName: Icons.add).font(
                            IconFont.action
                        ).foregroundStyle(.brandYellow)
                    }.buttonStyle(.plain).accessibilityIdentifier(
                        A11yId.addTaskButton
                    )
                }
            }
        }
    }
}

// MARK: - Row View
private struct TaskRow: View {
    let viewModel: TodoListItemViewModel
    let isActive: Bool
    let toggle: () -> Void
    let open: () -> Void
    var body: some View {
        HStack(alignment: .top, spacing: Metrics.taskRowInnerSpacing) {
            if !isActive {
                Image(
                    systemName: viewModel.isCompleted
                        ? Icons.statusOn : Icons.statusOff
                )
                .font(IconFont.status)
                .foregroundStyle(
                    viewModel.isCompleted ? .brandYellow : .brandLightGray
                )
                .frame(
                    width: Metrics.taskRowIconFrame,
                    height: Metrics.taskRowIconFrame,
                    alignment: .top
                )
                .contentShape(Rectangle())
                .onTapGesture(perform: toggle)
                .accessibilityIdentifier(A11yId.taskStatus(viewModel.id))
            }
            VStack(alignment: .leading, spacing: Metrics.taskTextStackSpacing) {
                Text(viewModel.title)
                    .font(AppFont.listItemTitle)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(
                        viewModel.isCompleted ? .brandLightGray : .primary
                    )
                    .strikethrough(
                        viewModel.isCompleted,
                        pattern: .solid,
                        color: .brandLightGray
                    )
                    .accessibilityIdentifier(A11yId.taskTitle(viewModel.id))
                Text(viewModel.detail)
                    .font(AppFont.meta)
                    .foregroundStyle(
                        viewModel.isCompleted ? .brandLightGray : .primary
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier(A11yId.taskDetail(viewModel.id))
                Text(viewModel.createdDate)
                    .font(AppFont.meta)
                    .foregroundStyle(.brandLightGray)
                    .accessibilityIdentifier(A11yId.taskCreated(viewModel.id))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: open)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ContextMenuPreviewLifecycle: View {
    let onOpen: () -> Void
    let onClose: () -> Void
    var body: some View {
        Color.clear.onAppear(perform: onOpen).onDisappear(perform: onClose)
    }
}
