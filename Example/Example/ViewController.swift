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

    let cardStackController = CardStackController()

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

        let viewController3 = UIViewController()
        viewController3.view = UIView()
        viewController3.view.backgroundColor = UIColor.greenColor()

        let viewController4 = UIViewController()
        viewController4.view = UIView()
        viewController4.view.backgroundColor = UIColor.cyanColor()

        self.presentViewController(cardStackController, animated: false, completion: nil)
        self.cardStackController.addViewController(viewController1)
        self.cardStackController.addViewController(viewController2)
        self.cardStackController.addViewController(viewController3)
        self.cardStackController.addViewController(viewController4)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

