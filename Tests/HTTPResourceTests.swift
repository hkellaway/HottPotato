//
//  HTTPResourceTests.swift
//  HottPotato
//
//  Created by Harlan Kellaway on 5/10/19.
//  Copyright © 2019 Harlan Kellaway. All rights reserved.
//

import XCTest
@testable import HottPotato

class HTTPResourceTests: XCTestCase {
    
    override func setUp() { }
    
    override func tearDown() { }
    
    func testComposeURL_shouldCombineBaseURLAndPath() {
        // given
        let baseURL = "https://test.com"
        let path = "/helloworld"
        let sut = HTTPResource<Int>(method: .GET, baseURL: baseURL, path: path)
        
        // when
        let url = sut.composeURL()
        
        // then
        XCTAssertEqual(url!.absoluteString, "https://test.com/helloworld")
    }
    
}
