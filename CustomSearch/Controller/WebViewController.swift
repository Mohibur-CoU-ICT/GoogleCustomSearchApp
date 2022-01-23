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
    
    var _title = "PageName"
    var link = "https://www.apple.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // to know when the webview start loading and end loading
        webView.navigationDelegate = self
        
        // add a background color to the footer buttons
        self.footerStackView.addBackground(color: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.3))
        
        // Adding loading indicator
        indicator.center = view.center
        view.addSubview(indicator)
        
        if NetworkMonitor.shared.isReachable {
            let myURL = URL(string: link)
            var myRequest = URLRequest(url: myURL!)
            myRequest.cachePolicy = .returnCacheDataElseLoad
            webView.load(myRequest)
            
            // Save web page content to database
            guard let myURL = URL(string: self.link) else {
                print("Error: \(self.link) doesn't seem to be a valid URL\n")
                return
            }
            
            do {
                let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
                //print("WebPage content = \n \(myHTMLString)\n")
                
                // Create directory
                let fileDirectory = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
                let filePath = fileDirectory.appendingPathComponent("Offline_Pages/\(self._title)")
                
                do {
                    try FileManager.default.createDirectory(atPath: filePath!.path, withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                    debugPrint("error = \(error)")
                    print("Unable to create directory.\n")
                }
                
                // Write in file
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = dir.appendingPathComponent("Offline_Pages/\(self._title)/\(self._title).html")
                    print("online filePath = \(fileURL)")
                    // writing
                    do {
                        try myHTMLString.write(to: fileURL, atomically: false, encoding: .utf8)
                    }
                    catch {
                        debugPrint("error = \(error)")
                        print("cant write to the file.\n")
                    }
                }
            }
            catch {
                debugPrint("error = \(error)")
            }
        }
        else {
            let fileDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let filePath = fileDirectory.appendingPathComponent("Offline_Pages/\(self._title)/\(self._title).html")
            print("offline filePath = \(filePath)")
            let url = URL.init(fileURLWithPath: filePath.path);
            let requestObj = URLRequest.init(url: url)
            webView.load(requestObj)
        }
    }
    
    //    override func viewDidAppear(_ animated: Bool) {
    //        indicator.startAnimating()
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
