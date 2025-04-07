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

struct ConnectButton: View {
    @State
    private var isShowingConnectionMenu = false
    @State
    private var nearbyDevices: [String] = []
    @State
    private var isScanning = false
    @State
    private var connectedDevice: String?

    // MultipeerConnectivity properties
    private let serviceType = "apple-connect"
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!

    init() {
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
    }

    var body: some View {
        Button(action: {
            isShowingConnectionMenu = true
        }) {
            Image(systemName: "dot.radiowaves.left.and.right")
                .imageScale(.medium)
                .foregroundColor(.gray)
        }
        .sheet(isPresented: $isShowingConnectionMenu) {
            connectionMenuView
        }
    }

    var connectionMenuView: some View {
        NavigationView {
            List {
                Section(header: Text("Screen Mirroring")) {
                    AirPlayButton()

                    Button(action: {
                        startScreenMirroring()
                    }) {
                        HStack {
                            Image(systemName: "display.2")
                            Text("Screen Mirror to Mac")
                        }
                    }
                }

                Section(header: Text("Bluetooth Devices")) {
                    if isScanning {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Scanning...")
                        }
                    }

                    Button(action: {
                        scanForBluetoothDevices()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Scan for Devices")
                        }
                    }

                    ForEach(nearbyDevices, id: \.self) { device in
                        Button(action: {
                            connectToDevice(device)
                        }) {
                            HStack {
                                Image(systemName: "bluetooth")
                                Text(device)
                                Spacer()
                                if connectedDevice == device {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Nearby Devices")) {
                    Button(action: {
                        startMultipeerDiscovery()
                    }) {
                        HStack {
                            Image(systemName: "wifi")
                            Text("Find Nearby Apple Devices")
                        }
                    }
                }
            }
            .navigationTitle("Connect")
            .navigationBarItems(trailing: Button("Done") {
                isShowingConnectionMenu = false
            })
        }
    }

    // MARK: - Functionality Methods

    func startScreenMirroring() {
        // In a real app, you would integrate with Apple's Screen Sharing API
        // or use AirPlay functionality to locate and connect to Macs
        print("Starting screen mirroring to Mac")

        // Simple simulation of successful connection
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            connectedDevice = "MacBook Pro"
            isShowingConnectionMenu = false
        }
    }

    func scanForBluetoothDevices() {
        isScanning = true

        // In a real app, you would integrate with CoreBluetooth to scan for devices
        // This is a simulation with sample devices
        nearbyDevices = []

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            nearbyDevices = ["AirPods Pro", "Magic Mouse", "Bluetooth Speaker", "MacBook Air"]
            isScanning = false
        }
    }

    func connectToDevice(_ device: String) {
        // In a real app, you would use CoreBluetooth to establish connection
        print("Connecting to \(device)")

        // Simulate connection process
        isScanning = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            connectedDevice = device
            isScanning = false
            isShowingConnectionMenu = false
        }
    }

    func startMultipeerDiscovery() {
        // Start advertising this device
        advertiser.startAdvertisingPeer()

        // Start browsing for other devices
        browser.startBrowsingForPeers()

        // In a real implementation, you would need to set up the delegate methods
        // and handle the connection process

        // For demo purposes, simulate finding devices
        isScanning = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            nearbyDevices += ["iPhone 15", "iPad Pro", "MacBook Pro (M3)"]
            isScanning = false
        }
    }
}

// MARK: - AirPlay Button

struct AirPlayButton: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let routePickerView = AVRoutePickerView()
        routePickerView.tintColor = .systemBlue
        routePickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(routePickerView)

        NSLayoutConstraint.activate([
            routePickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            routePickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            routePickerView.topAnchor.constraint(equalTo: view.topAnchor),
            routePickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
