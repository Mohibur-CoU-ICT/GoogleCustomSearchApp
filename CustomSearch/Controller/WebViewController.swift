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
    let indicator = UIActivityIndicatorView(style: .gray)
    
    var link = "https://www.apple.com"
    
//    override func loadView() {
//        let webConfiguration = WKWebViewConfiguration()
//        webView = WKWebView(frame: .zero, configuration: webConfiguration)
//        webView.uiDelegate = self
//        view = webView
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string: link)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        webView.navigationDelegate = self
        
        indicator.center = view.center
        view.addSubview(indicator)
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        indicator.stopAnimating()
    }
    
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
