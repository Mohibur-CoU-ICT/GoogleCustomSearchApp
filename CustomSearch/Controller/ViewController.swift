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
    var previousSearchQuery: String?
    var fetchStartIndex: Int = 1
    var onlineFatchStartPage: Int = 0
    var totalOnlinePages: Int = 0
    var totalRowsForSearchQuery: Int = 0
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // starting network monitoring
        NetworkMonitor.shared.startMonitoring()
        
        resultTableView.delegate = self
        resultTableView.dataSource = self
        searchQueryTextField.delegate = self
        
        // rename keyboard return key to google
        searchQueryTextField.returnKeyType = UIReturnKeyType.search
        
        // add a background to the footer stackview
        footerStackView.addBackground(color: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.3))
        
        // when app is launced previous and next button is disabled
        previousButton.isEnabled = false
        nextButton.isEnabled = false
        
        // hide keyboard when tapped outside of keyboard
        hideKeyboardWhenTappedAround()
    }
    
    
    // perform search when return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn() called\n")
        //textField code
        textField.resignFirstResponder()  //if desired
        self.searchButtonTapped((Any).self)
        return true
    }
    
    
    // call when search button is tapped
    @IBAction func searchButtonTapped(_ sender: Any) {
        searchQuery = searchQueryTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        print("Search button tapped with Query = \(searchQuery!)\n")
        if(searchQuery != nil && searchQuery?.isEmpty == false) {
            fetchStartIndex = 1
            if NetworkMonitor.shared.isReachable {
                onlineFatchStartPage = 0
                if searchQuery != previousSearchQuery {
                    previousSearchQuery = searchQuery
                    totalOnlinePages = 0
                    searchUtil(si: 1, num: 10)
                }
                else {
                    updateTableview()
                }
            }
            else {
                fetchItems()
            }
        }
    }
    
    
    // helper function to perform search
    func searchUtil(si: Int, num: Int) {
        print("searchUtil() called\n")
        var firstTimeRemoveSearchResults: Bool = true
        let dispatchGroup = DispatchGroup()
        var si: Int = si
        while si < 100 {
            dispatchGroup.enter()
            CustomSearchService.shared.callCustomSearchAPI(q: searchQuery ?? "", si: si, num: num) { (success) in
                if success {
                    if firstTimeRemoveSearchResults {
                        CustomSearchService.shared.customSearchResults = [CustomSearch](repeating: CustomSearch(), count: 10)
                        firstTimeRemoveSearchResults = false
                    }
                    dispatchGroup.leave()
                }
                else {
                    print("No internet connection or rate limit exceeded\n")
                    dispatchGroup.leave()
                }
            }
            si += 10
        }
        dispatchGroup.notify(queue: .main) {
            print("10 API call finished\n")
            self.updateTableview()
            self.insertIntoDatabase()
        }
    }
    
    
    func updateTableview() {
        print("updateTableview() called\n")
        _items.removeAll()
        for item in [CustomSearchService.shared.customSearchResults[onlineFatchStartPage]?.items] {
            if let eachItem = item {
                for index in 0..<eachItem.count {
                    let itemObj = Items()
                    itemObj.link = eachItem[index].link
                    itemObj.title = eachItem[index].title
                    itemObj.snippet = eachItem[index].snippet
                    _items.append(itemObj)
                }
            }
        }
        DispatchQueue.main.async {
            self.resultTableView.reloadData()
            self.updateMessages()
            print("Tableview updated for query=\(self.searchQuery!) from \(self.onlineFatchStartPage) th page.\n")
        }
    }
    
    
    // database methods
    
    // insert into database
    func insertIntoDatabase() {
        print("insertIntoDatabase() called\n")
        var firstTimeDelete: Bool = true
        var pageNo: Int = 0
        for customSearch in CustomSearchService.shared.customSearchResults {
            for item in [customSearch?.items] {
                if item?.count != nil && firstTimeDelete {
                    deleteItemsWithSearchQuery()
                    firstTimeDelete = false
                }
                if let eachItem = item {
                    print("eachItem.count = \(eachItem.count) for pageNo=\(pageNo)\n")
                    totalOnlinePages = max(totalOnlinePages, pageNo)
                    totalRowsForSearchQuery += eachItem.count
                    for index in 0..<eachItem.count {
                        let itemObj = All_Items(context: context)
                        itemObj.searchQuery = searchQuery
                        itemObj.link = eachItem[index].link
                        itemObj.title = eachItem[index].title
                        itemObj.snippet = eachItem[index].snippet
                        //itemObj.pagePath = ""
                    }
                    do {
                        try context.save()
                        print("\(eachItem.count) new items for \(searchQuery!) saved successfully\n")
                    }
                    catch {
                        print("Error in saving\n")
                    }
                }
                else {
                    print("item property is missing for query=\(searchQuery) for pageNo=\(pageNo)\n")
                }
            }
            pageNo += 1
        }
        print("Total pages found for search query = \(searchQuery) = \(totalOnlinePages)\n")
        print("After insertion totalRowsForSearchQuery = \(totalRowsForSearchQuery)\n")
    }
    
    
    // returns total number of items for a search query
    func totalItemsForSearchQuery() -> Int {
        print("totalItemsForSearchQuery() called\n")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "All_Items")
        fetchRequest.includesSubentities = false
        let pred = NSPredicate(format: "searchQuery == %@", searchQuery!)
        fetchRequest.predicate = pred
        
        var entitiesCount = 0
        do {
            entitiesCount = try context.count(for: fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)\n")
        }
        print("Total rows for \(searchQuery!) = \(entitiesCount)\n")
        totalRowsForSearchQuery = entitiesCount
        return entitiesCount
    }
    
    
    // to fetch items 10 by 10 for a search query
    func fetchItems() {
        print("fetchItems() called with fetchStartIndex = \(fetchStartIndex)\n")
        // Fetch the data from Core Data to display in the tableview
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "All_Items")
            // set the filtering on the request
            request.returnsObjectsAsFaults = false
            let pred = NSPredicate(format: "searchQuery == %@", searchQuery!)
            request.predicate = pred
            request.fetchOffset = fetchStartIndex - 1
            request.fetchLimit = 10
            
            let result = try context.fetch(request)
            
            // removing previous items and then appending new items
            _items.removeAll()
            
            for res in result as! [NSManagedObject] {
                let obj = Items()
                obj.title = res.value(forKey: "title") as? String
                obj.link = res.value(forKey: "link") as? String
                obj.snippet = res.value(forKey: "snippet") as? String
                _items.append(obj)
            }
            DispatchQueue.main.async {
                self.resultTableView.reloadData()
            }
        }
        catch {
            print("Error in fetchItems()\n")
            debugPrint(error)
        }
        // update messages after fetching
        self.updateMessages()
    }
    
    
    // delete records which has searchQuery equals to current search query
    func deleteItemsWithSearchQuery() {
        print("deleteItemsWithSearchQuery() called\n")
        let fetchRequest: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "All_Items")
        let pred = NSPredicate(format: "searchQuery == %@", searchQuery!)
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
            print("previous items of \(searchQuery!) deleted from database\n")
        }
        catch {
            print("Error in deleting items\n")
            debugPrint(error)
        }
    }
    
    
    // pagination methods
    @IBAction func nextButtonTapped(_ sender: Any) {
        print("nextButtonTapped() called\n")
        if NetworkMonitor.shared.isReachable {
            if onlineFatchStartPage < totalOnlinePages {
                onlineFatchStartPage += 1
                updateTableview()
                updateMessages()
            }
        }
        else {
            if fetchStartIndex + 10 <= 91 && fetchStartIndex + 10 <= totalRowsForSearchQuery {
                fetchStartIndex += 10
                fetchItems()
            }
        }
    }
    
    @IBAction func previousButtonTapped(_ sender: Any) {
        print("previousButtonTapped() called\n")
        if NetworkMonitor.shared.isReachable {
            if onlineFatchStartPage > 0 {
                onlineFatchStartPage -= 1
                updateTableview()
                updateMessages()
            }
        }
        else {
            if fetchStartIndex - 10 >= 1 {
                fetchStartIndex -= 10
                fetchItems()
            }
        }
    }
    
    
    // update messages
    func updateMessages() {
        print("updateMessages() called\n")
        updateTotalResultsMessage()
        updateButtonVisibility()
        updateNoSearchResultsMessage()
    }
    
    
    // function to update total results message
    func updateTotalResultsMessage() {
        print("updateTotalResultsMessage() called\n")
        var totalResultsMessage: String = ""
        if NetworkMonitor.shared.isReachable {
            if _items.count > 0 {
                totalResultsMessage = "About " + (CustomSearchService.shared.customSearchResults[onlineFatchStartPage]?.searchInformation?.formattedTotalResults ?? "") + " results ("
                totalResultsMessage += (CustomSearchService.shared.customSearchResults[onlineFatchStartPage]?.searchInformation?.formattedSearchTime ?? "") + " seconds)"
            }
        }
        else {
            let totalItemsForSearchQueryInDatabase: Int = totalItemsForSearchQuery()
            if totalItemsForSearchQueryInDatabase == 1 {
                totalResultsMessage = "1 result"
            }
            else if totalItemsForSearchQueryInDatabase > 1 {
                totalResultsMessage = "\(totalItemsForSearchQueryInDatabase) results"
            }
        }
        DispatchQueue.main.async {
            self.totalResultsLabel.text = totalResultsMessage
        }
    }
    
    
    // update button visibility
    func updateButtonVisibility() {
        print("updateButtonVisibility() called\n")
        DispatchQueue.main.async {
            if NetworkMonitor.shared.isReachable {
                self.previousButton.isEnabled = self.onlineFatchStartPage != 0
                self.nextButton.isEnabled = self.onlineFatchStartPage < self.totalOnlinePages
            }
            else {
                self.previousButton.isEnabled = self.fetchStartIndex != 1
                self.nextButton.isEnabled = self.fetchStartIndex+10 < self.totalRowsForSearchQuery
            }
        }
    }
    
    
    // update message of no search results
    func updateNoSearchResultsMessage() {
        print("updateNoSearchResultsMessage() called\n")
        if totalRowsForSearchQuery == 0 {
            var noDataMessage =
            "<html style='font-size:20px; font-family: Tahoma;'>"
            + "<div align='center'>"
                + "Your search - <b>" + (searchQuery ?? "") + "</b> - did not match any documents.<br><br>"
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
            
            if NetworkMonitor.shared.isReachable == false {
                noDataMessage = "<html style='font-size:20px;'><div align='center'>You are offline and no data<br>found for \(searchQuery ?? "") in the offline database.</div></html>"
            }
            
            DispatchQueue.main.async {
                let noDataLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.resultTableView.bounds.size.width, height: self.resultTableView.bounds.size.height))
                noDataLabel.numberOfLines = 0
                noDataLabel.textAlignment = NSTextAlignment.center
                noDataLabel.attributedText = noDataMessage.htmlToAttributedString
                self.resultTableView.backgroundView = noDataLabel
            }
        }
        else {
            // remove background message when there is data
            DispatchQueue.main.async {
                self.resultTableView.backgroundView = nil
            }
        }
    }
    
    
    // TableView methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // print("Total number of rows in table = \(self._items.count)\n")
        return _items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // print("cell for row at called with \(indexPath.row)\n")
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomGoogleSearchTableViewCell", for: indexPath) as? CustomGoogleSearchTableViewCell
        {
            cell.linkLabel.text = _items[indexPath.row].link ?? ""
            cell.titleLabel.text = _items[indexPath.row].title ?? ""
            cell.snippetLabel.text = _items[indexPath.row].snippet ?? ""
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // print("You tapped \(indexPath.row) th link\n")
        // To open a link in a webview
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let webViewController = storyboard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController._title = (_items[indexPath.row].title)!
        webViewController.link = (_items[indexPath.row].link)!
        webViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        present(webViewController, animated: true, completion: nil)
        // when back from webview deselect the row
        resultTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
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
