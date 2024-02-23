import SwiftUI

struct RootView: View {
    @StateObject var viewModel: RootViewModel

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
                                    url: item.imageUrl,
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
                            print(item.price)
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
                    .onMove { _, _ in

                    }
                    .onDelete { _ in

                    }
                }
                .listStyle(.plain)
                .toolbar {
                    EditButton()
                }
            }

            HStack(spacing: 24) {
                SystemImageButton(
                    systemName: "plus.circle",
                    didTap: {
                        viewModel.didTapCreateButton()
                    }
                )
                SystemImageButton(
                    systemName: "magnifyingglass.circle",
                    didTap: {
                        viewModel.didTapSearchButton()
                    }
                )
            }
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
