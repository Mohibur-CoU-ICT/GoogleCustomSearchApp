//
//  CustomSearchService.swift
//  CustomSearch
//
//  Created by Brotecs Mac Mini on 12/20/21.
//

import Foundation

class CustomSearchService {
    static let shared = CustomSearchService()
    
    private init(){
        
    }
    
    func callCustomSearchAPI(q: String, completionHandler: @escaping ( [Items], Bool) -> Void ) {
        let ac = CharacterSet.urlQueryAllowed
        print(ac)
        let urlString =  "https://www.googleapis.com/customsearch/v1?key=AIzaSyBhDq-e6q0W3aImfJoaABG37vN-LVlx4J8&cx=6e6d97019e0665110&q=\(q)"
        if let escapedURLString = urlString.addingPercentEncoding(withAllowedCharacters: Foundation.CharacterSet.urlQueryAllowed), let url = URL(string: escapedURLString) {
            
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
                        
                        completionHandler(searchResult.items ?? [], true)
                    }
                    catch {
                        print("Error in JSON parsing")
                    }
                }
                else{
                    completionHandler([], false)
                }
            })
            
            task.resume()
        }
        else {
            print("errr occured")
        }
    }
}
