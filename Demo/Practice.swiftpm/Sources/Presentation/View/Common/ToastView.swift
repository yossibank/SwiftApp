import SwiftUI

struct ToastView: View {
    @Binding var isShowing: Bool

    var body: some View {
        ZStack {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
                    .foregroundColor(Color.green)
                VStack(alignment: .leading) {
                    Text("ダウンロード完了")
                        .font(.custom("RoundedMplus1c-Bold", size: 16))
                        .foregroundColor(Color.black)
                    Text("ファイルを写真アプリに保存しました")
                        .font(.custom("RoundedMplus1c-Regular", size: 14))
                        .foregroundColor(Color.black)
                }
            }
            .padding(12)
            .background(Color(red: 232/255, green: 242/255, blue: 228/255))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .background(.red)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    isShowing = false
                }
            }
        }
    }
}
