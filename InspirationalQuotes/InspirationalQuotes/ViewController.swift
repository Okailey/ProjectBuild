//
//  ViewController.swift
//  InspirationalQuotes
//
//  Created by Danielle Naa Okailey Quaye on 11/12/23.
//

import UIKit
import ImageIO

class ViewController: UIViewController {
    
    @IBOutlet weak var quote: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeGif: UIImageView!
    @IBOutlet weak var loveButton: UIButton!
    @IBOutlet weak var loveGif: UIImageView!
    
    private var gifTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRandomQuote()
    }

    @IBAction func fetchQuoteButtonTapped(_ sender: UIButton) {
        fetchRandomQuote()
    }

    @IBAction func likeButtonTapped(_ sender: UIButton) {
        showReactionGIF(named: "like")
        startGifTimer(for: likeGif)
    }

    @IBAction func loveButtonTapped(_ sender: UIButton) {
        showReactionGIF(named: "love")
        startGifTimer(for: loveGif)
    }

    func showReactionGIF(named: String) {
        guard let gifURL = Bundle.main.url(forResource: named, withExtension: "gif") else {
            print("GIF not found.")
            return
        }

        do {
            let gifData = try Data(contentsOf: gifURL)
            let gif = UIImage.gifImageWithData(gifData)

            // Set corresponding GIFs for like and love reactions
            if named == GIFNames.like {
                likeGif.image = gif
            } else if named == GIFNames.love {
                loveGif.image = gif
            }
        } catch {
            print("Error loading GIF: \(error.localizedDescription)")
        }
    }
    
    func startGifTimer(for imageView: UIImageView) {
        // Set the timer duration (e.g., 5 seconds)
        let timerDuration = 5.0
        
        // Invalidate existing timer
        gifTimer?.invalidate()
        
        // Capture self weakly to avoid a strong reference cycle
        gifTimer = Timer.scheduledTimer(withTimeInterval: timerDuration, repeats: false) { _ in
            // Stop the GIF animation
            imageView.image = nil
        }
    }
    func fetchRandomQuote() {
        fetchQuotes.fetchRandomQuote { [weak self] result in
            switch result {
            case .success(let quote):
                DispatchQueue.main.async {
                    self?.quote.text = "\"\(quote.content)\"\n- \(quote.author)"
                }
            case .failure(let error):
                print("Error fetching quote: \(error.localizedDescription)")
            }
        }
    }
}

// Constants for GIF names
private struct GIFNames {
    static let like = "like"
    static let love = "love"
}

// MARK: - Extensions
extension UIImage {
    class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("Error: Source for the GIF not created!")
            return nil
        }

        return UIImage.animatedImageWithSource(source)
    }

    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [UIImage]()

        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: image))
            }
        }

        let duration = images.reduce(0) { acc, image in
            acc + CGImageSourceGifFrameDelay(source, index: images.firstIndex(of: image) ?? 0)
        }

        return UIImage.animatedImage(with: images, duration: duration)
    }
}

private extension UIImage {
    class func CGImageSourceGifFrameDelay(_ source: CGImageSource, index: Int) -> Double {
        var delay = 0.1

        if let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [String: Any],
            let gifProperties = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any],
            let unclampedDelay = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double {
            delay = unclampedDelay
        } else {
            let frameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [String: Any]
            let gifProperties = frameProperties?[kCGImagePropertyGIFDictionary as String] as? [String: Any]
            delay = gifProperties?[kCGImagePropertyGIFDelayTime as String] as? Double ?? delay
        }

        return delay
    }
}
