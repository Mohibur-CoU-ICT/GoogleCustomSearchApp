//
//  ViewController.swift
//  Demo
//
//  Created by Brotecs Mac Mini on 12/7/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var helloWorld: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var clickHereButton: UIButton!
    
    @IBAction func clickHereButtonTapped(_ sender: UIButton) {
        print("Hello")
        if(helloWorld.isHidden == true){
            helloWorld.isHidden = false
        }
        else{
            helloWorld.isHidden = true
        }
    }
    
}

