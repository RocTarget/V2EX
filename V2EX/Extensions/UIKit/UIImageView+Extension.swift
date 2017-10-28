import Kingfisher
import RxCocoa
import RxSwift
import UIView_Positioning

enum ImageResult {
    case success(UIImage)
    case failure(Error)
    
    var image: UIImage? {
        if case .success(let image) = self {
            return image
        } else {
            return nil
        }
    }
    
    var error: Error? {
        if case .failure(let error) = self {
            return error
        } else {
            return nil
        }
    }
}

extension UIImageView {
    @discardableResult
    func setImage(
        with resource: Resource?,
        placeholder: UIImage? = nil,
        progress: ((Int64, Int64) -> Void)? = nil,
        completion: ((ImageResult) -> Void)? = nil
        ) -> RetrieveImageTask {
        // GIF will only animates in the AnimatedImageView
        let options: KingfisherOptionsInfo? = nil//(self is AnimatedImageView) ? nil : [.onlyLoadFirstFrame]
        let completionHandler: CompletionHandler = { image, error, cacheType, url in
            if let image = image {
                completion?(.success(image))
            } else if let error = error {
                completion?(.failure(error))
            }
        }
        return self.kf.setImage(
            with: resource,
            placeholder: placeholder,
            options: options,
            progressBlock: progress,
            completionHandler: completionHandler
        )
    }
    
    func setImage(localURL: URL?) {
        guard let url = localURL else {
            log.error("URL is Null")
            return
        }
        setImage(with: url)
    }
}

public extension UIImageView {
    
    func setImage(url : URL?, placeholder: UIImage? = UIImage(named: "placeholder"), animated: Bool = true) {
        //        kf.indicatorType = .activity
        guard let imageURL = url else { return }
        
        if animated {
            kf.setImage(with: imageURL, placeholder: placeholder, options: [.backgroundDecode, .transition(.fade(1))])
        } else {
            kf.setImage(with: imageURL, placeholder: placeholder)
        }
    }
    
    /// 原始图
    func setImage(urlString URLString: String?, placeholder: UIImage? = nil, animated: Bool = true) {
        guard let urlString = URLString, let URL = URL(string: urlString) else {
            log.error("URL wrong ", URLString ?? "")
            return
        }
        setImage(url: URL, placeholder: placeholder, animated: animated)
    }

    func setCornerRadiusImage(urlString URLString: String?, placeholder: UIImage? = nil , cornerRadiusRatio: CGFloat = 5, progressBlock:ImageDownloaderProgressBlock? = nil) {
        guard let URLString = URLString, let URL = URL(string: URLString) else {
            print("URL wrong")
            return
        }

        let memoryImage = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey:URLString)
        let diskImage = KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey:URLString)
        guard let image = memoryImage ?? diskImage else {
            let optionInfo: KingfisherOptionsInfo = [ .forceRefresh ]
            KingfisherManager.shared.downloader.downloadImage(with: URL, options: optionInfo, progressBlock: progressBlock) { (image, error, imageURL, originalData) -> () in
                if let image = image, let originalData = originalData {
                    DispatchQueue.global(qos: .default).async {
                        let roundedImage = image.roundWithCornerRadius(cornerRadiusRatio)
                        KingfisherManager.shared.cache.store(roundedImage, original: originalData, forKey: URLString, toDisk: true, completionHandler: {
                            self.setImage(urlString: URLString, placeholder: placeholder)
                        })
                    }
                }
            }
            return
        }
        self.image = image
    }

    func setRoundImage(urlString URLString: String?, placeholder: UIImage? = nil, progressBlock: ImageDownloaderProgressBlock? = nil) {
        guard let URLString = URLString, let URL = URL(string: URLString) else {
            print("URL wrong")
            return
        }

        let memoryImage = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey:URLString)
        let diskImage = KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey:URLString)
        guard let image = memoryImage ?? diskImage else {
            let optionInfo: KingfisherOptionsInfo = [ .forceRefresh ]
            KingfisherManager.shared.downloader.downloadImage(with: URL, options: optionInfo, progressBlock: progressBlock) { (image, error, imageURL, originalData) -> () in
                if let image = image, let originalData = originalData {
                    DispatchQueue.global(qos: .default).async {
                        let roundedImage = image.roundWithCornerRadius(image.size.width * 0.5)
                        KingfisherManager.shared.cache.store(roundedImage, original: originalData, forKey: URLString, toDisk: true, completionHandler: {
                            self.setImage(urlString: URLString, placeholder: placeholder)
                        })
                    }
                }
            }
            return
        }
        self.image = image
    }
}

extension UIImage {
    
    func roundWithCornerRadius(_ cornerRadius: CGFloat) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
