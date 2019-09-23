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
        
        let section = UIView()
        section.backgroundColor = .blue
        configureSection(view: section, height: 44)
        
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .lightGray
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 5000)
        scrollView.delegate = self
        configureContent(view: scrollView)
    }

}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collapsing(with: scrollView)
    }
}
