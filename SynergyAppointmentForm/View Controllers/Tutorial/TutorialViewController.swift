//
//  TutorialViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 8/28/24.
//

import UIKit

class TutorialViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
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
            
            let group = DispatchGroup()
            for url in urls {
                group.enter()
                self.loadImage(from: url) { image in
                    if let image = image {
                        self.addImageToStackView(image)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
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
    
    func addImageToStackView(_ image: UIImage) {
        DispatchQueue.main.async {
            
            let imageView = UIImageView(image: image)
             imageView.contentMode = .scaleAspectFit
             imageView.translatesAutoresizingMaskIntoConstraints = false
             
             // Add the image view to the stack view
            self.stackView.addArrangedSubview(imageView)
             
             // Apply constraints
             NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),
                imageView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor)
             ])
         }
    }
}

