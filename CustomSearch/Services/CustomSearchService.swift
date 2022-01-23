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
    var customSearch = CustomSearch()
    
    private init(){
        
    }
    
    func callCustomSearchAPI(q: String, si: Int, num: Int, completionHandler: @escaping (Bool) -> Void ) {
        print("callCustomSearchAPI() called with start=\(si), num=\(num)\n")
        let urlString = "https://www.googleapis.com/customsearch/v1?key=AIzaSyBhDq-e6q0W3aImfJoaABG37vN-LVlx4J8&num=\(num)&cx=6e6d97019e0665110&start=\(si)&q=\(q)"
        
        if let escapedURLString = urlString.addingPercentEncoding(withAllowedCharacters: Foundation.CharacterSet.urlQueryAllowed), let url = URL(string: escapedURLString) {
            
//            DispatchQueue.global(qos: .userInitiated).async {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
//                print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
                if error == nil && data != nil {
                    // Parse JSON
                    let decoder = JSONDecoder()
                    do {
                        let searchResult = try decoder.decode(CustomSearch.self, from: data!)
//                        print(searchResult)
                        self.customSearch = searchResult
                        completionHandler(true)
                    }
                    catch {
                        debugPrint(error)
                        print("Error in JSON parsing inside callCustomSearchAPI\n")
                    }
                }
                else{
                    completionHandler(false)
                }
            })
            
            task.resume()
//            }
        }
        else {
            print("Error in api url\n")
        }
    }
}
