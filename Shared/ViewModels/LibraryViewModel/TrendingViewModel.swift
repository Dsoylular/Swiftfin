//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2025 Jellyfin & Jellyfin Contributors
//

import Foundation
import JellyfinAPI

final class TrendingViewModel: PagingLibraryViewModel<BaseItemDto>, Identifiable {

    override func get(page: Int) async throws -> [BaseItemDto] {

        let parameters = parameters()
        let request = Paths.getLatestMedia(userID: userSession.user.id, parameters: parameters)
        let response = try await userSession.client.send(request)

        return response.value
    }

    private func parameters() -> Paths.GetLatestMediaParameters { // TODO: !!!!!!!!!!

        var parameters = Paths.GetLatestMediaParameters() // TODO!!!!!!!!!!
        parameters.parentID = parent?.id
        parameters.fields = .MinimumFields
        parameters.enableUserData = true
        parameters.limit = pageSize

        return parameters
    }
}
