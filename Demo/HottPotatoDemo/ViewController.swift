//
//  ViewController.swift
//  HottPotatoDemo
//
//  Created by Harlan Kellaway on 5/10/19.
//  Copyright © 2019 Harlan Kellaway. All rights reserved.
//

import HottPotato
import UIKit

class ViewController: UIViewController {
    
    var httpClient = HottPotato.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let resource = HTTPResource<GitHubProfile>(
            method: .GET,
            baseURL: "https://api.github.com",
            path: "/users/hkellaway"
        )
        
        httpClient.sendRequest(for: resource) { result in
            switch result {
            case .success(let profile):
                print("Hello world from \(profile.login)")
            case .failure(let error):
                print("Goodbye world: \(error.localizedDescription)")
            }
        }
    }


}

