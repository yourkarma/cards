//
//  ViewController.swift
//  Example
//
//  Created by Klaas Pieter Annema on 06/01/15.
//  Copyright (c) 2015 Karma Mobility Inc. All rights reserved.
//

import UIKit
import Cards

class ViewController: UIViewController {

    let cardsViewController = CardStackViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        let viewController1 = UIViewController()
        viewController1.view = UIView()
        viewController1.view.backgroundColor = UIColor.yellowColor()

        let viewController2 = UIViewController()
        viewController2.view = UIView()
        viewController2.view.backgroundColor = UIColor.blueColor()

        self.presentViewController(cardsViewController, animated: false, completion: nil)
        self.cardsViewController.viewControllers = [viewController1, viewController2]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

