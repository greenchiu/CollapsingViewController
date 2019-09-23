//
//  ViewController.swift
//  CollapsingProfileController
//
//  Created by GreenChiu on 2019/9/23.
//  Copyright © 2019 GreenChiu. All rights reserved.
//

import UIKit

class ViewController: CollapsingViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel()
        label.backgroundColor = .yellow
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textAlignment = .center
        label.text = "Header"
        configureHeader(label, height: 180)
        
        let section = UIView(frame: CGRect(origin: .zero,
                                           size: CGSize(width: UIScreen.main.bounds.width, height: 44)))
        section.backgroundColor = .blue
        section.autoresizingMask = [.flexibleWidth]
        
        let scrollView = UIScrollView(frame: CGRect(origin: CGPoint(x: 0, y: 44),
                                                    size: CGSize(width: UIScreen.main.bounds.width,
                                                                 height: 0)))
        scrollView.autoresizingMask = [.flexibleHeight]
        scrollView.backgroundColor = .lightGray
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 5000)
        scrollView.delegate = self
        
        let container = UIView()
        container.addSubview(section)
        container.addSubview(scrollView)
        configureContent(view: container)
    }

}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collapsing(with: scrollView)
    }
}
