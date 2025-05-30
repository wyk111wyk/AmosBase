import SwiftUI

// 查看照片的Sheet
struct MutiImageViewer: View {
    enum ImagePageType {
        case swipe, collection
    }
    
    @Environment(\.dismiss) private var dismissPage
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var selectedIndex: Int
    @State private var pageType: ImagePageType = .swipe
    
    @State private var thumbnailWidth: CGFloat = 150
    @State private var hoveredIndex: Int?
    
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
        currentImageView()
            .buttonCirclePage(
                role: .cancel,
                labelColor: .white
            ) { dismissPage() }
    }
    
    @ViewBuilder
    private func currentImageView() -> some View {
        switch pageType {
        case .swipe: swipeImageView()
        case .collection: collectionImageView()
        }
    }
    
    @ViewBuilder
    private func collectionImageView() -> some View {
        let columns = [GridItem(.adaptive(minimum: thumbnailWidth), spacing: 10)]
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10){
                ForEach(allImages.indices, id: \.self) { index in
                    PlainButton {
                        SimpleHaptic.playLightHaptic()
                        withAnimation {
                            selectedIndex = index
                            pageType = .swipe
                        }
                    } label: {
                        Image(sfImage: allImages[index].image)
                            .resizable().scaledToFit()
                            .shadow(radius: 3)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if selectedIndex == index {
                            Image(systemName: "checkmark.circle.fill")
                                .imageModify(length: 24)
                                .foregroundStyle(.green)
                                .padding(5)
                        }
                    }
                    .onHover { _ in
                        hoveredIndex = index
                    }
                    #if os(macOS)
                    .opacity(hoveredIndex == index ? 1 : 0.85)
                    #endif
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            Slider(value: $thumbnailWidth, in: 60...sliderMax)
                .padding()
                .contentBackground(verticalPadding: 0, horizontalPadding: 0, cornerRadius: 60)
                .padding(.horizontal)
                #if os(macOS)
                .padding(.bottom)
                #endif
        }
    }
    
    private var sliderMax: CGFloat {
        if horizontalSizeClass == .regular { return 400 }
        else { return 220 }
    }
    
    private func swipeImageView() -> some View {
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
        .ignoresSafeArea(.all)
        .background(Color(r: 0.12, g: 0.12, b: 0.12), in: Rectangle())
        #if !os(macOS)
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        #endif
        .overlay(alignment: .topTrailing) {
            PlainButton {
                withAnimation {
                    pageType = .collection
                }
            } label: {
                HStack(spacing: 8) {
                    Text("\(selectedIndex + 1) / \(allImages.count)")
                        .contentTransition(.numericText())
                        .monospacedDigit()
                        .simpleTag(.border(verticalPad: 2, horizontalPad: 8, cornerRadius: 12, contentFont: .footnote, contentColor: .white, borderColor: .white))
                    Image(systemName: "rectangle.grid.2x2.fill")
                        .foregroundStyle(.white)
                }
            }
            .padding(.top)
            .padding(.top, 8)
            .padding(.trailing)
        }
    }
}

extension MutiImageViewer {
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
