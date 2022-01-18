//
//  ViewController.swift
//  CustomSearch
//
//  Created by Brotecs Mac Mini on 12/14/21.
//

import UIKit
import WebKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var searchQueryTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var footerStackView: UIStackView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    var _items = [Items]()
    var webView: WKWebView!
    var searchQuery: String?
    var previousSearchQuery: String?
    var fetchStartIndex: Int = 1
    var totalRowsForSearchQuery: Int = 0
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // starting network monitoring
        DispatchQueue.main.async {
            NetworkMonitor.shared.startMonitoring()
        }
        self.resultTableView.delegate = self
        self.resultTableView.dataSource = self
        self.searchQueryTextField.delegate = self
        
        self.footerStackView.addBackground(color: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.3))
        
        // when app is launced previous and next button is disabled
        self.previousButton.isEnabled = false
        self.nextButton.isEnabled = false
        
        // hide keyboard when tapped outside of keyboard
        self.hideKeyboardWhenTappedAround()
        
        // searchButton.addTarget(self, action: #selector(self.onTap(_:)), for: .touchUpInside)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textField code
        textField.resignFirstResponder()  //if desired
        self.searchButtonTapped((Any).self)
        return true
    }
    
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        self.searchQuery = searchQueryTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        // print("Query = \(searchQuery!)")
        if(self.searchQuery?.isEmpty == false && self.searchQuery != nil) {
            if self.searchQuery != self.previousSearchQuery {
                self.fetchStartIndex = 1
            }
            searchUtil()
            self.previousSearchQuery = self.searchQuery
        }
    }
    
    
    func searchUtil() {
        print("\nsearchUtil called with \(searchQueryTextField.text!)")
        var startIndex: Int = self.totalItemsForSearchQuery()
        var firstTime: Bool = true
        while startIndex < 100 {
            CustomSearchService.shared.callCustomSearchAPI(q: self.searchQuery ?? "", si: startIndex) { (success) in
                if success {
                    for item in [CustomSearchService.shared.customSearch.items] {
                        if let eachItem = item {
                            for index in 0..<eachItem.count {
                                let itemObj = All_Items(context: self.context)
                                itemObj.searchQuery = self.searchQuery
                                itemObj.link = eachItem[index].link
                                itemObj.title = eachItem[index].title
                                itemObj.snippet = eachItem[index].snippet
                                do {
                                    try self.context.save()
                                    // print("\(startIndex+index) th item Saved successfully")
                                }
                                catch {
                                    print("Error in saving")
                                }
                            }
                        }
                    }
                    if firstTime {
                        self.fetchItems()
                        DispatchQueue.main.async {
                            self.resultTableView.reloadData()
                        }
                        firstTime = false
                    }
                }
                else {
                    print("No internet connection")
                }
            }
            startIndex += 10
        }
        if firstTime {
            self.fetchItems()
            DispatchQueue.main.async {
                self.resultTableView.reloadData()
            }
        }
    }
    
    
    // returns total number of items for a search query
    func totalItemsForSearchQuery() -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "All_Items")
        fetchRequest.includesSubentities = false
        let pred = NSPredicate(format: "searchQuery == %@", self.searchQuery!)
        fetchRequest.predicate = pred
        
        var entitiesCount = 0
        do {
            entitiesCount = try context.count(for: fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        print("Total rows for \(self.searchQuery!) = \(entitiesCount)")
        self.totalRowsForSearchQuery = entitiesCount
        return entitiesCount
    }
    
    
    // to fetch items 10 by 10 for a search query
    func fetchItems() {
        print("fetchItems() called with fetchStartIndex = \(self.fetchStartIndex)")
        // Fetch the data from Core Data to display in the tableview
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "All_Items")
            // set the filtering on the request
            request.returnsObjectsAsFaults = false
            let pred = NSPredicate(format: "searchQuery == %@", self.searchQuery!)
            request.predicate = pred
            request.fetchOffset = self.fetchStartIndex
            request.fetchLimit = 10
            
            let result = try context.fetch(request)
            
            self._items.removeAll()
            for res in result as! [NSManagedObject] {
                let obj = Items()
                obj.title = res.value(forKey: "title") as? String
                obj.link = res.value(forKey: "link") as? String
                obj.snippet = res.value(forKey: "snippet") as? String
                self._items.append(obj)
            }
            DispatchQueue.main.async {
                self.resultTableView.reloadData()
            }
        }
        catch {
            print("Error in fetchItems(): " + error.localizedDescription)
        }
        updateButtonVisibility()
        updateNoSearchResultsMessage()
    }
    
    
    // pagination methods
    @IBAction func nextButtonTapped(_ sender: Any) {
        if self.fetchStartIndex + 10 <= 91 && self.fetchStartIndex + 10 <= self.totalRowsForSearchQuery {
            self.fetchStartIndex += 10
            fetchItems()
        }
    }
    
    @IBAction func previousButtonTapped(_ sender: Any) {
        if self.fetchStartIndex - 10 >= 1 {
            self.fetchStartIndex -= 10
            fetchItems()
        }
    }
    
    
    // update button visibility
    func updateButtonVisibility() {
        DispatchQueue.main.async {
            self.previousButton.isEnabled = self.fetchStartIndex != 1
            self.nextButton.isEnabled = self.fetchStartIndex+10 < self.totalRowsForSearchQuery
        }
    }
    
    
    // update message of no search results
    func updateNoSearchResultsMessage() {
        var noDataMessage =
        "<html style='font-size:20px; font-family: Tahoma;'>"
        + "<div align='center'>"
            + "Your search - <b>" + (self.searchQuery ?? "") + "</b> - did not match any documents.<br><br>"
            + "<div align='left'>"
            + "<p>&nbsp;&nbsp;Suggestions:</p>"
            + "<ul>"
                + "<li>Make sure that all words are spelled correctly.</li>"
                + "<li>Try different keywords.</li>"
                + "<li>Try more general keywords.</li>"
                + "<li>Try fewer keywords.</li>"
            + "</ul>"
            + "</div>"
        + "<div>"
        + "</html>"
        
        if self.totalRowsForSearchQuery == 0 {
            if NetworkMonitor.shared.isReachable == false {
                noDataMessage = "<html style='font-size:20px;'><div align='center'>You are offline and no data<br>found in the offline database.</div></html>"
            }
            DispatchQueue.main.async {
                let noDataLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.resultTableView.bounds.size.width, height: self.resultTableView.bounds.size.height))
//                noDataLabel.text          = noDataMessage
                noDataLabel.numberOfLines = 0
                noDataLabel.textAlignment = NSTextAlignment.center
                noDataLabel.attributedText = noDataMessage.htmlToAttributedString
                self.resultTableView.backgroundView = noDataLabel
            }
        }
    }
    
    
    // TableView methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // print("Total number of rows in table = \(self._items.count)")
        return self._items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // print("cell for row at called with \(indexPath.row)")
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomGoogleSearchTableViewCell", for: indexPath) as? CustomGoogleSearchTableViewCell
        {
            cell.linkLabel.text = self._items[indexPath.row].link ?? ""
            cell.titleLabel.text = self._items[indexPath.row].title ?? ""
            cell.snippetLabel.text = self._items[indexPath.row].snippet ?? ""
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // print("You tapped \(indexPath.row) th link")
        // To open a link in another view
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let webViewController = storyboard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.link = (_items[indexPath.row].link)!
        webViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(webViewController, animated: true, completion: nil)
        self.resultTableView.deselectRow(at: indexPath, animated: true)
        
        // Save web page content to database
        let myURLString = webViewController.link
        guard let myURL = URL(string: myURLString) else {
            print("Error: \(myURLString) doesn't seem to be a valid URL")
            return
        }

        do {
            let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
//            print("WebPage content = \n \(myHTMLString)")
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "All_Items")
            // set the filtering on the request
            request.returnsObjectsAsFaults = false
            let pred = NSPredicate(format: "link == %@", myURLString)
            request.predicate = pred
            
            let results = try context.fetch(request)
            if (results.count > 0) {
                let update = results[0] as! NSManagedObject
                update.setValue(myHTMLString, forKey: "pageContent")
                try context.save()
            }
        } catch let error {
            debugPrint(error)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    //    func tableView(_ tableView: UITableView,
    //               heightForRowAt indexPath: IndexPath) -> CGFloat {
    //       return UITableView.automaticDimension
    //    }
    
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

// to hide the keyboard when touch outside the keyboard
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
