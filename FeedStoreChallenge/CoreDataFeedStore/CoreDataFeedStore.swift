//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Saba Khutsishvili on 3/6/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

public class CoreDataFeedStore: FeedStore {
	
	public init() {
		
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.empty)
	}
}

@objc(CoreDataFeedImage)
private class CoreDataFeedImage: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var imageDescription: String?
	@NSManaged var location: String?
	@NSManaged var url: URL
	@NSManaged var feed: CoreDataFeed
}

@objc(CoreDataFeed)
private class CoreDataFeed: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feedImages: NSOrderedSet
}
