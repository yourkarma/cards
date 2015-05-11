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

class IndexViewController: UIViewController {
    var label: UILabel! = nil
    var index: Int = 0 {
        didSet {
            self.view.setNeedsLayout()
            self.view.setNeedsUpdateConstraints()
        }
    }
    var height: CGFloat

    required init(height: CGFloat = 200.0) {
        self.height = height
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = UIView()
        self.view.frame.size.height = self.height

        self.label = UILabel()
        self.label.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.label.textAlignment = .Center
        self.view.addSubview(self.label)
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

        let views = ["label": self.label]
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[label]|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[label]", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views))
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.label.text = String(self.index)
    }
}

class ViewController: UIViewController {

    var cardStackController: CardStackController!

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        cardStackController = segue.destinationViewController as! CardStackController
    }


    func delay(delay: Double, closure: (() -> Void)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            closure()
        }
    }

    func perform(closure: ( () -> () ) -> ()) {
        println("started with: \(self.cardStackController.viewControllers.count)")
        closure() {
            for index in (0..<self.cardStackController.viewControllers.count) {
                let viewController = self.cardStackController.viewControllers[index] as! IndexViewController
                viewController.index = index
            }

            println("ended with: \(self.cardStackController.viewControllers.count)")
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        delay(0.2) {
            self.pushViewControllers()
        }
    }

    func pushViewControllers() {
        perform {
            self.cardStackController.setViewControllers(
                [self.createViewController(height: 150.0), self.createViewController(height: 400.0), self.createViewController(height: 350.0)],
                animated: true, completion: $0)
        }
    }

    @IBAction func pushViewController() {
        perform {
            self.cardStackController.pushViewController(self.createViewController(), animated: true, completion: $0)
        }
    }

    @IBAction func insertTwoViewControllers() {
        perform {
            var existingViewControllers = self.cardStackController.viewControllers

            if (existingViewControllers.count < 1) {
                existingViewControllers.insert(self.createViewController(), atIndex: 0)
                existingViewControllers.insert(self.createViewController(), atIndex: 0)
            } else {
                existingViewControllers.insert(self.createViewController(), atIndex: 1)
                existingViewControllers.insert(self.createViewController(), atIndex: 1)
            }

            self.cardStackController.setViewControllers(existingViewControllers, animated: true, completion: $0)
        }
    }


    @IBAction func insertAndRemoveOneViewController() {
        perform {
            var existingViewControllers = self.cardStackController.viewControllers

            let viewController = existingViewControllers.removeLast()
//            existingViewControllers.insert(viewController, atIndex: 1)
            existingViewControllers.insert(self.createViewController(), atIndex: 0)
            self.cardStackController.setViewControllers(existingViewControllers, animated: true, completion: $0)
        }
    }

    @IBAction func popViewController() {
        perform {
            self.cardStackController.popViewController(animated: true, completion: $0)
        }
    }

    @IBAction func removeTwoViewControllers() {
        perform {
            var existingViewControllers = self.cardStackController.viewControllers

            if (existingViewControllers.count > 2) {
                existingViewControllers.removeAtIndex(1)
                existingViewControllers.removeAtIndex(1)
            } else {
                existingViewControllers.removeAll(keepCapacity: false)
            }

            self.cardStackController.setViewControllers(existingViewControllers, animated: true, completion: $0)
        }
    }

    func randomColor() -> UIColor {
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
    }

    func createViewController(height: CGFloat = 200.0) -> IndexViewController {
        let viewController = IndexViewController(height: height)
        viewController.view.backgroundColor = randomColor()
        return viewController
    }
}