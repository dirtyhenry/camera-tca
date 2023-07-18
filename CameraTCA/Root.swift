import ComposableArchitecture
import Foundation
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct RootFeature: ReducerProtocol {
    struct State {
        @PresentationState var takePhoto: ImagePickerFeature.State?
        var latestPhoto: UIImage?
        var count: Int
    }

    enum Action {
        case takePhotoButtonTapped
        case usePhoto(PresentationAction<ImagePickerFeature.Action>)
        case incrementButtonTapped
    }

    var body: some ReducerProtocolOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .incrementButtonTapped:
                state.count += 1
                return .none

            case .takePhotoButtonTapped:
                print("takePhotoButtonTapped \(state.count)")
                state.takePhoto = ImagePickerFeature.State()
                state.count += 1
                return .none

            case let .usePhoto(.presented(.delegate(.usePhoto(newPhoto)))):
                print("usePhoto \(state.count)")
                state.latestPhoto = newPhoto
                state.takePhoto = nil
                state.count += 1
                return .none

            case .usePhoto(.presented(.delegate(.cancel))):
                state.takePhoto = nil
                return .none

            case .usePhoto:
                return .none
            }
        }
        .ifLet(\.$takePhoto, action: /Action.usePhoto) {
            ImagePickerFeature()
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
                if viewStore.latestPhoto == nil {
                    Button("Take Photo \(viewStore.count)") {
                        viewStore.send(.takePhotoButtonTapped)
                    }
                    Button("Increment \(viewStore.count)") {
                        viewStore.send(.incrementButtonTapped)
                    }
                } else {
                    VStack {
                        Image(uiImage: viewStore.latestPhoto!)
                        Button("Retake Photo") {
                            viewStore.send(.takePhotoButtonTapped)
                        }
                    }
                }
            }
        }
        .sheet(
            store: store.scope(
                state: \.$takePhoto,
                action: { .usePhoto($0) }
            )) { takePhotoStore in
                NavigationStack {
                    ImagePickerView(
                        store: takePhotoStore,
                        sourceType: .camera,
                        mediaTypes: [UTType.image.identifier]
                    )
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
