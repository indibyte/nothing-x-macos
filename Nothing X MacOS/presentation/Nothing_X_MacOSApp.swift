//
//  Nothing_X_MacOSApp.swift
//  Nothing X MacOS
//
//  Created by Arunavo Ray on 07/01/23.
//

import SwiftUI


@main
struct Nothing_X_MacOSApp: App {
    @StateObject private var store = Store()
    @StateObject private var viewModel = MainViewViewModel(bluetoothService: BluetoothServiceImpl(), nothingRepository: NothingRepositoryImpl.shared, nothingService: NothingServiceImpl.shared)
    @StateObject private var budsPickerViewModel = BudsPickerComponentViewModel()

    private static let uiScale: CGFloat = 1.5

    private var batteryText: String {
        guard let left = viewModel.leftBattery, let right = viewModel.rightBattery else {
            return ""
        }
        let l = Int(left)
        let r = Int(right)
        switch store.batteryDisplayMode {
        case .both:
            return l == r ? "\(l)%" : "\(l)·\(r)%"
        case .average:
            return "\((l + r) / 2)%"
        case .minimum:
            return "\(min(l, r))%"
        }
    }

    var body: some Scene {
        MenuBarExtra {
            NavigationStack(path: $viewModel.navigationPath.animation(.default)) {
                
                HomeView()
                    .navigationDestination(for: Destination.self) { destination in
                        switch(destination) {
                        case .home: HomeView()
                                .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                        case .equalizer: EqualizerView(eqMode: $viewModel.eqProfiles)
                        case .controls: ControlsView()
                        case .controlsTripleTap: controlsDetailView(.controlsTripleTap)
                        case .controlsTapHold: controlsDetailView(.controlsTapHold)
                        case .controlsDoubleTap: controlsDetailView(.controlsDoubleTap)
                        case .controlsDoubleTapHold: controlsDetailView(.controlsDoubleTapHold)
                        case .settings: SettingsView()
                        case .findMyBuds: FindMyBudsView()
                        case .discover: DiscoverView()
                                .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                        case .connect: ConnectView()
                            //                                .animation(nil)
                                .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                        case .discover_started: DiscoverStartedView()
                        case .bluetooth_off: BluetoothIsOffView()
                        case .earTipTest: EarTipTestView()
                        case .caseLED: CaseLEDView()

                        }
                        
                        
                    }
                    
            }
            .environmentObject(store)
            .environmentObject(viewModel)
            .environmentObject(budsPickerViewModel)
            .frame(width: 250, height: 230)
            // Views are laid out for a fixed 250x230 popover, so scale the whole UI up uniformly
            .scaleEffect(Self.uiScale, anchor: .topLeading)
            .frame(width: 250 * Self.uiScale, height: 230 * Self.uiScale, alignment: .topLeading)
            .background(Color.black)
        
            
        } label: {
            
            // The custom symbol only exists when the asset catalog is compiled (Xcode builds)
            Group {
                if NSImage(named: "nothing.ear.1") != nil {
                    Label(batteryText, image: "nothing.ear.1")
                } else {
                    Label(batteryText, systemImage: "earbuds")
                }
            }
            .labelStyle(.titleAndIcon)

        }
        .menuBarExtraStyle(.window)

    }

    @ViewBuilder
    private func controlsDetailView(_ destination: Destination) -> some View {
        ControlsDetailView(
            destination: destination,
            leftTripleTapAction: $viewModel.leftTripleTapAction,
            rightTripleTapAction: $viewModel.rightTripleTapAction,
            leftTapAndHoldAction: $viewModel.leftTapAndHoldAction,
            rightTapAndHoldAction: $viewModel.rightTapAndHoldAction,
            leftDoubleTapAction: $viewModel.leftDoubleTapAction,
            rightDoubleTapAction: $viewModel.rightDoubleTapAction,
            leftDoubleTapAndHoldAction: $viewModel.leftDoubleTapAndHoldAction,
            rightDoubleTapAndHoldAction: $viewModel.rightDoubleTapAndHoldAction
        )
    }
}
