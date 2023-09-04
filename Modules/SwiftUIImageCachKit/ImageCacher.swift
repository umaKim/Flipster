//
//  ImageCacher.swift
//  SwiftUIImageCachKit
//
//  Created by 김윤석 on 2023/09/04.
//

import SwiftUI

public struct CacheImage<Content: View>: View{
    private let url: URL
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content
    
    public init(
        urlString: String,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ){
        self.url = URL(string: urlString) ?? URL(string: "")!
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }
    
    public var body: some View{
        //이미 캐시에 있다면 여기에서 이미지를 보여준다.
        if let cached = ImageCacher[url] {
            let _ = print("cached: \(url.absoluteString)")
            content(.success(cached))
        }else{
        // 캐시에 이미지가 없다면 AsyncImage로 받아온다.
            let _ = print("request: \(url.absoluteString)")
            AsyncImage(
                url: url,
                scale: scale,
                transaction: transaction
            ){ phase in
                cacheAndRender(phase: phase)
            }
        }
    }
    
    private func cacheAndRender(phase: AsyncImagePhase) -> some View{
        if case .success (let image) = phase {
            //캐시에 저장해주고,
            ImageCacher[url] = image
        }
        //content에 되돌려준다.
        return content(phase)
    }
}

fileprivate actor ImageCacher{
    static private var cache: [URL: Image] = [:]
    static subscript(url: URL) -> Image?{
        get{
            ImageCacher.cache[url]
        }
        set{
            ImageCacher.cache[url] = newValue
        }
    }
}
