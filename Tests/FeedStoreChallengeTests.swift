//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {
	
	//  ***********************
	//
	//  Follow the TDD process:
	//
	//  1. Uncomment and run one test at a time (run tests with CMD+U).
	//  2. Do the minimum to make the test pass and commit.
	//  3. Refactor if needed and commit again.
	//
	//  Repeat this process until all tests are passing.
	//
	//  ***********************
	
	func test_retrieve_deliversEmptyOnEmptyCache() throws {
		let sut = try makeSUT()
		
		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnEmptyCache() throws {
		let sut = try makeSUT()

		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_retrieve_deliversFoundValuesOnNonEmptyCache() throws {
		let sut = try makeSUT()

		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() throws {
		let sut = try makeSUT()

		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnEmptyCache() throws {
		let sut = try makeSUT()

		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnNonEmptyCache() throws {
		let sut = try makeSUT()

		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_insert_overridesPreviouslyInsertedCacheValues() throws {
		let sut = try makeSUT()

		assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
	}
	
	func test_delete_deliversNoErrorOnEmptyCache() throws {
		let sut = try makeSUT()

		assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
	}
	
	func test_delete_hasNoSideEffectsOnEmptyCache() throws {
		let sut = try makeSUT()

		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_delete_deliversNoErrorOnNonEmptyCache() throws {
		let sut = try makeSUT()

		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_delete_emptiesPreviouslyInsertedCache() throws {
		let sut = try makeSUT()

		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}
	
	func test_storeSideEffects_runSerially() throws {
		let sut = try makeSUT()

		assertThatSideEffectsRunSerially(on: sut)
	}
	
	// - MARK: Helpers
	
	private func makeSUT() throws -> FeedStore {
		let bundle = Bundle(for: CoreDataFeedStore.self)
		let storeURL = URL(fileURLWithPath: artifactlessStoreURLPath)
		let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: bundle)
		trackMemoryLeaks(sut)
		return sut
	}
	
	private var artifactlessStoreURLPath: String {
		return "/dev/null"
	}
	
}

private extension FeedStoreChallengeTests {
	
	class Swizzler {
		private static func exchangeImplementations(
			of class1: AnyClass, method1: Selector,
			to class2: AnyClass, method2: Selector
		) {
			let originalMethod = class_getInstanceMethod(class1, method1)
			let swizzledMethod = class_getInstanceMethod(class2, method2)
			
			method_exchangeImplementations(originalMethod!, swizzledMethod!)
		}
		
		static func exchangeFetchImplementations() {
			exchangeImplementations(
				of: NSManagedObjectContext.self, method1: #selector(NSManagedObjectContext.fetch),
				to: Swizzler.self, method2: #selector(fetch)
			)
		}
		
		@objc
		private func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) throws -> [Any] {
			throw anyNSError()
		}
		
		private func anyNSError() -> NSError {
			return NSError(domain: "any error", code: 0)
		}
	}
}

extension FeedStoreChallengeTests: FailableRetrieveFeedStoreSpecs {

	func test_retrieve_deliversFailureOnRetrievalError() throws {
		let sut = try makeSUT()
		
		simulateContextResultFetchFailure()

		assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
		
		revertForcingResultFetchFailure()
	}

	func test_retrieve_hasNoSideEffectsOnFailure() throws {
//		let sut = try makeSUT()
//
//		assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
	}

	private func simulateContextResultFetchFailure() {
		Swizzler.exchangeFetchImplementations()
	}
	
	private func revertForcingResultFetchFailure() {
		Swizzler.exchangeFetchImplementations()
	}
}

//extension FeedStoreChallengeTests: FailableInsertFeedStoreSpecs {
//
//	func test_insert_deliversErrorOnInsertionError() throws {
////		let sut = try makeSUT()
////
////		assertThatInsertDeliversErrorOnInsertionError(on: sut)
//	}
//
//	func test_insert_hasNoSideEffectsOnInsertionError() throws {
////		let sut = try makeSUT()
////
////		assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
//	}
//
//}

//extension FeedStoreChallengeTests: FailableDeleteFeedStoreSpecs {
//
//	func test_delete_deliversErrorOnDeletionError() throws {
////		let sut = try makeSUT()
////
////		assertThatDeleteDeliversErrorOnDeletionError(on: sut)
//	}
//
//	func test_delete_hasNoSideEffectsOnDeletionError() throws {
////		let sut = try makeSUT()
////
////		assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
//	}
//
//}
