import SwiftUI
import Kingfisher

extension KFImage {
    static let kfProcessingQueue = DispatchQueue(label: "kingfisherProcessingQueue")
}

struct KFImageView: View {
    let urlString: String?
    
    @State private var loadImage: Bool
    
    init(urlString: String?) {
        self.urlString = urlString
        loadImage = true
    }
    
    @ViewBuilder
    var body: some View {
        if loadImage, let urlString = urlString, let url = URL(string: urlString) {
            KFImage(url)
                .resizable()
                .processingQueue(.dispatch(KFImage.kfProcessingQueue))
                .cacheMemoryOnly()
                .processingQueue(.dispatch(.main))
                .placeholder {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                .onFailure { error in
                    loadImage = false
                }
        } else {
            Image(systemName: "pencil")
                .resizable()
        }
    }
}
