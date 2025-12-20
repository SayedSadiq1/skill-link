//
//  BaseViewController.swift
//  Skill-Link
//
//  Created by Sayed on 20/12/2025.
//
import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.contents = UIImage(named: "smaller_background")?.cgImage
        view.layer.contentsGravity = .resizeAspectFill

        setupNavigationItemStyle()
    }

    private func setupNavigationItemStyle() {
        guard let navBar = navigationController?.navigationBar else { return }

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear    // transparent over background image
        appearance.shadowColor = .clear        // remove bottom line

        // Title style
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]

        // Large title (if used anywhere)
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 32, weight: .bold)
        ]

        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance

        navBar.tintColor = .white
        navigationItem.hidesBackButton = true

        let backButton = UIBarButtonItem(
                    title: "←",
                    style: .plain,
                    target: self,
                    action: #selector(handleBack)
                )
        backButton.setTitleTextAttributes([
                 .foregroundColor: UIColor.white,
                 .font: UIFont.systemFont(ofSize: 16, weight: .medium)
             ], for: .normal)

             navigationItem.leftBarButtonItem = backButton
         }

         @objc private func handleBack() {
             navigationController?.popViewController(animated: true)
         }
    }

