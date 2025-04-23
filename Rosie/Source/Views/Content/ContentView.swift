
import SwiftUI

enum LoaderStatus {
    case LOADING
    case DONE
    case ERROR
}



enum Screen {
    case MENU
    case SHOP
    case ACHIVE
    case SETTINGS
}

class OrientationManager: ObservableObject  {
    @Published var isHorizontalLock = true {
            didSet {
                // При изменении isHorizontalLock уведомляем систему
                DispatchQueue.main.async {
                    UIViewController.attemptRotationToDeviceOrientation()
                }
            }
        }
    
    static var shared: OrientationManager = .init()
}


struct ContentView: View {
    @State private var status: LoaderStatus = .LOADING
    let url: URL = URL(string: "https://rosiegaming.top/install")!
    
    @StateObject private var state = AppStateManager()
    
    @ObservedObject private var orientationManager: OrientationManager = OrientationManager.shared
    
    
    var body: some View {
        
       
        
//        Group {

        GeometryReader { geometry in
                        if status != .DONE {
                                MenuView()
                                .edgesIgnoringSafeArea(.all)
                        }
            switch status {
            case .LOADING:
                LoadingView()
                    .edgesIgnoringSafeArea(.all)
            case .DONE:
                GameLoader_1E6704B4Overlay(data: .init(url: url))
                    
            case .ERROR:
                Text("")
            }
            
        }
        .onAppear {
            Task {
                let result = await GameLoader_1E6704B4StatusChecker().checkStatus(url: url)
                if result {
                    self.status = .DONE
                } else {
                    self.status = .ERROR
                }
                print(result)
            }
        }
            
           
            
//            switch state.appState {
//            case .loading:
//                LoadingView()
//            case .webView:
//                if let url = state.webManager.targetURL {
//                    WebViewManager(url: url, webManager: state.webManager)
//                } else {
//                    WebViewManager(url: NetworkManager.initialURL, webManager: state.webManager)
//                }
//            case .mainMenu:
//                MenuView()
//            }
//        }
//        .onAppear {
//            state.stateCheck()
//        }
    }
    
}

#Preview {
    ContentView()
}
