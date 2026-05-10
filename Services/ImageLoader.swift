//
//  ImageLoader.swift
//  InternGallery
//
//  Created by Ilya on 10.05.2026.
//

import UIKit

final class ImageLoader {
    private static let cache = NSCache<NSString, UIImage>()
    
    static func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask? {
        let cacheKey = NSString(string: urlString)
        
        if let image = cache.object(forKey: cacheKey) {
            completion(image)
            return nil
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return nil
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil, let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            cache.setObject(image, forKey: cacheKey)
            DispatchQueue.main.async {
                completion(image)
            }
        }
        
        task.resume()
        return task
    }
}
