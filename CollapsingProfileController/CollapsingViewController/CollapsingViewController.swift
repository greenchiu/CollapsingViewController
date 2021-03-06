//
//  CollapsingViewController.swift
//  CollapsingProfileController
//
//  Created by GreenChiu on 2019/9/23.
//  Copyright © 2019 GreenChiu. All rights reserved.
//


import UIKit

private let kMinFadeInOutOffset: CGFloat = 44

private extension UIApplication {
    static var statusBarHight: CGFloat { return  shared.statusBarFrame.height }
}

private extension String {
    struct CollapsingKey: Hashable, RawRepresentable {
        typealias RawValue = String
        static func == (lhs: String.CollapsingKey, rhs: String.CollapsingKey) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }

        fileprivate let rawValue: RawValue
        static var header: CollapsingKey { return CollapsingKey(rawValue: "header") }
        static var contentView: CollapsingKey { return CollapsingKey(rawValue: "contentView") }
    }
}

class CollapsingViewController: UIViewController {
    private lazy var collapsedBarView = CollapsedBarView()
    private var collapsed = false
    private var viewConfiguration: [String.CollapsingKey: CollapsingInnerView] = [:]
    private var lastOffsetsOfScrollView: [String: CGFloat] = [:]
    private var collapsedIntervalSpace: CGFloat?
    private var isArranged = false
    var barFadeInOutOffset: CGFloat = kMinFadeInOutOffset {
        didSet {
            guard barFadeInOutOffset < kMinFadeInOutOffset else { return }
            barFadeInOutOffset = kMinFadeInOutOffset
        }
    }
    var headerHeight: CGFloat {
        set {
            guard var header = viewConfiguration[.header] else {
                return
            }
            guard header.height != newValue else { return }
            // TODO: Correct the intervalSpace.
            // TODO: Add animation.
            header.height = newValue
            reLayoutSubviews()
        }
        get { return viewConfiguration[.header]?.height ?? 0 }
    }
    
    var collapsedTitle: String? {
        set { collapsedBarView.title = newValue }
        get { return collapsedBarView.title }
    }
    
    var collapsedTitleColor: UIColor {
        set { collapsedBarView.textColor = newValue }
        get { return collapsedBarView.textColor }
    }
    
    var collapsedBarColor: UIColor? {
        set { collapsedBarView.backgroundColor = newValue }
        get { return collapsedBarView.backgroundColor }
    }
    var collapsedBarRightItems: [UIBarButtonItem]? {
        didSet {
            guard collapsedBarView.alpha > 0, let items = collapsedBarRightItems else { return }
            navigationItem.setRightBarButtonItems(items, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard !isArranged else { return }
        isArranged = true
        reLayoutSubviews()
    }
}

extension CollapsingViewController {
    func configureHeader(_ header: UIView?, height: CGFloat = 0) {
        configure(view: header, height: height, key: .header)
    }
    
    func configureContent(view: UIView?) {
        configure(view: view, height: 0, key: .contentView)
    }
}

extension CollapsingViewController {
    func collapsing(with scrollView: UIScrollView) {
        guard let interspace = collapsedIntervalSpace, let content = viewConfiguration[.contentView]?.view else { return }
        let key = String(format: "%p", scrollView)
        let lastOffset = lastOffsetsOfScrollView[key] ?? 0
        let offsetY = scrollView.contentOffset.y

        let frame = content.frame
        var leaveIntervalSpace: CGFloat?
        if lastOffset > offsetY {
            if frame.minY < interspace {
                update(contentView: content, positionY: min(frame.minY+(lastOffset - offsetY), interspace))
                updateHeaderPosition()
                scrollView.contentOffset = .zero
                leaveIntervalSpace = content.frame.minY - view.safeAreaInsets.top
            }
        }
        else if lastOffset < offsetY {
            if frame.minY > view.safeAreaInsets.top {
                update(contentView: content, positionY: max(frame.minY+(lastOffset - offsetY), view.safeAreaInsets.top))
                updateHeaderPosition()
                scrollView.contentOffset = .zero
                leaveIntervalSpace = content.frame.minY - view.safeAreaInsets.top
            }
        }
        
        lastOffsetsOfScrollView[key] = lastOffset
        
        guard let space = leaveIntervalSpace else { return }
        
        if let _ = navigationItem.rightBarButtonItems, space > barFadeInOutOffset {
            navigationItem.setRightBarButtonItems(nil, animated: true)
        }
        else if let items = collapsedBarRightItems, navigationItem.rightBarButtonItems == nil, space <= barFadeInOutOffset {
            navigationItem.setRightBarButtonItems(items, animated: true)
        }
        
        guard 0...barFadeInOutOffset ~= space else {
            if space > 0 {
                collapsedBarView.alpha = 0
            }
            return
        }
        collapsedBarView.alpha = 1 - ((space - barFadeInOutOffset + kMinFadeInOutOffset) / kMinFadeInOutOffset)
    }
    
    private func update(contentView: UIView, positionY y: CGFloat) {
        var frame = contentView.frame
        frame.origin = CGPoint(x: 0, y: y)
        frame.size = CGSize(width: view.bounds.width, height: view.bounds.height - y)
        contentView.frame = frame
    }
}


private extension CollapsingViewController {
    func configure(view: UIView?, height: CGFloat = 0, key: String.CollapsingKey) {
        if let config = viewConfiguration[key] {
            config.view.removeFromSuperview()
        }
        guard let view = view else { return }
        let newConfig = CollapsingInnerView(view: view, height: height)
        viewConfiguration[key] = newConfig
    }
    
    func reLayoutSubviews() {
        guard isViewLoaded else { return }
        var offset: CGFloat = view.safeAreaInsets.top
        let width = view.bounds.width
        collapsedIntervalSpace = nil
        
        if let config = viewConfiguration[.header] {
            let height = config.height ?? 0
            config.view.frame = CGRect(x: 0, y: offset, width: width, height: height)
            view.addSubview(config.view)
            offset += height
            collapsedIntervalSpace = offset
        }
        
        guard let content = viewConfiguration[.contentView] else {
            fatalError("Must have Content View for CollapsingViewController")
        }
        content.view.frame = CGRect(x: 0, y: offset, width: width, height: view.bounds.height - offset)
        view.addSubview(content.view)
        
        collapsedBarView.frame = CGRect(origin: .zero, size: CGSize(width: width, height: UIApplication.statusBarHight + 44))
        view.addSubview(collapsedBarView)
    }
    
    func updateHeaderPosition() {
        guard let header = viewConfiguration[.header],
            let content = viewConfiguration[.contentView]?.view else { return }
        var frame = header.view.frame
        frame.origin = CGPoint(x: 0, y: content.frame.minY - header.height!)
        header.view.frame = frame
    }
}

///
/// Internal models
///
private extension CollapsingViewController {
    struct CollapsingInnerView {
        enum Height {
            case value(CGFloat)
            case fillTheRest
        }
        let view: UIView
        var height: CGFloat?
    }
}

private class CollapsedBarView: UIView {
    private let textLabel = UILabel()
    
    var title: String? {
        set { textLabel.text = newValue }
        get { return textLabel.text }
    }
    
    var textColor: UIColor {
        set { textLabel.textColor = newValue }
        get { return textLabel.textColor }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textLabel.font = .systemFont(ofSize: 24, weight: .bold)
        textLabel.textAlignment = .center
        addSubview(textLabel)
        alpha = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported xib or storyboard")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.frame = CGRect(origin: CGPoint(x: 60, y: UIApplication.statusBarHight),
                                 size: bounds.inset(by: .init(top: UIApplication.statusBarHight, left: 60, bottom: 0, right: 60)).size)
    }
}
