//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2025 Jellyfin & Jellyfin Contributors
//

import CollectionHStack
import Defaults
import JellyfinAPI
import OrderedCollections
import SwiftUI

extension HomeView {

    struct TrendingView: View {

        @Default(.Customization.trendingPosterType)
        private var trendingPosterType

        @EnvironmentObject
        private var router: HomeCoordinator.Router

        @ObservedObject
        var viewModel: TrendingViewModel

        var body: some View {
            if viewModel.elements.isNotEmpty {
                PosterHStack(
                    title: "Trending",
                    type: trendingPosterType,
                    items: viewModel.elements
                )
                .trailing {
                    SeeAllButton()
                        .onSelect {
                            router.route(to: \.library, viewModel)
                        }
                }
                .onSelect { item in
                    router.route(to: \.item, item)
                }
            }
        }
    }
}
