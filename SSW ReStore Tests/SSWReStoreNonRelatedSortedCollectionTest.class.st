"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWReStoreNonRelatedSortedCollectionTest',
	#superclass : 'SSWReStoreGenericNonRelatedCollectionTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'accessing' }
SSWReStoreNonRelatedSortedCollectionTest >> componentDefinition [

	^SortedCollection of: GenericOwnedTest
]

{ #category : 'public' }
SSWReStoreNonRelatedSortedCollectionTest >> replaceInCollection: aCollection [

	^(aCollection remove: aCollection last) -> (aCollection add: self templateComponent)
]

{ #category : 'accessing' }
SSWReStoreNonRelatedSortedCollectionTest >> templateCollection [

	^SortedCollection 
		with: self templateComponent
		with: self templateComponent
		with: self templateComponent
]

{ #category : 'unit tests' }
SSWReStoreNonRelatedSortedCollectionTest >> testCollectionRefreshComponentChange [

	| component originalName changedName changedName2 |

	component := collection anyOne.
	originalName := component name.
	changedName := originalName, '_changed'.

	reStore2 evaluateAsTransaction: [((component class storedInstancesIn: reStore2) detect: [ :each | each name = originalName]) name: changedName].
	self refreshDelay.

	"The need to sort on the target class means we do a full recover instead of just refreshing the collection itself, i.e. no difference between refresh and refresh with components"
	reStore refresh: collection.
	self assert: (component name = changedName).

	changedName2 := originalName, '_changed2'.
	reStore2 evaluateAsTransaction: [((component class storedInstancesIn: reStore2) detect: [ :each | each name = changedName]) name: changedName2].
	self refreshDelay.

	reStore refresh: collection withComponents.
	self assert: (component name = changedName2)
]

{ #category : 'unit tests' }
SSWReStoreNonRelatedSortedCollectionTest >> testCollectionRefreshComponentChangeIfUpdated [

	| component originalName changedName changedName2 |

	component := collection anyOne.
	originalName := component name.
	changedName := originalName, '_changed'.

	reStore2 evaluateAsTransaction: [((component class storedInstancesIn: reStore2) detect: [ :each | each name = originalName]) name: changedName].
	self refreshDelay.

	"The need to sort on the target class means we do a full recover instead of just refreshing the collection itself, i.e. no difference between refresh and refresh with components"
	reStore refreshIfUpdated: collection.
	self assert: (component name = changedName).

	changedName2 := originalName, '_changed2'.
	reStore2 evaluateAsTransaction: [((component class storedInstancesIn: reStore2) detect: [ :each | each name = changedName]) name: changedName2].
	self refreshDelay.

	reStore refreshIfUpdated: collection withComponents.
	self assert: (component name = changedName2)
]
