//
//  CustomSearchService.swift
//  CustomSearch
//
//  Created by Brotecs Mac Mini on 12/20/21.
//

import Foundation
import UIKit

class CustomSearchService {
    static let shared = CustomSearchService()
    var customSearchResults = [CustomSearch?](repeating: nil, count: 10)
    
    private init(){
        
    }
    
    func callCustomSearchAPI(q: String, si: Int, num: Int, completionHandler: @escaping (Bool) -> Void ) {
        print("callCustomSearchAPI() called with start=\(si), num=\(num)\n")
        // two keys [AIzaSyBnxPnj_0vwyaDW4Ka_pDRIyEjAy8-4YyA, AIzaSyBhDq-e6q0W3aImfJoaABG37vN-LVlx4J8]
        let urlString = "https://www.googleapis.com/customsearch/v1?key=AIzaSyBnxPnj_0vwyaDW4Ka_pDRIyEjAy8-4YyA&num=\(num)&cx=6e6d97019e0665110&start=\(si)&q=\(q)"
        
        if let escapedURLString = urlString.addingPercentEncoding(withAllowedCharacters: Foundation.CharacterSet.urlQueryAllowed), let url = URL(string: escapedURLString) {
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                print("\(si)th response = ", terminator: "")
                print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
                if error == nil && data != nil {
                    // Parse JSON
                    let decoder = JSONDecoder()
                    do {
                        let searchResult = try decoder.decode(CustomSearch.self, from: data!)
//                        print(searchResult)
                        self.customSearchResults[si/10] = searchResult
                        completionHandler(true)
                    }
                    catch {
                        print("Error in JSON parsing inside callCustomSearchAPI\n")
                        completionHandler(false)
                    }
                }
                else {
                    print("Found error response from API\n")
                    completionHandler(false)
                }
            })
            
            task.resume()
        }
        else {
            print("Error in api url\n")
        }
    }
}
