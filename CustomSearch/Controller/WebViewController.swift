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
        
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
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

extension WebViewController: UIWebViewDelegate {
    private func webViewDidFinishLoad(_ webView: WKWebView) {
        print("Finished loading")
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
        }
    }
}
