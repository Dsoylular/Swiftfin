//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2025 Jellyfin & Jellyfin Contributors
//

import CollectionVGrid
import Defaults
import Factory
import JellyfinAPI
import Stinsen
import SwiftUI

struct FavouritesView: View {
    @EnvironmentObject
    private var router: FavouritesCoordinator.Router // Changed from MediaCoordinator.Router

    @StateObject
    private var viewModel = MediaViewModel()

    var body: some View {
        ZStack {
            // Simple placeholder view while routing
            DelayedProgressView()
        }
        .navigationTitle(L10n.favorites)
        .onFirstAppear {
            // Create favorites view model
            let favoritesViewModel = ItemLibraryViewModel(
                title: L10n.favorites,
                id: "favorites",
                filters: .favorites
            )

            // Route directly to favorites library
            router.route(to: \.library, favoritesViewModel)
        }
    }
}
