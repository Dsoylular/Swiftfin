//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2025 Jellyfin & Jellyfin Contributors
//

import CollectionHStack
import JellyfinAPI
import OrderedCollections
import SwiftUI

extension HomeView {

    struct ContinueWatchingView: View {

        let rastroGreen = Color(red: 223 / 255, green: 255 / 255, blue: 96 / 255)

        @EnvironmentObject
        private var router: HomeCoordinator.Router

        @ObservedObject
        var viewModel: HomeViewModel

        // TODO: see how this looks across multiple screen sizes
        //       alongside PosterHStack + landscape
        // TODO: need better handling for iPadOS + portrait orientation
        private var columnCount: CGFloat {
            if UIDevice.isPhone {
                1.5
            } else {
                3.5
            }
        }

        var body: some View {
            if !viewModel.resumeItems.isEmpty {
                PosterHStack(
                    title: "Continue Watching", // Title here, replace with the localized string
                    type: .landscape, // Assuming you want a similar poster type as in RecentlyAddedView
                    items: viewModel.resumeItems
                )
                .trailing {
                    SeeAllButton() // Add functionality for "See All" button if needed
                        .onSelect {
                            // Handle navigation to another view if needed
                        }
                }
                .onSelect { item in
                    router.route(to: \.item, item)
                }
            }
        }
    }
}
