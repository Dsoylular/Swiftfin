//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2025 Jellyfin & Jellyfin Contributors
//

import Combine
import CoreStore
import Factory
import Get
import JellyfinAPI
import OrderedCollections

final class HomeViewModel: ViewModel, Stateful {

    // MARK: Action

    enum Action: Equatable {
        case backgroundRefresh
        case error(JellyfinAPIError)
        case setIsPlayed(Bool, BaseItemDto)
        case refresh
    }

    // MARK: BackgroundState

    enum BackgroundState: Hashable {
        case refresh
    }

    // MARK: State

    enum State: Hashable {
        case content
        case error(JellyfinAPIError)
        case initial
        case refreshing
    }

    @Published
    private(set) var librariesLatest: [LatestInLibraryViewModel] = []

    @Published
    private(set) var librariesTrending: [TrendingViewModel] = []

    @Published
    private(set) var librariesFeaturing: [FeaturingViewModel] = []

    @Published
    var resumeItems: OrderedSet<BaseItemDto> = []

    @Published
    var backgroundStates: Set<BackgroundState> = []
    @Published
    var state: State = .initial

    // TODO: replace with views checking what notifications were
    //       posted since last disappear
    @Published
    var notificationsReceived: NotificationSet = .init()

    private var backgroundRefreshTask: AnyCancellable?
    private var refreshTask: AnyCancellable?

    var nextUpViewModel: NextUpLibraryViewModel = .init()
    var recentlyAddedViewModel: RecentlyAddedLibraryViewModel = .init()
    var featuringViewModel: FeaturingViewModel = .init()

    override init() {
        super.init()

        Notifications[.itemMetadataDidChange]
            .publisher
            .sink { _ in
                // Necessary because when this notification is posted, even with asyncAfter,
                // the view will cause layout issues since it will redraw while in landscape.
                // TODO: look for better solution
                DispatchQueue.main.async {
                    self.notificationsReceived.insert(.itemMetadataDidChange)
                }
            }
            .store(in: &cancellables)
    }

    func respond(to action: Action) -> State {
        switch action {
        case .backgroundRefresh:

            backgroundRefreshTask?.cancel()
            backgroundStates.insert(.refresh)

            backgroundRefreshTask = Task { [weak self] in
                do {
                    self?.nextUpViewModel.send(.refresh)
                    self?.recentlyAddedViewModel.send(.refresh)

                    let resumeItems = try await self?.getResumeItems() ?? []

                    guard !Task.isCancelled else { return }

                    await MainActor.run {
                        guard let self else { return }
                        self.resumeItems.elements = resumeItems
                        self.backgroundStates.remove(.refresh)
                    }
                } catch is CancellationError {
                    // cancelled
                } catch {
                    guard !Task.isCancelled else { return }

                    await MainActor.run {
                        guard let self else { return }
                        self.backgroundStates.remove(.refresh)
                        self.send(.error(.init(error.localizedDescription)))
                    }
                }
            }
            .asAnyCancellable()

            return state
        case let .error(error):
            return .error(error)
        case let .setIsPlayed(isPlayed, item): ()
            Task {
                try await setIsPlayed(isPlayed, for: item)

                self.send(.backgroundRefresh)
            }
            .store(in: &cancellables)

            return state
        case .refresh:
            backgroundRefreshTask?.cancel()
            refreshTask?.cancel()

            refreshTask = Task { [weak self] in
                do {
                    try await self?.refresh()

                    guard !Task.isCancelled else { return }

                    await MainActor.run {
                        guard let self else { return }
                        self.state = .content
                    }
                } catch is CancellationError {
                    // cancelled
                } catch {
                    guard !Task.isCancelled else { return }

                    await MainActor.run {
                        guard let self else { return }
                        self.send(.error(.init(error.localizedDescription)))
                    }
                }
            }
            .asAnyCancellable()

            return .refreshing
        }
    }

    private func refresh() async throws {

        await nextUpViewModel.send(.refresh)
        await recentlyAddedViewModel.send(.refresh)

        let resumeItems = try await getResumeItems()
        let librariesLatest = try await getLibrariesLatest()
        let librariesTrending = try await getLibrariesTrending()
        let librariesFeaturing = try await getLibrariesFeaturing()

        for library in librariesLatest {
            await library.send(.refresh)
        }
        for library in librariesTrending {
            await library.send(.refresh)
        }
        for library in librariesFeaturing {
            await library.send(.refresh)
        }
        await MainActor.run {
            self.resumeItems.elements = resumeItems
            self.librariesLatest = librariesLatest
            self.librariesTrending = librariesTrending
            self.librariesFeaturing = librariesFeaturing
        }
    }

    private func getResumeItems() async throws -> [BaseItemDto] {
        var parameters = Paths.GetResumeItemsParameters()
        parameters.enableUserData = true
        parameters.fields = .MinimumFields
        parameters.includeItemTypes = [.movie, .episode]
        parameters.limit = 20

        let request = Paths.getResumeItems(userID: userSession.user.id, parameters: parameters)
        let response = try await userSession.client.send(request)

        return response.value.items ?? []
    }

    private func getLibrariesLatest() async throws -> [LatestInLibraryViewModel] {

        let userViewsPath = Paths.getUserViews(userID: userSession.user.id)
        async let userViews = userSession.client.send(userViewsPath)

        async let excludedLibraryIDs = getExcludedLibraries()

        return try await (userViews.value.items ?? [])
            .intersection(["movies", "tvshows"], using: \.collectionType)
            .subtracting(excludedLibraryIDs, using: \.id)
            .map { LatestInLibraryViewModel(parent: $0) }
    }

    private func getLibrariesTrending() async throws -> [TrendingViewModel] {

        let userViewsPath = Paths.getUserViews(userID: userSession.user.id)
        async let userViews = userSession.client.send(userViewsPath)

        async let excludedLibraryIDs = getExcludedLibraries()

        return try await (userViews.value.items ?? [])
            .intersection(["movies", "tvshows"], using: \.collectionType)
            .subtracting(excludedLibraryIDs, using: \.id)
            .map { TrendingViewModel(parent: $0) }
    }

    private func getLibrariesFeaturing() async throws -> [FeaturingViewModel] {
        let userViewsPath = Paths.getUserViews(userID: userSession.user.id)
        async let userViews = userSession.client.send(userViewsPath)
        async let excludedLibraryIDs = getExcludedLibraries()

        let libraries = try await (userViews.value.items ?? [])
            .intersection(["movies", "tvshows"], using: \.collectionType)
            .subtracting(excludedLibraryIDs, using: \.id)

        var viewModels: [FeaturingViewModel] = []

        for library in libraries {
            let viewModel = FeaturingViewModel(parent: library)

            // Fetch first page of items
            let items = try await viewModel.get(page: 0)

            // Keep only items named "joker" or "sonsuz"
            let filteredItems = items.filter { item in
                guard let name = item.name?.lowercased() else { return false }
                return name == "joker" || name == "sonsuz"
            }

            // Overwrite the view model's items with the filtered ones

            viewModels.append(viewModel)
        }

        return viewModels
    }

    // TODO: use the more updated server/user data when implemented
    private func getExcludedLibraries() async throws -> [String] {
        let currentUserPath = Paths.getCurrentUser
        let response = try await userSession.client.send(currentUserPath)

        return response.value.configuration?.latestItemsExcludes ?? []
    }

    private func setIsPlayed(_ isPlayed: Bool, for item: BaseItemDto) async throws {
        let request: Request<UserItemDataDto>

        if isPlayed {
            request = Paths.markPlayedItem(
                userID: userSession.user.id,
                itemID: item.id!
            )
        } else {
            request = Paths.markUnplayedItem(
                userID: userSession.user.id,
                itemID: item.id!
            )
        }

        let _ = try await userSession.client.send(request)
    }
}
