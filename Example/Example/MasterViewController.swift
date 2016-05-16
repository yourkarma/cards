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

class MasterViewController: UIViewController, CardStackControllerDelegate {
    @IBOutlet weak var presentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cardStackController?.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("master will appear")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("master did appear", terminator: " ")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("master will disappear", terminator: " ")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("master did disappear", terminator: " ")
    }
    
    // CardStackController delegate methods
    
    func cardWillAppear() {
        print("cardWillAppear:", terminator: " ")
    }
    
    func cardDidAppear() {
        print("cardDidAppear:", terminator: " ")
    }
    
    func cardWillDisappear() {
        print("cardWillDisappear:", terminator: " ")
    }
    
    func cardDidDisappear() {
        print("cardDidDisappear:", terminator: " ")
    }
    
    @IBAction func push(sender: AnyObject) {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        self.cardStackController?.pushViewController(viewController, animated: true, completion: nil)
    }
    
    @IBAction func presentImage(sender: AnyObject) {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
        self.cardStackController?.pushViewController(viewController, animated: true, completion: nil)
    }
    
    @IBAction func presentUI(sender: AnyObject) {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("VerticalViewController") as! VerticalViewController
        self.cardStackController?.pushViewController(viewController, animated: true, completion: nil)
    }
}