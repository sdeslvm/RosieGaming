import SwiftUI

struct LoseModalView: View {
    let onTryAgain: () -> Void
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 30) {
                Text("LOSE")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("You lost! Time is up.")
                    .font(.title2)
                    .foregroundColor(.white)
                Button(action: onTryAgain) {
                    Text("Try Again")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 30)
            }
            .padding()
            .frame(width: 300, height: 250)
            .background(Color.gray.opacity(0.95))
            .cornerRadius(20)
            .shadow(radius: 12)
        }
    }
}

#Preview {
    LoseModalView(onTryAgain: {})
}
