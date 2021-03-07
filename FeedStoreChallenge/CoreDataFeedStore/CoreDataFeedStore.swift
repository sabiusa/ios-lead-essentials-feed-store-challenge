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
	private let context: NSManagedObjectContext
	
	public init(storeURL: URL, bundle: Bundle = .main) throws {
		container = try NSPersistentContainer.load(
			named: "CoreDataFeedStore",
			storeURL: storeURL,
			in: bundle
		)
		context = container.newBackgroundContext()
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		context.perform { [context] in
			do {
				try CoreDataFeed.fetchFirst(in: context).map(context.delete(_:))
				try context.save()
				completion(nil)
			} catch {
				context.rollback()
				completion(error)
			}
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		context.perform { [context] in
			do {
				try CoreDataFeed.freshInstance(
					from: feed,
					timestamp: timestamp,
					in: context
				)
				try context.save()
				completion(nil)
			} catch {
				context.rollback()
				completion(error)
			}
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		context.perform { [context] in
			do {
				if let feed = try CoreDataFeed.fetchFirst(in: context) {
					completion(.found(feed: feed.localFeed, timestamp: feed.timestamp))
				} else {
					completion(.empty)
				}
			} catch {
				completion(.failure(error))
			}
		}
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
	
	static func fromLocal(_ local: LocalFeedImage, in context: NSManagedObjectContext) -> CoreDataFeedImage {
		let image = CoreDataFeedImage(context: context)
		image.id = local.id
		image.imageDescription = local.description
		image.location = local.location
		image.url = local.url
		return image
	}
	
	func toLocal() -> LocalFeedImage {
		return LocalFeedImage(
			id: id,
			description: imageDescription,
			location: location,
			url: url
		)
	}
}

@objc(CoreDataFeed)
private class CoreDataFeed: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feedImages: NSOrderedSet
	
	var localFeed: [LocalFeedImage] {
		return feedImages
			.compactMap { $0 as? CoreDataFeedImage }
			.map { $0.toLocal() }
	}
	
	enum Error: Swift.Error {
		case missingEntityName
	}
	
	@discardableResult
	static func freshInstance(
		from feed: [LocalFeedImage],
		timestamp: Date,
		in context: NSManagedObjectContext
	) throws -> CoreDataFeed {
		try fetchFirst(in: context).map(context.delete(_:))
		let feedImages = feed.map { CoreDataFeedImage.fromLocal($0, in: context) }
		let coreDataFeed = CoreDataFeed(context: context)
		coreDataFeed.timestamp = timestamp
		coreDataFeed.feedImages = NSOrderedSet(array: feedImages)
		return coreDataFeed
	}
	
	static func fetchFirst(in context: NSManagedObjectContext) throws -> CoreDataFeed? {
		guard let name = CoreDataFeed.entity().name else {
			throw Error.missingEntityName
		}
		
		let request = NSFetchRequest<CoreDataFeed>(entityName: name)
		request.fetchBatchSize = 0
		request.returnsObjectsAsFaults = false
		return try context.fetch(request).first
	}
}
