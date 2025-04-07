//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2025 Jellyfin & Jellyfin Contributors
//

import AVKit
import MultipeerConnectivity
import SwiftUI

import SwiftUI

struct SearchButton: View {
    let rastroGreen = Color(red: 223 / 255, green: 255 / 255, blue: 96 / 255)

    @Binding
    var isSearchActive: Bool

    var body: some View {
        Button {
            isSearchActive.toggle()
        } label: {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .overlay {
                    Color.clear
                }
        }
        .accessibilityLabel(L10n.search) // Same as in SettingsBarButton for consistency
    }
}
