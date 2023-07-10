//
//  ViewController.swift
//  Example
//
//  Created by syt on 2023/7/10.
//

import UIKit
import HalfScreenModalViewController

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton()
        button.setTitle("Show", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        view.addSubview(button)
        button.addTarget(self, action: #selector(tap), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 128),
            button.heightAnchor.constraint(equalToConstant: 48),
        ])
    }

    @objc private func tap() {
        present(ExampleHalfScreenViewController(), animated: true)
    }
}




class ExampleHalfScreenViewController: HalfScreenModalViewController {
    private lazy var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .label.withAlphaComponent(0.3)
        view.layer.cornerRadius = 2.5
        return view
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "Half Screen Modal View Controller"
        return label
    }()
    private lazy var closeButton = UIButton(type: .close, primaryAction: .init(handler: { [unowned self] _ in
        animateDismiss()
    }))
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.text =
        """
        # Half Screen Modal View Controller
        
        iOS UIKit Half-Screen Modal View Controller

        ## Usage
        1. Add this repository to your project using SPM
        2. `import HalfScreenModalViewController` in File
        3. Declare a new UIViewController that inherits from `HalfScreenModalViewController`
            - `Views must be added to the `contentView`, not to the `view`.`
        """
        label.numberOfLines = 0
        label.textAlignment = .natural
        return label
    }()
    private lazy var line: UIView = {
        let line = UIView()
        line.backgroundColor = .lightGray.withAlphaComponent(0.5)
        return line
    }()
    
    init() {
        super.init(config: .init())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(indicatorView)
        contentView.addSubview(closeButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(label)
        contentView.addSubview(line)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            indicatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            indicatorView.widthAnchor.constraint(equalToConstant: 36),
            indicatorView.heightAnchor.constraint(equalToConstant: 4),
            
            closeButton.widthAnchor.constraint(equalToConstant: 28),
            closeButton.heightAnchor.constraint(equalToConstant: 28),
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 48),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -48),
            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            
            line.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            line.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),
            line.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            
            label.topAnchor.constraint(equalTo: line.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
    }
}

