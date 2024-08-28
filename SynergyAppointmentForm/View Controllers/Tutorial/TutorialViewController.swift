//
//  TutorialViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 8/28/24.
//

import UIKit

class TutorialViewController: UITabBarController {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - FUNCTIONS
    func setupView() {
        FirebaseController.shared.getTutorialScreenshotsURL { urls, error in
            if let error = error {
                print("Failed to get URLs: \(error)")
                return
            }
            
            guard let urls = urls else {
                print("No URLs found")
                return
            }
            
            DispatchQueue.main.async {
                for url in urls {
                    self.loadImage(from: url) { image in
                        if let image = image {
                            self.addImageToStackView(image)
                        }
                    }
                }
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
    
    func addImageToStackView(_ image: UIImage) {
        DispatchQueue.main.async {
            
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set width and height constraints to match the scrollView's height
            imageView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor).isActive = true
            imageView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor).isActive = true
        
            self.stackView.addArrangedSubview(imageView)
        }
    }
}

