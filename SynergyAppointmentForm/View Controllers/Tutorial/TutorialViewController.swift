import UIKit

class TutorialViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var imageUrls: [URL] = []
    private var images: [UIImage?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - FUNCTIONS
    func setupView() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        FirebaseController.shared.getTutorialScreenshotsURL { urls, error in
            if let error = error {
                print("Failed to get URLs: \(error)")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
                return
            }
            
            guard let urls = urls else {
                print("No URLs found")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
                return
            }
            
            self.imageUrls = urls
            self.images = Array(repeating: nil, count: urls.count)
            
            let group = DispatchGroup()
            
            for (index, url) in urls.enumerated() {
                group.enter()
                self.loadImage(from: url) { image in
                    if let image = image {
                        self.images[index] = image
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.updateStackView()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
    }

    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }
        task.resume()
    }
    
    func updateStackView() {
        self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for image in images {
            if let image = image {
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFit
                imageView.translatesAutoresizingMaskIntoConstraints = false
                
                self.stackView.addArrangedSubview(imageView)
                
                NSLayoutConstraint.activate([
                    imageView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),
                    imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: image.size.height / image.size.width)
                ])
            }
        }
    }
}
