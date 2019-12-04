"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreNonRelatedObjectTest,
	#superclass : #SSWReStoreGenericObjectTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #accessing }
SSWReStoreNonRelatedObjectTest >> componentDefinition [

	^GenericOwnedTest
]

{ #category : #'unit tests' }
SSWReStoreNonRelatedObjectTest >> testChangedObjectsComponentChange [

	| originalName changedName |

	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"A change to an object's component does not mark the owning object as changed"
	self assert: ((reStore selectChanged: (Array with: component)) asArray = (Array with: component)).
	self assert: ((reStore selectChanged: (Array with: testObject)) isEmpty).

	"...even withRelatedComponents"
	self assert: ((reStore selectChanged: (Array with: testObject withRelatedComponents)) isEmpty).

	"...but does withComponents"
	self assert: ((reStore selectChanged: (Array with: testObject withComponents)) asArray = (Array with: component))
]

{ #category : #'unit tests' }
SSWReStoreNonRelatedObjectTest >> testChangedObjectsComponentChangeDeeply [

	| originalName changedName |

	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	"A change to an object's component does not mark the owning object as changed"
	component deepTest name: changedName.

	self assert: ((reStore selectChanged:  (Array with: component deepTest)) asArray = (Array with: component deepTest)).
	self assert: ((reStore selectChanged: (Array with: component)) isEmpty).
	self assert: ((reStore selectChanged: (Array with: testObject)) isEmpty).

	"...even withRelatedComponents"
	self assert: ((reStore selectChanged: (Array with: testObject withRelatedComponents)) isEmpty).

	"...but does withComponents"
	self assert: ((reStore selectChanged: (Array with: testObject withComponents)) asArray = (Array with: component deepTest))
]

{ #category : #'unit tests' }
SSWReStoreNonRelatedObjectTest >> testCheckHasChangedComponentChange [

	| originalName changedName |

	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"A change to an object's component does not mark the owning object as changed"
	self assert: (reStore hasChanged: component).
	self deny: (reStore hasChanged: testObject).

	"...even withRelatedComponents"
	self deny: (reStore hasChanged: testObject withRelatedComponents).

	"...but does withComponents"
	self assert: (reStore hasChanged: testObject withComponents)
]

{ #category : #'unit tests' }
SSWReStoreNonRelatedObjectTest >> testCheckHasChangedComponentChangeDeeply [

	| originalName changedName |

	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	"A change to an object's component does not mark the owning object as changed"
	component deepTest name: changedName.
	self assert: (reStore hasChanged: component deepTest).
	self deny: (reStore hasChanged: component).
	self deny: (reStore hasChanged: testObject).

	"...even withRelatedComponents"
	self deny: (reStore hasChanged: testObject withRelatedComponents).

	"...but does withComponents"
	self assert: (reStore hasChanged: testObject withComponents)
]

{ #category : #'unit tests' }
SSWReStoreNonRelatedObjectTest >> testCommitComponentChange [

	| originalName changedName |

	"Commit of just the owner does not commit the change to the component"
	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.
	reStore commit: testObject.
	self fetchTestObjects.
	self assert: (component name = originalName).

	"...even withRelatedComponents"
	component name: changedName.
	reStore commit: testObject withRelatedComponents.
	self fetchTestObjects.
	self assert: (component name = originalName).

	"...but does withComponents"
	component name: changedName.
	reStore commit: testObject withComponents.
	self fetchTestObjects.
	self assert: (component name = changedName)

]

{ #category : #'unit tests' }
SSWReStoreNonRelatedObjectTest >> testCommitComponentChangeDeeply [

	| originalName changedName |

	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	"Commit of just the owner does not commit the change to the component"
	component deepTest name: changedName.
	reStore commit: testObject.
	self fetchTestObjects.
	self assert: (component deepTest name = originalName).

	"...even withRelatedComponents"
	component deepTest name: changedName.
	reStore commit: testObject withRelatedComponents.
	self fetchTestObjects.
	self assert: (component deepTest name = originalName).

	"...but does withComponents"
	component deepTest name: changedName.
	reStore commit: testObject withComponents.
	self fetchTestObjects.
	self assert: (component deepTest name = changedName)


]

{ #category : #'unit tests' }
SSWReStoreNonRelatedObjectTest >> testForceRefreshComponent [

	| originalName changedName |

	originalName := component name.
	changedName := originalName, '_changed'.
	
	"Update via raw SQL leaving versioning unaffected - this means we need to use forceRefresh"
	reStore connection 
		beginRWTxn;
		exec: ('update <1S> set name = <2P> where name = <3P>' expandMacrosWith: (reStore tableForClass: component class) name with: changedName with: originalName);
		commitTxn.

	"Refresh of just the owner does not refresh the component"
	reStore forceRefresh: testObject.
	self assert: (component name = originalName).

	"...event withRelatedComponents"
	reStore forceRefresh: testObject withRelatedComponents.
	self assert: (component name = originalName).

	"...but does withComponents"
	reStore forceRefresh: testObject withComponents.
	self assert: (component name = changedName)

]

{ #category : #'unit tests' }
SSWReStoreNonRelatedObjectTest >> testForceRefreshComponentDeeply [

	| originalName changedName |

	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].
	
	"Update via raw SQL leaving versioning unaffected - this means we need to use forceRefresh"
	reStore connection 
		beginRWTxn;
		exec: ('update <1S> set name = <2P> where name = <3P>' expandMacrosWith: (reStore tableForClass: component deepTest class) name with: changedName with: originalName);
		commitTxn.

	"Refresh of just the owner does not refresh the component"
	reStore forceRefresh: testObject.
	self assert: (component deepTest name = originalName).

	"...event withRelatedComponents"
	reStore forceRefresh: testObject withRelatedComponents.
	self assert: (component deepTest name = originalName).

	"...but does withComponents"
	reStore forceRefresh: testObject withComponents.
	self assert: (component deepTest name = changedName)

]

{ #category : #'unit tests' }
SSWReStoreNonRelatedObjectTest >> testRefreshComponentIfUpdated [

	| originalName changedName |

	originalName := component name.
	changedName := originalName, '_changed'.
	
	"Update via reStore2 so versioning is respected"
	self setUpReStore2.
	reStore2 evaluateAsTransaction: [((reStore2 instancesOf: component class) satisfying: [ :each | each name = originalName]) modify: [ :each | each name: changedName]].
	self refreshDelay.

	"Ensure reStore wasn't affected"
	self assert: (component name = originalName).

	"...event withRelatedComponents"
	reStore refreshIfUpdated: testObject withRelatedComponents.
	self assert: (component name = originalName).

	"...but does withComponents"
	reStore refreshIfUpdated: testObject withComponents.
	self assert: (component name = changedName)

]

{ #category : #'unit tests' }
SSWReStoreNonRelatedObjectTest >> testRefreshComponentIfUpdatedDeeply [

	| originalName changedName |

	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].	

	"Update via reStore2 so versioning is respected"
	self setUpReStore2.
	reStore2 evaluateAsTransaction: [((reStore2 instancesOf: component deepTest class) satisfying: [ :each | each name = originalName]) modify: [ :each | each name: changedName]].
	self refreshDelay.

	"Ensure reStore wasn't affected"
	self assert: (component deepTest name = originalName).

	"Refresh of just the owner does not refresh the component"
	self refreshDelay.
	reStore refreshIfUpdated: testObject.
	self assert: (component deepTest name = originalName).

	"...event withRelatedComponents"
	reStore refreshIfUpdated: testObject withRelatedComponents.
	self assert: (component deepTest name = originalName).

	"...but does withComponents"
	reStore refreshIfUpdated: testObject withComponents.
	self assert: (component deepTest name = changedName)

]

{ #category : #'unit tests' }
SSWReStoreNonRelatedObjectTest >> testRollbackComponentChange [

	| originalName changedName |

	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"Rollback of just the owner does not revert the change to the component"
	reStore rollback: testObject.
	self assert: (component name = changedName).

	"...even withRelatedComponents"
	reStore rollback: testObject withRelatedComponents.
	self assert: (component name = changedName).

	"...but does withComponents"
	reStore rollback: testObject withComponents.
	self assert: (component name = originalName).
]

{ #category : #'unit tests' }
SSWReStoreNonRelatedObjectTest >> testRollbackComponentChangeDeeply [

	| originalName changedName |

	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	"Rollback of just the owner does not revert the change to the component"
	component deepTest name: changedName.
	reStore rollback: testObject.
	self assert: (component deepTest name = changedName).

	"...even withRelatedComponents"
	reStore rollback: testObject withRelatedComponents.
	self assert: (component deepTest name = changedName).

	"...but does withComponents"
	reStore rollback: testObject withComponents.
	self assert: (component deepTest name = originalName).
]
