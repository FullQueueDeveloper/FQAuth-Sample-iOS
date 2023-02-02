import SwiftUI

struct RandomStringView: View {

  @ObservedObject
  var controller: RandomStringController

  @Binding var currentRoute: NavigationPath

  var body: some View {

    VStack {

      Group {
        switch controller.latestEvent.state {
        case .notLoaded:
          Spacer()
          Text("not loaded")
            .foregroundColor(.gray)
          Spacer()
          HStack {
            RefreshButton(controller: controller)
            RegenerateButton(controller: controller)
          }

        case .loading:
          Text("loading").foregroundColor(.gray)
          ProgressView()
        case .loaded(let current):
          Spacer()
          Text(current)
          Spacer()
          HStack {
            RefreshButton(controller: controller)
            RegenerateButton(controller: controller)
          }
        case .error(let error):
          Spacer()
          Text(error.localizedDescription)
            .foregroundColor(.red)
          Spacer()
          RefreshButton(controller: controller)
        }
      }
      .task {
#if DEBUG
        guard !isPreview() else { return }
#endif

        await controller.refresh()
      }
    }
    .navigationTitle("Random String app")
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button("Profile") {
          currentRoute.append(AppRoute.profile)
        }
      }
    }
  }

  struct RefreshButton: View {
    @ObservedObject var controller: RandomStringController
    var body: some View {
      Button("refresh") {
        Task {
          await controller.refresh()
        }
      }
      .buttonStyle(.borderedProminent)
    }
  }

  struct RegenerateButton: View {
    @ObservedObject var controller: RandomStringController
    var body: some View {
      Button("Regenerate") {
        Task {
          await controller.regenerate()
        }
      }
      .buttonStyle(.bordered)
    }
  }
}


#if DEBUG
struct RandomStringView_Previews: PreviewProvider {

  static var networking: FQNetworking = .init(
    urlSession: FakeURLSession(),
    currentAuthController: CurrentAuthorizationController(jwtVerifier: FakeJWTVerifier()))

  static var previews: some View {
    Group {
      NavigationStack {

        RandomStringView(controller: RandomStringController(state: .notLoaded, networking: networking), currentRoute: .constant(NavigationPath([AppRoute.randomString])))
      }

      NavigationStack {
        RandomStringView(controller: RandomStringController(state: .loading, networking: networking), currentRoute: .constant(NavigationPath([AppRoute.randomString])))
      }

      NavigationStack {
        RandomStringView(controller: RandomStringController(state: .error(RandomStringController.Errors.responseDataNotConvertibleToString), networking: networking), currentRoute: .constant(NavigationPath([AppRoute.randomString])))
      }

      NavigationStack {
        RandomStringView(controller: RandomStringController(state: .loaded("yes it loads"), networking: networking), currentRoute: .constant(NavigationPath([AppRoute.randomString])))
      }
    }
  }
}
#endif
