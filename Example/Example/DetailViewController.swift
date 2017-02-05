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
        self.view.addConstraint(NSLayoutConstraint(item: bottomView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("detail will appear")

        self.animated = self.animatedToggle.isOn
        self.dismissableToggle.isOn = self.cardStackController?.topViewControllerCanBeDismissed ?? true
     }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("detail did appear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        print("detail will disappear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("detail did disappear")
    }

    @IBAction func toggleAnimation(_ sender: UISwitch) {
        self.animated = sender.isOn
    }

    @IBAction func toggleDismissable(_ sender: UISwitch) {
        self.cardStackController?.topViewControllerCanBeDismissed = sender.isOn
    }

    @IBAction func push(_ sender: AnyObject) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        self.cardStackController?.pushViewController(viewController, animated: self.animated)
    }

    @IBAction func pop(_ sender: AnyObject) {
        self.cardStackController?.popViewController(self.animated)
    }

    @IBAction func presentCurrentContext(_ sender: AnyObject) {
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "VerticalViewController")
        self.showDetailViewController(viewController, sender: sender)
    }
}
