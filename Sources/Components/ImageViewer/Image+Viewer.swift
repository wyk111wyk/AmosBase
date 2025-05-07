import SwiftUI

// 查看照片的Sheet
struct MutiImageViewer: View {
    @Environment(\.dismiss) private var dismissPage
    @State private var selectedIndex: Int
    let allImages: [any SimpleImageStore]
    
    init(
        allImages: [any SimpleImageStore] = [],
        selectedIndex: Int = 0,
        needToSave: Bool = false,
        onSave: @escaping ((Int) -> Void) = {_ in}
    ) {
        self.allImages = allImages
        self._selectedIndex = State.init(initialValue: selectedIndex)
    }

    var body: some View {
        TabView(selection: $selectedIndex.animation()) {
            if allImages.count > 0 {
                ForEach(allImages.indices, id: \.self) { index in
                    ImageDetailView(
                        image: allImages[index].image,
                        caption: allImages[index].caption
                    )
                    .tag(index)
                    .overlay(alignment: .leading) {
                        lastButton()
                    }
                    .overlay(alignment: .trailing) {
                        nextButton()
                    }
                }
            }
        }
        .background(Color(r: 0.12, g: 0.12, b: 0.12), in: Rectangle())
        #if os(iOS) || os(watchOS) || os(tvOS)
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        #endif
        .ignoresSafeArea(.all)
        .buttonCirclePage(
            role: .cancel,
            labelColor: .white
        ) { dismissPage() }
        .overlay(alignment: .topTrailing) {
            Text("\(selectedIndex + 1) / \(allImages.count)")
                .contentTransition(.numericText())
                .foregroundStyle(.white)
                .font(.footnote)
                .padding(.top)
                .padding(.trailing)
        }
    }
    
    @ViewBuilder
    private func lastButton() -> some View {
        #if os(macOS)
        if selectedIndex > 0 {
            PlainButton {
                selectedIndex -= 1
            } label: {
                Image(systemName: "arrowshape.left.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(8)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(.regularMaterial)
                    }
            }
            .padding(.leading)
        }
        #endif
    }
    
    @ViewBuilder
    private func nextButton() -> some View {
        #if os(macOS)
        if selectedIndex < allImages.count - 1 {
            PlainButton {
                selectedIndex += 1
            } label: {
                Image(systemName: "arrowshape.right.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(8)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(.regularMaterial)
                    }
            }
            .padding(.trailing)
        }
        #endif
    }
}

#Preview {
    MutiImageViewer(
        allImages: ImageStoreModel.examples(),
        selectedIndex: 0
    )
}
