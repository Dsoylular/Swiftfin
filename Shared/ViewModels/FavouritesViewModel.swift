//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2025 Jellyfin & Jellyfin Contributors
//

import Combine
import Foundation
import JellyfinAPI

final class FavouritesViewModel: ObservableObject {

    enum ViewState {
        case initial
        case loading
        case content
        case error(Error)
    }

    enum Action {
        case loadFavorites
    }

    // MARK: - Properties

    @Published
    private(set) var state: ViewState = .initial

    @Published
    private(set) var movies: [BaseItemDto] = []
    @Published
    private(set) var series: [BaseItemDto] = []
    @Published
    private(set) var episodes: [BaseItemDto] = []
    @Published
    private(set) var collections: [BaseItemDto] = []
    @Published
    private(set) var people: [BaseItemDto] = []

    private var cancellables = Set<AnyCancellable>()

    var hasNoFavorites: Bool {
        movies.isEmpty &&
            series.isEmpty &&
            episodes.isEmpty &&
            collections.isEmpty &&
            people.isEmpty
    }

    // MARK: - Public Methods

    func send(_ action: Action) {
        switch action {
        case .loadFavorites:
            loadFavorites()
        }
    }

    @MainActor
    func refreshFavorites() async {
        loadFavorites()
    }

    // MARK: - Private Methods

    private func loadFavorites() {
        if case .loading = state {
            return
        }

        state = .loading

        // Reset collections
        movies = []
        series = []
        episodes = []
        collections = []
        people = []

//        let userId = SessionManager.shared.currentSession.user.id
//
//        JellyfinAPI.ItemsAPI.getItems(
//            userID: userId,
//            isFavorite: true,
//            limit: 100,
//            fields: [.primaryImageAspectRatio, .basicSyncInfo]
//        )
//        .sink(
//            receiveCompletion: { [weak self] completion in
//                guard let self = self else { return }
//
//                if case let .failure(error) = completion {
//                    self.state = .error(error)
//                }
//            },
//            receiveValue: { [weak self] response in
//                guard let self = self else { return }
//
//                self.processItems(response.items ?? [])
//                self.state = .content
//            }
//        )
//        .store(in: &cancellables)
    }

    private func processItems(_ items: [BaseItemDto]) {
        for item in items {
            guard let type = item.type else { continue }

            switch type {
            case .movie:
                movies.append(item)
            case .series:
                series.append(item)
            case .episode:
                episodes.append(item)
            case .boxSet:
                collections.append(item)
            case .person:
                people.append(item)
            default:
                // Ignore other types
                break
            }
        }
    }
}
