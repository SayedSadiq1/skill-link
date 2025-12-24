//
//  PhotoPickerHelper.swift
//  Skill-Link
//
//  Created by BP-36-201-23 on 24/12/2025.
//

import Foundation
import UIKit
import PhotosUI

final class PhotoPickerHelper: NSObject, PHPickerViewControllerDelegate {

    private weak var presenter: UIViewController?
    private let onImagePicked: (UIImage) -> Void

    init(presenter: UIViewController, onImagePicked: @escaping (UIImage) -> Void) {
        self.presenter = presenter
        self.onImagePicked = onImagePicked
    }

    func presentPicker() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        presenter?.present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self, let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self.onImagePicked(image)
            }
        }
    }
}
