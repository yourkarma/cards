// ViewController.swift
//
// Copyright (c) 2015 Karma Mobility Inc. (https://yourkarma.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Cards

class ViewController: UIViewController {

    var cardStackController: CardStackController!

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

        self.cardStackController.pushViewController(viewController1)
        self.cardStackController.pushViewController(viewController2)
        self.cardStackController.pushViewController(viewController3)
        self.cardStackController.pushViewController(viewController4)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        cardStackController = segue.destinationViewController as CardStackController
    }

}

