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
        static var contentSection: CollapsingKey { return CollapsingKey(rawValue: "contentSection") }
        static var contentView: CollapsingKey { return CollapsingKey(rawValue: "contentView") }
    }
}

private struct CollapsingInnerView {
    let view: UIView
    var height: CGFloat?
}

class CollapsingViewController: UIViewController {
    private var haveHeader = false
    private var collapsed = false
    private var viewConfiguration: [String.CollapsingKey: CollapsingInnerView] = [:]
    private var collapsedRightBarItems: [UIBarButtonItem] = []
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
        view.backgroundColor = .clear
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        reLayoutSubviews()
    }
}

extension CollapsingViewController {
    func configureHeader(_ header: UIView?, height: CGFloat = 0) {
        configure(view: header, height: height, key: .header)
        haveHeader = (header != nil && height > 0)
    }
    
    func configureSection(view: UIView?, height: CGFloat = 0) {
        configure(view: view, height: height, key: .contentSection)
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
        guard haveHeader else { return }
    }
}


private extension CollapsingViewController {
    func configure(view: UIView?, height: CGFloat = 0, key: String.CollapsingKey) {
        defer { reLayoutSubviews() }
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
        
        for key in [String.CollapsingKey.header, .contentSection] {
            guard let config = viewConfiguration[key] else {
                continue
            }
            let height = config.height ?? 0
            config.view.frame = CGRect(x: 0, y: offset, width: width, height: height)
            offset += height
        }
        
        guard let content = viewConfiguration[.contentView] else {
            fatalError("Must have Content View for CollapsingViewController")
        }
        content.view.frame = CGRect(x: 0, y: offset, width: width, height: view.bounds.height - offset)
    }
}
