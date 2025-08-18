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
            VStack(spacing: 0) {
                searchBar
                Spacer().frame(height: 16)
                listContent
            }
            .navigationTitle("Задачи")
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
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundStyle(
                .brandLightGray
            )
            ZStack(alignment: .leading) {
                if search.isEmpty {
                    Text("Search").font(AppFont.search).foregroundColor(
                        .brandLightGray
                    )
                }
                TextField("", text: $search)
                    .font(AppFont.search)
                    .textFieldStyle(.plain)
                    .onChange(of: search) { _, newValue in
                        presenter.onSearch(newValue)
                    }
            }
            if !search.isEmpty {
                Button {
                    search = ""
                    presenter.onSearch("")
                } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(
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
                        ? "stop.circle.fill" : "mic.fill"
                )
                .font(IconFont.mic)
                .frame(width: 36, height: 36)
                .foregroundStyle(.brandLightGray)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12).fill(Color.brandDarkGray)
        )
        .padding(.horizontal, 16)
    }

    private var listContent: some View {
        List {
            ForEach(presenter.items.indices, id: \.self) { index in
                let viewModel = presenter.items[index]
                VStack(spacing: 0) {
                    TaskRow(viewModel: viewModel, isActive: activeContextMenuTaskId == viewModel.id) {
                        presenter.onToggle(id: viewModel.id)
                    } open: {
                        presenter.onSelect(id: viewModel.id)
                    }
                    .blur(radius: activeContextMenuTaskId != nil ? 4 : 0)
                    .id(viewModel.id)
                    .contentShape(Rectangle())
                    .onTapGesture { presenter.onSelect(id: viewModel.id) }
                    .contextMenu {
                        Button {
                            presenter.onSelect(id: viewModel.id)
                        } label: {
                            Label {
                                Text("Редактировать")
                            } icon: {
                                Image("icon_edit").renderingMode(.template)
                            }
                        }
                        Button {
                            shareText = presenter.shareText(for: viewModel.id)
                            showShare = true
                        } label: {
                            Label {
                                Text("Поделиться")
                            } icon: {
                                Image("icon_share").renderingMode(.template)
                            }
                        }
                        Button(role: .destructive) {
                            presenter.onDelete(id: viewModel.id)
                        } label: {
                            Label {
                                Text("Удалить")
                            } icon: {
                                Image("icon_delete").renderingMode(.template)
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
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.clear)
                            ContextMenuPreviewLifecycle(
                                onOpen: { activeContextMenuTaskId = viewModel.id },
                                onClose: {
                                    if activeContextMenuTaskId == viewModel.id {
                                        activeContextMenuTaskId = nil
                                    }
                                }
                            )
                            .frame(width: 0, height: 0)
                        }
                        .frame(
                            idealWidth: UIScreen.main.bounds.width * 0.9,
                            maxWidth: UIScreen.main.bounds.width * 0.95,
                            alignment: .leading
                        )
                        .background(Color.brandDarkGray)
                        .scrollDisabled(true)
                    }

                    // Custom divider (design-system color + spacing) except after last cell
                    if index < presenter.items.count - 1 {
                        Rectangle()
                            .fill(Color.dividerGray)
                            .frame(height: 0.5)
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
                    .accessibilityIdentifier("task_count_label")
                HStack {
                    Spacer()
                    Button {
                        presenter.onAddTapped()
                    } label: {
                        Image(systemName: "square.and.pencil").font(
                            IconFont.action
                        ).foregroundStyle(.brandYellow)
                    }.buttonStyle(.plain).accessibilityIdentifier(
                        "add_task_button"
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
        HStack(alignment: .top, spacing: 12) {
            if !isActive {
                Image(
                    systemName: viewModel.isCompleted ? "checkmark.circle" : "circle"
                )
                .font(IconFont.status)
                .foregroundStyle(viewModel.isCompleted ? .brandYellow : .secondary)
                .frame(width: 24, height: 24, alignment: .top)
                .contentShape(Rectangle())
                .onTapGesture(perform: toggle)
                .accessibilityIdentifier("task_status_\(viewModel.id)")
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.title)
                    .font(AppFont.listItemTitle)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(viewModel.isCompleted ? .secondary : .primary)
                    .strikethrough(
                        viewModel.isCompleted,
                        pattern: .solid,
                        color: .secondary
                    )
                    .accessibilityIdentifier("task_title_\(viewModel.id)")
                Text(viewModel.detail)
                    .font(AppFont.meta)
                    .foregroundStyle(viewModel.isCompleted ? .secondary : .primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("task_detail_\(viewModel.id)")
                Text(viewModel.createdDate)
                    .font(AppFont.meta)
                    .foregroundStyle(.brandLightGray)
                    .accessibilityIdentifier("task_created_\(viewModel.id)")
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
