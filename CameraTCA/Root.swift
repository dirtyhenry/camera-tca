import ComposableArchitecture
import Foundation
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct RootFeature: ReducerProtocol {
    struct State {
        var latestPhotoData: Data?
        var count: Int
    }

    enum Action {
        case incrementButtonTapped
        case loadDummyButtonTapped
    }

    var body: some ReducerProtocolOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .incrementButtonTapped:
                state.count += 1
                return .none

            case .loadDummyButtonTapped:
                guard let image = UIImage(named: "DummyImage"),
                      let imageData = image.jpegData(compressionQuality: 1)
                else {
                    fatalError("No image found.")
                }
                state.latestPhotoData = imageData
                print("Set data")
                return .none
            }
        }
    }
}

extension RootFeature.State: Equatable {}
extension RootFeature.Action: Equatable {}

struct RootView: View {
    let store: StoreOf<RootFeature>

    var body: some View {
        NavigationStack {
            WithViewStore(store, observe: { $0 }) { viewStore in
                if viewStore.latestPhotoData == nil {
                    VStack(spacing: 32) {
                        Button("Increment \(viewStore.count)") {
                            viewStore.send(.incrementButtonTapped)
                        }
                        Button("Load Dummy Photo") {
                            viewStore.send(.loadDummyButtonTapped)
                        }
                        Text("\(viewStore.latestPhotoData == nil ? "Nil" : "Data")")
                    }
                } else {
                    Text("PHOTO")
                }
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(store: Store(
            initialState: RootFeature.State(count: 1),
            reducer: RootFeature()
        ))
    }
}
