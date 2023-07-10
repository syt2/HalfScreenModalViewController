//
//  HalfScreenModalViewController.swift
//  Swift-iOS
//
//  Created by syt on 2023/6/2.
//

import Foundation
import UIKit

public extension HalfScreenModalViewController {
    struct Config {
        
        /// Background overlay color
        /// default is `darkGray`
        var backgroundOverlayColor: UIColor
        
        /// Background overlay alpha
        /// default is `0.6`
        var backgroundOverlayAlpha: Double
        
        /// Default height of half-screen view controller
        /// half-screen view controller is initially at this height
        /// default is `300`
        var defaultHeight: Double
        
        /// Dismiss height of half-screen view controller
        /// half-screen view controller will dismissed after dragging below this height
        /// default is `200`
        var dismissedHeight: Double
        
        /// Maximum height of half-screen view controller
        /// half-screen view controller will remain at this height after being dragged to reach this height
        /// default is `UIScreen.main.bounds.height - 64`
        var maximumHeight: Double
        
        /// Maximum stretchable height
        /// After reaching to `maximumHeight`, further dragging will gradually decrease until increasing back to that height.
        /// default is `10`
        var stretchableHeight: Double
        
        /// Minimum absolute height of the view.
        /// When the height is less than this value, `contentView` will update the bottom offset.
        /// When the height is greater than this value, `contentView` will update the content height.
        /// defalut is `300`
        var minimumContentCompressHeight: Double
        
        /// corner radius of half-screen view controller
        /// default is `16`
        var cornerRadius: Double
        
        /// contentView dragable
        /// default is `true`
        var contentDragable: Bool
        
        /// overlay backgrounf dragable
        /// default is `false`
        var overlayBackgroundDragable: Bool
        
        /// dismiss when tap in overlay background
        /// default is `true`
        var overlayBackgroundTapDismiss: Bool
        
        
        public init(backgroundOverlayColor: UIColor = .darkGray,
                    backgroundOverlayAlpha: Double = 0.6,
                    defaultHeight: Double = 300.0,
                    dismissedHeight: Double = 200.0,
                    maximumHeight: Double = (UIScreen.main.bounds.height - 64),
                    stretchableHeight: Double = 10.0,
                    minimumContentCompressHeight: Double = 300.0,
                    cornerRadius: Double = 16.0,
                    contentDragable: Bool = true,
                    overlayBackgroundDragable: Bool = false,
                    overlayBackgroundTapDismiss: Bool = true) {
            self.backgroundOverlayColor = backgroundOverlayColor
            self.backgroundOverlayAlpha = backgroundOverlayAlpha
            self.defaultHeight = defaultHeight
            self.dismissedHeight = dismissedHeight
            self.maximumHeight = maximumHeight
            self.stretchableHeight = stretchableHeight
            self.minimumContentCompressHeight = minimumContentCompressHeight
            self.cornerRadius = cornerRadius
            self.contentDragable = contentDragable
            self.overlayBackgroundDragable = overlayBackgroundDragable
            self.overlayBackgroundTapDismiss = overlayBackgroundTapDismiss
        }
    }
}

/// Half Screen Modal View Controller
/// Must add subviews on `contentView`
open class HalfScreenModalViewController: UIViewController {
    /// view config
    public var config: Config {
        didSet { updateConfig(from: oldValue, to: config) }
    }
    
    private lazy var currentContentHeight = config.defaultHeight
    public private(set) lazy var contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = config.cornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    private lazy var backgroundOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.alpha = config.backgroundOverlayAlpha
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundOverlayCloseAction(_:)))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var associatedPanGestureRecognizers = [UIView: UIPanGestureRecognizer]()
    
    private var containerViewHeightConstraint: NSLayoutConstraint?
    private var containerViewBottomConstraint: NSLayoutConstraint?
    
    public init(config: Config) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        configViews()
        animatePresentContent()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateShowDimmedView()
    }
    
    /// dismiss with animation
    public func animateDismiss() {
        backgroundOverlayView.alpha = config.backgroundOverlayAlpha
        UIView.animate(withDuration: 0.3) {
            self.backgroundOverlayView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
        containerViewBottomConstraint?.constant = max(currentContentHeight, config.minimumContentCompressHeight)
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    /// remove a dragable view
    public func removeDragable(view: UIView) {
        if let pan = associatedPanGestureRecognizers[view] {
            view.removeGestureRecognizer(pan)
        }
        associatedPanGestureRecognizers.removeValue(forKey: view)
    }
    
    /// add a dragable view
    public func addDragable(view: UIView) {
        if associatedPanGestureRecognizers.keys.contains(view) { return }
        let pan = panGestureRecognizer
        view.addGestureRecognizer(pan)
        associatedPanGestureRecognizers[view] = pan
    }
}


private extension HalfScreenModalViewController {
    var panGestureRecognizer: UIPanGestureRecognizer {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        pan.delaysTouchesBegan = false
        pan.delaysTouchesEnded = false
        return pan
    }
    
    func updateConfig(from: Config, to: Config) {
        if from.backgroundOverlayAlpha != to.backgroundOverlayAlpha || from.backgroundOverlayColor != to.backgroundOverlayColor {
            UIView.animate(withDuration: 0.3) { [self] in
                backgroundOverlayView.alpha = to.backgroundOverlayAlpha
                backgroundOverlayView.backgroundColor = to.backgroundOverlayColor
            }
        }
        if from.cornerRadius != to.cornerRadius {
            contentView.layer.cornerRadius = config.cornerRadius
        }
        if from.contentDragable != to.contentDragable {
            if to.contentDragable {
                addDragable(view: contentView)
            } else {
                removeDragable(view: contentView)
            }
        }
        if from.overlayBackgroundDragable != to.overlayBackgroundDragable {
            if to.overlayBackgroundDragable {
                addDragable(view: view)
            } else {
                removeDragable(view: view)
            }
        }
    }
    
    func configViews() {
        view.addSubview(backgroundOverlayView)
        view.addSubview(contentView)
        backgroundOverlayView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundOverlayView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundOverlayView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backgroundOverlayView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3),
            backgroundOverlayView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 3),
            
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        containerViewHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: max(config.defaultHeight, config.minimumContentCompressHeight))
        containerViewBottomConstraint = contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: max(config.defaultHeight, config.minimumContentCompressHeight))
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
        if config.contentDragable {
            addDragable(view: contentView)
        }
        if config.overlayBackgroundDragable {
            addDragable(view: view)
        }
    }
    
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        let newHeight = currentContentHeight - sender.translation(in: view).y
        switch sender.state {
        case .changed:
            if newHeight < config.minimumContentCompressHeight {
                containerViewBottomConstraint?.constant = config.minimumContentCompressHeight - newHeight
            } else if newHeight < config.maximumHeight {
                containerViewHeightConstraint?.constant = newHeight
            } else {
                let offset = newHeight - config.maximumHeight
                /// Decay curve of nx / (x + n^2)
                let offsetHeight = config.stretchableHeight * offset / (offset + config.stretchableHeight * config.stretchableHeight)
                containerViewHeightConstraint?.constant = config.maximumHeight + offsetHeight
            }
            view.layoutIfNeeded()
        case .ended:
            changeToNewHeight(newHeight, isDraggingDown: sender.velocity(in: view).y > 0)
        default:
            break
        }
    }
    
    func changeToNewHeight(_ newHeight: CGFloat, isDraggingDown: Bool? = nil) {
        if newHeight < config.dismissedHeight {
            animateDismiss()
        } else if newHeight < config.defaultHeight {
            animateContentHeight(config.defaultHeight)
        } else if newHeight < config.maximumHeight && isDraggingDown != false {
            animateContentHeight(config.defaultHeight)
        } else if newHeight > config.defaultHeight && isDraggingDown != true {
            animateContentHeight(config.maximumHeight)
        }
    }
    
    @objc func handleBackgroundOverlayCloseAction(_ sender: Any) {
        guard config.overlayBackgroundTapDismiss else { return }
        animateDismiss()
    }
    
    func animateContentHeight(_ height: Double) {
        containerViewHeightConstraint?.constant = max(height, config.minimumContentCompressHeight)
        containerViewBottomConstraint?.constant = max(0, config.minimumContentCompressHeight - height)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        currentContentHeight = height
    }
    
    func animatePresentContent() {
        containerViewHeightConstraint?.constant = max(config.defaultHeight, config.minimumContentCompressHeight)
        containerViewBottomConstraint?.constant = max(0, config.minimumContentCompressHeight - config.defaultHeight)
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func animateShowDimmedView() {
        backgroundOverlayView.alpha = 0
        UIView.animate(withDuration: 0.3) { [self] in
            backgroundOverlayView.alpha = config.backgroundOverlayAlpha
            backgroundOverlayView.backgroundColor = config.backgroundOverlayColor
        }
    }
}
