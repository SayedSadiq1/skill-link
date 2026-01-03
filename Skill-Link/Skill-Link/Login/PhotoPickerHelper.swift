import Foundation
import UIKit
import PhotosUI

// Helper to handle picking a photo from the gallery
final class PhotoPickerHelper: NSObject, PHPickerViewControllerDelegate {

    // Screen that shows the picker
    private weak var presenter: UIViewController?

    // Called when image is selected
    private let onImagePicked: (UIImage) -> Void

    // Setup with screen and callback
    init(presenter: UIViewController, onImagePicked: @escaping (UIImage) -> Void) {
        self.presenter = presenter
        self.onImagePicked = onImagePicked
    }

    // Opens the photo picker UI
    func presentPicker() {
        // Picker config using shared photos
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images       // images only
        config.selectionLimit = 1     // single image

        // Create and show picker
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        presenter?.present(picker, animated: true)
    }

    // Runs when user finishes picking
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // Close the picker screen
        picker.dismiss(animated: true)

        // Get the selected image provider
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        // Load image in background
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self, let image = object as? UIImage else { return }

            // Return image on main thread
            DispatchQueue.main.async {
                self.onImagePicked(image)
            }
        }
    }
}
