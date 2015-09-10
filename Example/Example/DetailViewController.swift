// DetailViewController
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

class DetailViewController: UIViewController {

    @IBOutlet weak var animatedToggle: UISwitch!
    @IBOutlet weak var dismissableToggle: UISwitch!

    @IBOutlet weak var bottomView: UIView!

    var index: Int = 0

    var animated: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addConstraint(NSLayoutConstraint(item: bottomView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        println("\(index) will appear")

        self.animated = self.animatedToggle.on
        self.dismissableToggle.on = self.cardStackController?.topViewControllerCanBeDismissed ?? true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("\(index) did appear")
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        println("\(index) will disappear")
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        println("\(index) did disappear")
    }

    @IBAction func toggleAnimation(sender: UISwitch) {
        self.animated = sender.on
    }

    @IBAction func toggleDismissable(sender: UISwitch) {
        self.cardStackController?.topViewControllerCanBeDismissed = sender.on
    }

    @IBAction func push(sender: AnyObject) {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        self.cardStackController?.pushViewController(viewController, animated: self.animated)
    }

    @IBAction func pop(sender: AnyObject) {
        self.cardStackController?.popViewController(self.animated)
    }
}