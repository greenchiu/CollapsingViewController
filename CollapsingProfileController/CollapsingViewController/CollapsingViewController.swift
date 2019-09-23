//
//  CollapsingViewController.swift
//  CollapsingProfileController
//
//  Created by GreenChiu on 2019/9/23.
//  Copyright © 2019 GreenChiu. All rights reserved.
//


import UIKit

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

private struct CollapsingInnerView {
    let view: UIView
    var height: CGFloat?
}

class CollapsingViewController: UIViewController {
    private var collapsed = false
    private var viewConfiguration: [String.CollapsingKey: CollapsingInnerView] = [:]
    private var lastOffsetsOfScrollView: [String: CGFloat] = [:]
    private var collapsedRightBarItems: [UIBarButtonItem] = []
    private var collapsedIntervalSpace: CGFloat?
    private var isArranged = false
    var headerHeight: CGFloat {
        set {
            guard var header = viewConfiguration[.header] else {
                return
            }
            guard header.height != newValue else { return }
            header.height = newValue
            reLayoutSubviews()
        }
        get { return viewConfiguration[.header]?.height ?? 0 }
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
    
    func configureCollapsedRightBar(items: [UIBarButtonItem]) {
        collapsedRightBarItems = items
    }
}

extension CollapsingViewController {
    func collapsing(with scrollView: UIScrollView) {
        guard let interspace = collapsedIntervalSpace, let content = viewConfiguration[.contentView]?.view else { return }
        let key = String(format: "%p", scrollView)
        let lastOffset = lastOffsetsOfScrollView[key] ?? 0
        let offsetY = scrollView.contentOffset.y

        // TODO: Add/Remove the navigationBar items and update the background for navigationBar.
        var frame = content.frame
        if lastOffset > offsetY {
            if frame.minY < interspace {
                let newY = min(frame.minY+(lastOffset - offsetY), interspace)
                frame.origin = CGPoint(x: 0, y: newY)
                frame.size = CGSize(width: view.bounds.width, height: view.bounds.height - newY)
                content.frame = frame
                updateHeaderPosition()
                scrollView.contentOffset = .zero
            }
        }
        else if lastOffset < offsetY {
            if frame.minY > view.safeAreaInsets.top {
                let newY = max(frame.minY+(lastOffset - offsetY), view.safeAreaInsets.top)
                frame.origin = CGPoint(x: 0, y: newY)
                frame.size = CGSize(width: view.bounds.width, height: view.bounds.height - newY)
                content.frame = frame
                updateHeaderPosition()
                scrollView.contentOffset = .zero
            }
        }
        
        lastOffsetsOfScrollView[key] = lastOffset
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
    }
    
    func updateNavigationBarIfNeed() {
        guard let navigationController = navigationController, !navigationController.isNavigationBarHidden else {
            return
        }
        
        
    }
    
    func updateHeaderPosition() {
        guard let header = viewConfiguration[.header],
            let content = viewConfiguration[.contentView]?.view else { return }
        var frame = header.view.frame
        frame.origin = CGPoint(x: 0, y: content.frame.minY - header.height!)
        header.view.frame = frame
    }
}
