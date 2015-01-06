// CardStackViewController.Swift
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

public class CardStackViewController: UIViewController {

    public var viewControllers: [UIViewController] = [] {
        willSet(newViewControllers) {
            for viewController: UIViewController in self.childViewControllers as [UIViewController] {
                viewController.willMoveToParentViewController(nil)
                viewController.view.removeFromSuperview()
                viewController.removeFromParentViewController()
            }

            for viewController in newViewControllers {
                self.addChildViewController(viewController)
                viewController.view.frame = self.view.bounds
                self.view.addSubview(viewController.view)
                viewController.didMoveToParentViewController(self)
            }
        }
    }

    public override func loadView() {
        let view = UIView()
        view.frame = UIScreen.mainScreen().bounds
        self.view = view
    }

}
