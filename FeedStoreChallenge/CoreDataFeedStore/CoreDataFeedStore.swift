//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Saba Khutsishvili on 3/6/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

public class CoreDataFeedStore: FeedStore {
	private let container: NSPersistentContainer
	
	public init(storeURL: URL, bundle: Bundle = .main) throws {
		container = try NSPersistentContainer.load(
			named: "\(CoreDataFeedStore.self)",
			storeURL: storeURL,
			in: bundle
		)
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.empty)
	}
}

private extension NSPersistentContainer {
	
	enum LoadError: Error {
		case loadManagedObjectModel
		case loadPersistentStores(Error)
	}
	
	static func load(
		named name: String,
		storeURL: URL,
		in bundle: Bundle
	) throws -> NSPersistentContainer {
		guard let model = NSManagedObjectModel.load(named: name, in: bundle) else {
			throw LoadError.loadManagedObjectModel
		}
		
		let container = NSPersistentContainer(name: name, managedObjectModel: model)
		container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]

		var loadError: Error?
		container.loadPersistentStores { _, error in
			 loadError = error
		}
		if let error = loadError {
			throw LoadError.loadPersistentStores(error)
		}

		return container
	}
}

private extension NSManagedObjectModel {
	
	static func load(named name: String, in bundle: Bundle) -> NSManagedObjectModel? {
		guard let url = bundle.url(forResource: name, withExtension: "momd") else {
			return nil
		}
		
		return NSManagedObjectModel(contentsOf: url)
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
