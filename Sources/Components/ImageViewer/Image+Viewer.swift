import SwiftUI

// 查看照片的Sheet
public struct MutiImageViewer: View {
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

    public var body: some View {
        TabView(selection: $selectedIndex.animation()) {
            if allImages.count > 0 {
                ForEach(allImages.indices, id: \.self) { index in
                    ImageDetailView(
                        image: allImages[index].image,
                        caption: allImages[index].caption
                    ).tag(index)
                }
            }
        }
        .background(Color(r: 0.12, g: 0.12, b: 0.12), in: Rectangle())
        #if os(iOS)
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        #elseif os(macOS)
        .tabViewStyle(.automatic)
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
}

#Preview {
    MutiImageViewer(
        allImages: ImageStoreModel.examples(),
        selectedIndex: 0
    )
}
