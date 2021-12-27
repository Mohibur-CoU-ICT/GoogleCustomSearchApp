//
//  ViewController.swift
//  CustomSearch
//
//  Created by Brotecs Mac Mini on 12/14/21.
//

import UIKit
import WebKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var searchQueryTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    var _items: [Items]?
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        resultTableView.delegate = self
        resultTableView.dataSource = self
//        searchButton.addTarget(self, action: #selector(self.onTap(_:)), for: .touchUpInside)
//        resultTableView.estimatedRowHeight = 200.0
//        resultTableView.rowHeight = UITableView.automaticDimension
    }
    
    //    @objc func onTap(_ sender: Any) {
    //        if(searchQueryTextField.text!.isEmpty == false){
    //            let url = URL(string: "https://www.googleapis.com/customsearch/v1?key=AIzaSyBhDq-e6q0W3aImfJoaABG37vN-LVlx4J8&cx=6e6d97019e0665110&q=\(String(describing: searchQueryTextField.text!)))")!
    //
    //            var request = URLRequest(url: url)
    //            request.httpMethod = "GET"
    //            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    //            request.addValue("application/json", forHTTPHeaderField: "Accept")
    //
    //            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
    //                // print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
    //                if error == nil && data != nil {
    //                    // Parse JSON
    //                    let decoder = JSONDecoder()
    //                    do {
    //                        let searchResult = try decoder.decode(CustomSearch.self, from: data!)
    //                        print(searchResult)
    //                        self._items = searchResult.items
    //
    //                        DispatchQueue.main.async {
    //                            self.resultTableView.reloadData()
    //                        }
    //                    }
    //                    catch {
    //                        print("Error in JSON parsing")
    //                    }
    //                }
    //            })
    //
    //            task.resume()
    //        }
    //    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        if(searchQueryTextField.text!.isEmpty == false){
            CustomSearchService.shared.callCustomSearchAPI(q: searchQueryTextField.text!) { (item, success) in
                if success {
                    self._items = item
                    DispatchQueue.main.async {
                        self.resultTableView.reloadData()
                    }
                }
                else {
                    print("No internet connection")
                }
            }
        }
    }
    
    
    
    // TableView Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomGoogleSearchTableViewCell", for: indexPath) as? CustomGoogleSearchTableViewCell
        {
            cell.linkLabel.text = _items?[indexPath.row].link ?? ""
            cell.titleLabel.text = _items?[indexPath.row].title ?? ""
            cell.snippetLabel.text = _items?[indexPath.row].snippet ?? ""
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped me")
        
        // To open a link in another view
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let webViewController = storyboard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.link = (_items?[indexPath.row].link)!
        webViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(webViewController, animated: true, completion: nil)
        
        // To open a link using phone's default browser
//        if let url = URL(string: (_items?[indexPath.row].link)!) {
//            UIApplication.shared.open(url)
//            let myRequest = URLRequest(url: url)
//            webView.load(myRequest)
//        }
//        else {
//            print("Invalid link")
//        }
    }
    
//    func tableView(_ tableView: UITableView,
//               heightForRowAt indexPath: IndexPath) -> CGFloat {
//       return UITableView.automaticDimension
//    }

}
