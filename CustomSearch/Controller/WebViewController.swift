//
//  WebViewController.swift
//  CustomSearch
//
//  Created by Brotecs Mac Mini on 12/21/21.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var footerStackView: UIStackView!
    let indicator = UIActivityIndicatorView(style: .gray)
    
    var link = "https://www.apple.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string: link)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        webView.navigationDelegate = self
        
        self.footerStackView.addBackground(color: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.3))
        
        indicator.center = view.center
        view.addSubview(indicator)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        indicator.stopAnimating()
//    }
    
    @IBAction func backwardButtonTapped(_ sender: Any) {
        webView?.goBack()
    }
    
    @IBAction func forwardButtonTapped(_ sender: Any) {
        webView?.goForward()
    }
    
    @IBAction func exitButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//        print("Start Loading")
        DispatchQueue.main.async {
            self.indicator.startAnimating()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        print("End loading")
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
        }
    }
}

extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}
