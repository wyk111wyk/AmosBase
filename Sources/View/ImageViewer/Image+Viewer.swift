import SwiftUI

#if os(iOS)
// 查看照片的Sheet
public struct MutiImageViewer: View {
    @Environment(\.dismiss) private var dismissPage
    @State private var selectedIndex: Int
    let allImages: [SimpleImageStore]
    
    init(allImages: [SimpleImageStore] = [],
         selectedIndex: Int = 0,
         needToSave: Bool = false,
         onSave: @escaping ((Int) -> Void) = {_ in}) {
        self.allImages = allImages
        self._selectedIndex = State.init(initialValue: selectedIndex)
    }

    public var body: some View {
        TabView(selection: $selectedIndex) {
            if allImages.count > 0 {
                ForEach(allImages.indices, id: \.self) { index in
                    ImageDetailView(image: allImages[index].image,
                                    caption: allImages[index].caption)
                        .tag(index)
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .ignoresSafeArea(.all)
        .buttonCirclePage(role: .cancel, labelColor: .white) { dismissPage() }
    }
}

struct MutiImageViewer_Previews: PreviewProvider {
    static var previews: some View {
        MutiImageViewer(allImages: ImageStoreModel.examples(),
                        selectedIndex: 0)
    }
}
#endif
