//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2025 Jellyfin & Jellyfin Contributors
//

import SwiftUI

struct ProfileView: View {
    // Hardcoded color values
    private let backgroundColor = Color(red: 0.35, green: 0.2, blue: 0.1)
    private let orangeColor = Color(red: 0.9, green: 0.5, blue: 0.3)
    private let darkOverlayColor = Color.black.opacity(0.4)

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [orangeColor, backgroundColor]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top navigation bar
                HStack {
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                    }

                    Spacer()

                    Text("Home")
                        .font(.headline)

                    Spacer()

                    HStack(spacing: 16) {
                        Button(action: {}) {
                            Image(systemName: "airplayvideo")
                                .font(.title2)
                        }

                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                        }

                        Button(action: {}) {
                            Image(systemName: "ellipsis")
                                .font(.title2)
                        }
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 12)

                Spacer()

                // User profile content
                VStack(spacing: 20) {
                    // Large profile letter
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 110, height: 110)

                        Text("J")
                            .font(.system(size: 80, weight: .light))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 10)

                    // Username
                    Text("jakida")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // Membership info
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "play.rectangle.fill")
                            Text("Plex Pass")
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(darkOverlayColor)
                        .cornerRadius(4)

                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                            Text("Joined 2013")
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(darkOverlayColor)
                        .cornerRadius(4)
                    }
                    .font(.caption)
                    .foregroundColor(.white)

                    // Action buttons
                    HStack(spacing: 16) {
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Profile")
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(darkOverlayColor)
                            .cornerRadius(20)
                        }

                        Button(action: {}) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("Requests (0)")
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(darkOverlayColor)
                            .cornerRadius(20)
                        }

                        Button(action: {}) {
                            Image(systemName: "square.and.arrow.up")
                                .padding(8)
                                .background(darkOverlayColor)
                                .cornerRadius(20)
                        }
                    }
                    .foregroundColor(.white)
                    .font(.subheadline)

                    // Watch history section
                    VStack(spacing: 0) {
                        // Watch history header
                        Button(action: {}) {
                            HStack {
                                Text("My Watch History")
                                    .fontWeight(.medium)

                                Spacer()

                                HStack(spacing: 8) {
                                    Image(systemName: "person.2")
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .foregroundColor(.white)
                        }

                        // Watch statistics
                        HStack(spacing: 0) {
                            Spacer()

                            VStack {
                                Text("34")
                                    .font(.system(size: 42, weight: .bold))
                                Text("Movies")
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            VStack {
                                Text("9")
                                    .font(.system(size: 42, weight: .bold))
                                Text("Shows")
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            VStack {
                                Text("44")
                                    .font(.system(size: 42, weight: .bold))
                                Text("Episodes")
                                    .foregroundColor(.gray)
                            }

                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .background(darkOverlayColor)

                        // Watch stats footer
                        Text("Watched since joining Plex")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(darkOverlayColor)
                    }
                    .background(darkOverlayColor)
                    .cornerRadius(8)

                    // Sync personal media section
                    Button(action: {}) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sync Personal Media state as well?")
                                .fontWeight(.medium)
                                .foregroundColor(.white)

                            Text("Now you can sync your watch state and ratings with the Plex Platform")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(darkOverlayColor)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        // Hide the default navigation bar
        .navigationBarHidden(true)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
