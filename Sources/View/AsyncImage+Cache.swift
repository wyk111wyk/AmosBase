//
//  Created by Lorenzo Fiamingo on 04/11/20.
//

import SwiftUI

public struct CachedAsyncImage<Content>: View where Content: View {
    
    @State private var phase: AsyncImagePhase
    
    private let urlRequest: URLRequest?
    
    private let urlSession: URLSession
    
    private let scale: CGFloat
    
    private let transaction: Transaction
    
    private let content: (AsyncImagePhase) -> Content
    
    private let successLoaded: (SFImage) -> Void
    
    private let cacheHelper: SimpleCache?
    
    public var body: some View {
        content(phase)
            .task(id: urlRequest) { await load() }
    }
    
    public init(
        url: URL?,
        urlCache: URLCache = .shared,
        scale: CGFloat = 1,
        successLoaded: @escaping (SFImage) -> Void = {_ in}
    ) where Content == Image {
        let urlRequest = url == nil ? nil : URLRequest(url: url!)
        self.init(urlRequest: urlRequest, urlCache: urlCache, scale: scale, successLoaded: successLoaded)
    }
    
    public init(
        urlRequest: URLRequest?,
        urlCache: URLCache = .shared,
        scale: CGFloat = 1,
        successLoaded: @escaping (SFImage) -> Void = {_ in}
    ) where Content == Image {
        self.init(urlRequest: urlRequest, urlCache: urlCache, scale: scale, content: { phase in
            phase.image ?? Image(sfImage: .init())
        }, successLoaded: successLoaded)
    }
    
    public init<I, P>(
        url: URL?,
        urlCache: URLCache = .shared,
        scale: CGFloat = 1,
        @ViewBuilder content: @escaping (Image) -> I,
        @ViewBuilder placeholder: @escaping () -> P,
        successLoaded: @escaping (SFImage) -> Void = {_ in}
    ) where Content == _ConditionalContent<I, P>, I : View, P : View {
        let urlRequest = url == nil ? nil : URLRequest(url: url!)
        self.init(
            urlRequest: urlRequest,
            urlCache: urlCache,
            scale: scale,
            content: content,
            placeholder: placeholder,
            successLoaded: successLoaded
        )
    }
    
    public init<I, P>(
        urlRequest: URLRequest?,
        urlCache: URLCache = .shared,
        scale: CGFloat = 1,
        @ViewBuilder content: @escaping (Image) -> I,
        @ViewBuilder placeholder: @escaping () -> P,
        successLoaded: @escaping (SFImage) -> Void = {_ in}
    ) where Content == _ConditionalContent<I, P>, I : View, P : View {
        self.init(
            urlRequest: urlRequest,
            urlCache: urlCache,
            scale: scale,
            content: { phase in
                if let image = phase.image {
                    content(image)
                } else {
                    placeholder()
                }
            },
            successLoaded: successLoaded
        )
    }
    
    public init(
        url: URL?,
        urlCache: URLCache = .shared,
        scale: CGFloat = 1,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content,
        successLoaded: @escaping (SFImage) -> Void = {_ in}
    ) {
        let urlRequest = url == nil ? nil : URLRequest(url: url!)
        self.init(
            urlRequest: urlRequest,
            urlCache: urlCache,
            scale: scale,
            transaction: transaction,
            content: content,
            successLoaded: successLoaded
        )
    }
    
    /// Loads and displays a modifiable image from the specified URL in phases.
    ///
    /// If you set the asynchronous image's URL to `nil`, or after you set the
    /// URL to a value but before the load operation completes, the phase is
    /// ``AsyncImagePhase/empty``. After the operation completes, the phase
    /// becomes either ``AsyncImagePhase/failure(_:)`` or
    /// ``AsyncImagePhase/success(_:)``. In the first case, the phase's
    /// ``AsyncImagePhase/error`` value indicates the reason for failure.
    /// In the second case, the phase's ``AsyncImagePhase/image`` property
    /// contains the loaded image. Use the phase to drive the output of the
    /// `content` closure, which defines the view's appearance:
    ///
    ///     CachedAsyncImage(url: URL(string: "https://example.com/icon.png")) { phase in
    ///         if let image = phase.image {
    ///             image // Displays the loaded image.
    ///         } else if phase.error != nil {
    ///             Color.red // Indicates an error.
    ///         } else {
    ///             Color.blue // Acts as a placeholder.
    ///         }
    ///     }
    ///
    /// To add transitions when you change the URL, apply an identifier to the
    /// ``CachedAsyncImage``.
    ///
    /// - Parameters:
    ///   - urlRequest: The URL request of the image to display.
    ///   - urlCache: The URL cache for providing cached responses to requests within the session.
    ///   - scale: The scale to use for the image. The default is `1`. Set a
    ///     different value when loading images designed for higher resolution
    ///     displays. For example, set a value of `2` for an image that you
    ///     would name with the `@2x` suffix if stored in a file on disk.
    ///   - transaction: The transaction to use when the phase changes.
    ///   - content: A closure that takes the load phase as an input, and
    ///     returns the view to display for the specified phase.
    public init(
        urlRequest: URLRequest?,
        urlCache: URLCache = .shared,
        scale: CGFloat = 1,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content,
        successLoaded: @escaping (SFImage) -> Void = {_ in}
    ) {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = urlCache
        self.urlRequest = urlRequest
        self.urlSession =  URLSession(configuration: configuration)
        self.scale = scale
        self.transaction = transaction
        self.content = content
        self.cacheHelper = try? SimpleCache(isDebuging: false)
        self._phase = State(wrappedValue: .empty)
        self.successLoaded = successLoaded
        do {
            if let urlRequest = urlRequest, 
               let image = try cachedImage(from: urlRequest, cache: urlCache) {
                self._phase = State(wrappedValue: .success(image))
            }
        } catch {
            self._phase = State(wrappedValue: .failure(error))
        }
    }
    
    private func load() async {
        do {
            if let urlRequest = urlRequest {
                let (image, metrics) = try await remoteImage(from: urlRequest, session: urlSession)
                if metrics.transactionMetrics.last?.resourceFetchType == .localCache {
                    phase = .success(image)
                } else {
                    withAnimation(transaction.animation) {
                        phase = .success(image)
                    }
                }
            } else {
                withAnimation(transaction.animation) {
                    phase = .empty
                }
            }
        } catch {
            withAnimation(transaction.animation) {
                phase = .failure(error)
            }
        }
    }
}

// MARK: - LoadingError

private extension AsyncImage {
    struct LoadingError: Error {}
}

// MARK: - Helpers
private extension CachedAsyncImage {
    private func remoteImage(
        from request: URLRequest,
        session: URLSession
    ) async throws -> (Image, URLSessionTaskMetrics) {
        let (data, _, metrics) = try await session.data(for: request)
        if metrics.redirectCount > 0 {
            if let idKey = request.url?.absoluteString {
                try cacheHelper?.save(object: data, forKey: idKey)
            }
        }
        return (try image(from: data), metrics)
    }
    
    private func cachedImage(
        from request: URLRequest,
        cache: URLCache
    ) throws -> Image? {
        if let idKey = request.url?.absoluteString,
           let cacheImage = try? cacheHelper?.loadImage(forKey: idKey) {
            self.successLoaded(cacheImage)
            return Image(sfImage: cacheImage)
        }
        
        guard let cachedResponse = cache.cachedResponse(for: request) else { return nil }
        return try image(from: cachedResponse.data)
    }
    
    // 将 Data 转换为 Image
    private func image(from data: Data) throws -> Image {
        if let sfImage = SFImage(data: data) {
            self.successLoaded(sfImage)
            return Image(sfImage: sfImage)
        } else {
            throw AsyncImage<Content>.LoadingError()
        }
    }
}

// MARK: - AsyncImageURLSession

private class URLSessionTaskController: NSObject, URLSessionTaskDelegate {
    
    var metrics: URLSessionTaskMetrics?
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didFinishCollecting metrics: URLSessionTaskMetrics
    ) {
        self.metrics = metrics
    }
}

private extension URLSession {
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse, URLSessionTaskMetrics) {
        let controller = URLSessionTaskController()
        let (data, response) = try await data(for: request, delegate: controller)
        return (data, response, controller.metrics!)
    }
}
