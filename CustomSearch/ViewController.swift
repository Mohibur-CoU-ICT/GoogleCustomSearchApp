//
//  ViewController.swift
//  CustomSearch
//
//  Created by Brotecs Mac Mini on 12/14/21.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var searchQueryTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    var _items: [Items]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        resultTableView.delegate = self
        resultTableView.dataSource = self
        //searchButton.addTarget(self, action: #selector(self.onTap(_:)), for: .touchUpInside)
    }
    
    
    func jsonToString(json: AnyObject){
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            print(convertedString!) // <-- here is ur string
            
        } catch let myJSONError {
            print(myJSONError)
        }
        
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
//                        //                        var i = 0
//                        //                        for it in _items {
//                        //                            resultTableView.insertRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
//                        //                            i++
//                        //                        }
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
        if(searchQueryTextField.text!.isEmpty == false){
            let url = URL(string: "https://www.googleapis.com/customsearch/v1?key=AIzaSyBhDq-e6q0W3aImfJoaABG37vN-LVlx4J8&cx=6e6d97019e0665110&q=\(String(describing: searchQueryTextField.text!)))")!
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                // print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
                if error == nil && data != nil {
                    // Parse JSON
                    let decoder = JSONDecoder()
                    do {
                        let searchResult = try decoder.decode(CustomSearch.self, from: data!)
                        print(searchResult)
                        self._items = searchResult.items
                        
                        //                        var i = 0
                        //                        for it in _items {
                        //                            resultTableView.insertRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
                        //                            i++
                        //                        }
                        DispatchQueue.main.async {
                            self.resultTableView.reloadData()
                        }
                    }
                    catch {
                        print("Error in JSON parsing")
                    }
                }
            })
            
            task.resume()
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = _items?[indexPath.row].link ?? ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped me")
    }
}
