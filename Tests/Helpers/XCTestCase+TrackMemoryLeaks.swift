//
//  XCTestCase+TrackMemoryLeaks.swift
//  Tests
//
//  Created by Saba Khutsishvili on 3/6/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

extension XCTestCase {
	
	func trackMemoryLeaks(
		_ instance: AnyObject,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(
				instance,
				"Instance should have been deallocated. Potential memory leak",
				file: file,
				line: line
			)
		}
	}
}
