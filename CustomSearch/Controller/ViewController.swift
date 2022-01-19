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
    @IBOutlet weak var totalResultsLabel: UILabel!
    @IBOutlet weak var footerStackView: UIStackView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    var _items = [Items]()
    var webView: WKWebView!
    var searchQuery: String?
    var fetchStartIndex: Int = 1
    var totalRowsForSearchQuery: Int = 0
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // starting network monitoring
        NetworkMonitor.shared.startMonitoring()
        
        self.resultTableView.delegate = self
        self.resultTableView.dataSource = self
        self.searchQueryTextField.delegate = self
        
        // rename keyboard return key to google
        self.searchQueryTextField.returnKeyType = UIReturnKeyType.search
        
        // add a background to the footer stackview
        self.footerStackView.addBackground(color: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.3))
        
        // when app is launced previous and next button is disabled
        self.previousButton.isEnabled = false
        self.nextButton.isEnabled = false
        
        // hide keyboard when tapped outside of keyboard
        self.hideKeyboardWhenTappedAround()
        
        // searchButton.addTarget(self, action: #selector(self.onTap(_:)), for: .touchUpInside)
    }
    
    
    // perform search when return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textField code
        textField.resignFirstResponder()  //if desired
        self.searchButtonTapped((Any).self)
        return true
    }
    
    
    // call when search button is tapped
    @IBAction func searchButtonTapped(_ sender: Any) {
        self.searchQuery = searchQueryTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        // print("Query = \(searchQuery!)\n")
        if(self.searchQuery != nil && self.searchQuery?.isEmpty == false) {
            self.fetchStartIndex = 1
            self.searchUtil(si: 1, num: 10)
            self.fetchItems()
        }
    }
    
    
    // helper function to perform search
    func searchUtil(si: Int, num: Int) {
        var firstTime: Bool = true
        var si: Int = si
        while si < 100 {
            print("callCustomSearchAPI() called with start=\(si), num=\(num)\n")
            CustomSearchService.shared.callCustomSearchAPI(q: self.searchQuery ?? "", si: si, num: num) { (success) in
                if success {
                    if firstTime {
                        self.deleteItemsWithSearchQuery()
                        firstTime = false
                    }
                    for item in [CustomSearchService.shared.customSearch.items] {
                        print("item.count = \(item?.count ?? -1)\n")
                        if let eachItem = item {
                            print("eachItem.count = \(eachItem.count)\n")
                            for index in 0..<eachItem.count {
                                let itemObj = All_Items(context: self.context)
                                itemObj.searchQuery = self.searchQuery
                                itemObj.link = eachItem[index].link
                                itemObj.title = eachItem[index].title
                                itemObj.snippet = eachItem[index].snippet
                                //itemObj.pageContent = ""
                            }
                            do {
                                try self.context.save()
                                print("\(eachItem.count) new items for \(self.searchQuery!) saved successfully\n")
                            }
                            catch {
                                print("Error in saving\n")
                            }
                        }
                    }
                }
                else {
                    print("No internet connection\n")
                }
            }
            si += 10
        }
    }
    
    
    // database methods
    
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
            print("error executing fetch request: \(error)\n")
        }
        print("Total rows for \(self.searchQuery!) = \(entitiesCount)\n")
        self.totalRowsForSearchQuery = entitiesCount
        return entitiesCount
    }
    
    
    // to fetch items 10 by 10 for a search query
    func fetchItems() {
        print("fetchItems() called with fetchStartIndex = \(self.fetchStartIndex)\n")
        // Fetch the data from Core Data to display in the tableview
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "All_Items")
            // set the filtering on the request
            request.returnsObjectsAsFaults = false
            let pred = NSPredicate(format: "searchQuery == %@", self.searchQuery!)
            request.predicate = pred
            request.fetchOffset = self.fetchStartIndex - 1
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
            print("Error in fetchItems()\n")
            debugPrint(error)
        }
        self.updateTotalResultsMessage()
        self.updateButtonVisibility()
        self.updateNoSearchResultsMessage()
    }
    
    
    // delete records which has searchQuery equals to current search query
    func deleteItemsWithSearchQuery() {
        print("deleteItemsWithSearchQuery() called\n")
        let fetchRequest: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "All_Items")
        let pred = NSPredicate(format: "searchQuery == %@", self.searchQuery!)
        fetchRequest.predicate = pred
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            // perform the batch delete
            let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
            guard let deleteResult = result?.result as? [NSManagedObjectID] else {
                return
            }
            let deletedObjects: [AnyHashable: Any] = [
                NSDeletedObjectsKey: deleteResult
            ]
            // Merge the delete changes into the managed object context
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: deletedObjects,
                into: [context]
            )
            print("previous items of \(self.searchQuery!) deleted from database\n")
        }
        catch {
            print("Error in deleting items\n")
            debugPrint(error)
        }
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
    
    
    // function to update total results message
    func updateTotalResultsMessage() {
        print("updateTotalResultsMessage() called\n")
        let totalItemsForSearchQueryInDatabase: Int = self.totalItemsForSearchQuery()
        var totalResultsMessage: String = ""
        if totalItemsForSearchQueryInDatabase == 1 {
            totalResultsMessage = "1 result"
        }
        else if totalItemsForSearchQueryInDatabase > 1 {
            totalResultsMessage = "\(totalItemsForSearchQueryInDatabase) results"
        }
        DispatchQueue.main.async {
            self.totalResultsLabel.text = totalResultsMessage
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
        // print("Total number of rows in table = \(self._items.count)\n")
        return self._items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // print("cell for row at called with \(indexPath.row)\n")
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
        // print("You tapped \(indexPath.row) th link\n")
        // To open a link in a webview
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let webViewController = storyboard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.link = (_items[indexPath.row].link)!
        webViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(webViewController, animated: true, completion: nil)
        // when back from webview deselect the row
        self.resultTableView.deselectRow(at: indexPath, animated: true)
        
        // Save web page content to database
        let myURLString = webViewController.link
        guard let myURL = URL(string: myURLString) else {
            print("Error: \(myURLString) doesn't seem to be a valid URL\n")
            return
        }

        do {
            let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
//            print("WebPage content = \n \(myHTMLString)\n")
            
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

// to enable html formated string in label
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
