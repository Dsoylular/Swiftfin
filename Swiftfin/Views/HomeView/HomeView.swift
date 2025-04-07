//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2025 Jellyfin & Jellyfin Contributors
//

import Defaults
import Factory
import Foundation
import SwiftUI

import SwiftUI

struct HomeView: View {

    @Default(.Customization.nextUpPosterType)
    private var nextUpPosterType
    @Default(.Customization.Home.showRecentlyAdded)
    private var showRecentlyAdded
    @Default(.Customization.recentlyAddedPosterType)
    private var recentlyAddedPosterType

    let rastroGreen = Color(red: 223 / 255, green: 255 / 255, blue: 96 / 255)

    @EnvironmentObject
    private var mainRouter: MainCoordinator.Router
    @EnvironmentObject
    private var router: HomeCoordinator.Router

    @StateObject
    private var viewModel = HomeViewModel()

    @State
    private var isSearchActive: Bool = false

    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {

                ForEach(viewModel.librariesFeaturing) { viewModel in
                    FeaturingView(viewModel: viewModel)
                }

                ContinueWatchingView(viewModel: viewModel)

                NextUpView(viewModel: viewModel.nextUpViewModel)
                    .onSetPlayed { item in
                        viewModel.send(.setIsPlayed(true, item))
                    }

                if showRecentlyAdded {
                    RecentlyAddedView(viewModel: viewModel.recentlyAddedViewModel)
                }

                // ForEach(viewModel.librariesLatest) { viewModel in
                //  LatestInLibraryView(viewModel: viewModel)
                // }

                ForEach(viewModel.librariesTrending) { viewModel in
                    TrendingView(viewModel: viewModel)
                }
            }
            .edgePadding(.vertical)
        }
        .refreshable {
            viewModel.send(.refresh)
        }
    }

    private func errorView(with error: some Error) -> some View {
        ErrorView(error: error)
            .onRetry {
                viewModel.send(.refresh)
            }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Custom Top Bar
                HStack(spacing: 15) {
                    Image("Rastro-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)

                    Text("RASTRO")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(rastroGreen)
                    Spacer()

                    if viewModel.backgroundStates.contains(.refresh) {
                        ProgressView()
                    }

                    ConnectButton()
                    SearchButton(isSearchActive: $isSearchActive)
                    SettingsBarButton(
                        server: viewModel.userSession.server,
                        user: viewModel.userSession.user
                    ) {
                        mainRouter.route(to: \.settings)
                    }
                }
                .padding(.horizontal)
                .frame(height: 80)
                .background(Color(.systemBackground))
                .shadow(radius: 1)

                Divider()

                switch viewModel.state {
                case .content:
                    contentView
                case let .error(error):
                    errorView(with: error)
                case .initial, .refreshing:
                    DelayedProgressView()
                }

                NavigationLink(
                    destination: SearchView(),
                    isActive: $isSearchActive
                ) {
                    EmptyView()
                }
            }
        }
        .onFirstAppear {
            viewModel.send(.refresh)
        }
        .sinceLastDisappear { interval in
            if interval > 60 || viewModel.notificationsReceived.contains(.itemMetadataDidChange) {
                viewModel.send(.backgroundRefresh)
                viewModel.notificationsReceived.remove(.itemMetadataDidChange)
            }
        }
    }
}
