"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreRelatedSortedCollectionTest,
	#superclass : #SSWReStoreGenericRelatedCollectionTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #accessing }
SSWReStoreRelatedSortedCollectionTest >> componentDefinition [

	^SortedCollection of: GenericOwnedTest related
]

{ #category : #public }
SSWReStoreRelatedSortedCollectionTest >> replaceInCollection: aCollection [

	^(aCollection remove: aCollection last) -> (aCollection add: self templateComponent)
]

{ #category : #accessing }
SSWReStoreRelatedSortedCollectionTest >> templateCollection [

	^SortedCollection 
		with: self templateComponent
		with: self templateComponent
		with: self templateComponent
]

{ #category : #'unit tests' }
SSWReStoreRelatedSortedCollectionTest >> testCollectionRefreshComponentChange [

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

	reStore refresh: collection withRelatedComponents.
	self assert: (component name = changedName2)
]

{ #category : #'unit tests' }
SSWReStoreRelatedSortedCollectionTest >> testCollectionRefreshComponentChangeIfUpdated [

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

	reStore refreshIfUpdated: collection withRelatedComponents.
	self assert: (component name = changedName2)
]

{ #category : #'unit tests' }
SSWReStoreRelatedSortedCollectionTest >> testCollectionRefreshRollbackComponentChange [

	| component originalName changedName |

	component := collection anyOne.
	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"The need to sort on the target class means we do a full recover instead of just refreshing the collection itself, i.e. no difference between refresh and refresh with components"
	reStore refresh: collection.
	self assert: (component name = originalName).

	"Should be identical withRelatedComponents"
	component name: changedName.
	reStore refresh: collection withRelatedComponents.
	self assert: (component name = originalName)

]
