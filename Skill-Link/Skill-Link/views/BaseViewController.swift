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

        setBackgroundImage(named: "smaller_background")
        setupNavigationItemStyle()
    }

    private func setBackgroundImage(named name: String) {
        let bg = UIImageView(image: UIImage(named: name))
        bg.contentMode = .scaleAspectFill
        bg.translatesAutoresizingMaskIntoConstraints = false

        view.insertSubview(bg, at: 0) // behind everything

        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: view.topAnchor),
            bg.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
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
    
        func addBottomBorder(
        to view: UIView,
        color: UIColor = .lightGray,
        height: CGFloat = 1
    ) {
        let border = UIView()
        border.backgroundColor = color
        border.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(border)

        NSLayoutConstraint.activate([
            border.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            border.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            border.heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    
    func addTopBorder(
        to view: UIView,
        color: UIColor = .lightGray,
        height: CGFloat = 1
    ) {
        let border = UIView()
        border.backgroundColor = color
        border.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(border)

        NSLayoutConstraint.activate([
            border.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            border.topAnchor.constraint(equalTo: view.topAnchor),
            border.heightAnchor.constraint(equalToConstant: height)
        ])
    }
    }

