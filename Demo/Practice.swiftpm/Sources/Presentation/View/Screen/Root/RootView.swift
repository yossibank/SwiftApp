import SwiftUI

struct RootView: View {
    @StateObject var viewModel: RootViewModel

    @State private var isSelectedFloatingButton = false

    init(viewModel: RootViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                Text("欲しいものリスト")
                    .font(.system(size: 20, weight: .bold))
                    .padding([.top, .leading], 16)
                    .frame(maxWidth: .infinity, alignment: .leading)

                List {
                    ForEach(viewModel.state.itemList, id: \.self) { item in
                        VStack {
                            HStack(alignment: .top, spacing: 12) {
                                AsyncImageView(
                                    url: item.imageURL,
                                    successImage: { image in
                                        image.resizable()
                                    },
                                    failureImage: {
                                        Image("noImage", bundle: .module).resizable()
                                    },
                                    placeholderImage: {
                                        Image("noImage", bundle: .module).resizable()
                                    }
                                )
                                .frame(width: 128, height: 128)
                                .clipShape(RoundedRectangle(cornerRadius: 4))

                                VStack(alignment: .leading, spacing: 12) {
                                    Text(item.name)
                                        .font(.system(size: 16, weight: .bold))
                                        .lineLimit(4)
                                        .fixedSize(horizontal: false, vertical: true)

                                    HStack {
                                        Text(item.price)
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundStyle(.red)

                                        Image(item.searchEngine.rawValue, bundle: .module)
                                            .resizable()
                                            .frame(width: 16, height: 16)
                                    }
                                }
                            }

                            Divider()
                        }
                        .listRowSeparator(.hidden)
                        .onTapGesture {
                            viewModel.didTapItem(item)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(
                                role: .destructive,
                                action: {
                                    viewModel.deleteItem(item: item)
                                },
                                label: {
                                    Image(systemName: "trash")
                                }
                            )
                        }
                    }
                    .onMove { offsets, destination in
                        viewModel.moveItem(
                            from: offsets,
                            to: destination
                        )
                    }
                    .onDelete { offsets in
                        viewModel.deleteItem(from: offsets)
                    }
                }
                .listStyle(.plain)
                .toolbar {
                    if viewModel.state.isShowEditButton {
                        EditButton()
                            .bold()
                    }
                }
            }

            FloatingActionButtonView(
                isSelected: $viewModel.state.isSelectedButton,
                actionButtons: viewModel.makeFloatingActionButtons()
            )
            .padding(32)
        }
    }

    private struct SystemImageButton: View {
        let systemName: String
        let didTap: () -> Void

        var body: some View {
            Button(
                action: didTap,
                label: {
                    Image(systemName: systemName)
                        .resizable()
                        .frame(width: 48, height: 48)
                }
            )
        }
    }
}

#Preview {
    RootView(
        viewModel: .init(
            state: .init(),
            dependency: .init(userDefaultsClient: .init())
        )
    )
}
