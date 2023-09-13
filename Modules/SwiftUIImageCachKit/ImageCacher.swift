//
//  ImageCacher.swift
//  SwiftUIImageCachKit
//
//  Created by 김윤석 on 2023/09/04.
//

import SwiftUI

public struct CacheImage<Content: View>: View{
    private let urlString: String
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content
    
    public init(
        urlString: String,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ){
        self.urlString = urlString
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }
    
    public var body: some View{
        //이미 캐시에 있다면 여기에서 이미지를 보여준다.
        if let cached = ImageCacher[urlString] {
            content(.success(cached))
        }else{
        // 캐시에 이미지가 없다면 AsyncImage로 받아온다.
            if let url = URL(string: urlString) {
                AsyncImage(
                    url: url,
                    scale: scale,
                    transaction: transaction
                ){ phase in
                    cacheAndRender(phase: phase)
                }
            }
        }
    }
    
    private func cacheAndRender(phase: AsyncImagePhase) -> some View{
        if case .success (let image) = phase {
            //캐시에 저장해주고,
            ImageCacher[urlString] = image
        }
        //content에 되돌려준다.
        return content(phase)
    }
}

fileprivate final class ImageCacher {
    static private var cache: [String: Image] = [:]
    static subscript(url: String) -> Image?{
        get {
            ImageCacher.cache[url]
        }
        set {
            ImageCacher.cache[url] = newValue
        }
    }
}
