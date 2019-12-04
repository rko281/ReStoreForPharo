"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreRelatedObjectTest,
	#superclass : #SSWReStoreGenericObjectTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #accessing }
SSWReStoreRelatedObjectTest >> componentDefinition [

	^GenericOwnedTest related
]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testChangedObjectsComponentChange [

	| originalName changedName |

	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"A change to an object's component does not mark the owning object as changed"
	self assert: ((reStore selectChanged: (Array with: component)) asArray = (Array with: component)).
	self assert: ((reStore selectChanged: (Array with: testObject)) isEmpty).

	"...but does withRelatedComponents"
	self assert: ((reStore selectChanged: (Array with: testObject withRelatedComponents)) asArray = (Array with: component))
]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testChangedObjectsComponentChangeDeeply [

	| originalName changedName |

	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	"A change to an object's component does not mark the owning object as changed"
	component deepTest name: changedName.

	self assert: ((reStore selectChanged: (Array with: component deepTest)) asArray = (Array with: component deepTest)).
	self assert: ((reStore selectChanged: (Array with: component)) isEmpty).
	self assert: ((reStore selectChanged: (Array with: testObject)) isEmpty).

	"...but does withRelatedComponents"
	self assert: ((reStore selectChanged: (Array with: testObject withRelatedComponents)) asArray = (Array with: component deepTest)).
	self assert: ((reStore selectChanged: (Array with: component withRelatedComponents)) asArray = (Array with: component deepTest))
]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testChangedObjectsComponentChangeWithExclusion [

	| originalName changedName |

	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"A change to an object's component does not mark the owning object as changed"
	self assert: ((reStore selectChanged: (Array with: component)) asArray = (Array with: component)).
	self assert: ((reStore selectChanged: (Array with: testObject)) isEmpty).

	"Now check exclusion mechanism"
	self assert: ((reStore selectChanged: (Array with: (testObject withRelatedComponents without: component))) isEmpty)
]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testChangedObjectsComponentChangeWithExclusionDeeply [

	| originalName changedName |

	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	"A change to an object's component does not mark the owning object as changed"
	component deepTest name: changedName.

	self assert: ((reStore selectChanged: (Array with: component deepTest)) asArray = (Array with: component deepTest)).
	self assert: ((reStore selectChanged: (Array with: component)) isEmpty).
	self assert: ((reStore selectChanged: (Array with: testObject)) isEmpty).

	"...and also with exclusion mechanism"
	self assert: ((reStore selectChanged: (Array with: (testObject withRelatedComponents without: component))) isEmpty).
	self assert: ((reStore selectChanged: (Array with: (testObject withRelatedComponents without: component deepTest))) isEmpty).
	self assert: ((reStore selectChanged: (Array with: (testObject withRelatedComponents withoutAll: {component. component deepTest}))) isEmpty).
	self assert: ((reStore selectChanged: (Array with: (component withRelatedComponents without: component deepTest))) isEmpty).

	"Check exclusion only applies to deepTest"
	component name: changedName.
	self assert: ((reStore selectChanged: (Array with: (testObject withRelatedComponents without: component))) isEmpty).
	self assert: ((reStore selectChanged: (Array with: (testObject withRelatedComponents withoutAll: {component. component deepTest}))) isEmpty).
	self assert: ((reStore selectChanged: (Array with: (testObject withRelatedComponents without: component deepTest))) asArray = (Array with: component))
]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testCheckHasChangedComponentChange [

	| originalName changedName |

	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"A change to an object's component does not mark the owning object as changed"
	self assert: (reStore hasChanged: component).
	self deny: (reStore hasChanged: testObject).

	"...but does withRelatedComponents"
	self assert: (reStore hasChanged: testObject withRelatedComponents)
]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testCheckHasChangedComponentChangeDeeply [

	| originalName changedName |

	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	"A change to an object's component does not mark the owning object as changed"
	component deepTest name: changedName.
	self assert: (reStore hasChanged: component deepTest).
	self deny: (reStore hasChanged: component).
	self deny: (reStore hasChanged: testObject).

	"...but does withRelatedComponents"
	self assert: (reStore hasChanged: testObject withRelatedComponents).
	self assert: (reStore hasChanged: component withRelatedComponents)
]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testCheckHasChangedComponentChangeWithExclusion [

	| originalName changedName |

	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"A change to an object's component does not mark the owning object as changed"
	self assert: (reStore hasChanged: component).
	self deny: (reStore hasChanged: testObject).

	"Removing testObject from related components also ignores the change"
	self deny: (reStore hasChanged: (testObject withRelatedComponents without: component))
]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testCheckHasChangedComponentChangeWithExclusionDeeply [

	| originalName changedName |

	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	"A change to an object's component does not mark the owning object as changed"
	component deepTest name: changedName.
	self assert: (reStore hasChanged: component deepTest).
	self deny: (reStore hasChanged: component).
	self deny: (reStore hasChanged: testObject).

	"Check exclusion mechanism"
	self deny: (reStore hasChanged: (testObject withRelatedComponents without: component)).
	self deny: (reStore hasChanged: (testObject withRelatedComponents without: component deepTest)).
	self deny: (reStore hasChanged: (component withRelatedComponents without: component deepTest)).
	self deny: (reStore hasChanged: (testObject withRelatedComponents withoutAll: {component. component deepTest})).

	"Check intermediate level change"
	component name: (component name, '_changed').
	self deny: (reStore hasChanged: (testObject withRelatedComponents without: component)).
	self assert: (reStore hasChanged: (testObject withRelatedComponents without: component deepTest)).
	self assert: (reStore hasChanged: (component withRelatedComponents without: component deepTest)).
	self deny: (reStore hasChanged: (testObject withRelatedComponents withoutAll: {component. component deepTest})).

]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testCommitComponentChange [

	| originalName changedName |

	"Commit of just the owner does not commit the change to the component"
	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.
	reStore commit: testObject.
	self fetchTestObjects.
	self assert: (component name = originalName).

	"...but does withRelatedComponents"
	component name: changedName.
	reStore commit: testObject withRelatedComponents.
	self fetchTestObjects.
	self assert: (component name = changedName)

]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testCommitComponentChangeDeeply [

	| originalName changedName |

	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	"Commit of just the owner does not commit the change to the component"
	component deepTest name: changedName.
	reStore commit: testObject.
	self fetchTestObjects.
	self assert: (component deepTest name = originalName).

	"...but does withRelatedComponents"
	component deepTest name: changedName.
	reStore commit: testObject withRelatedComponents.
	self fetchTestObjects.
	self assert: (component deepTest name = changedName)

]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testCommitComponentChangeWithExclusion [

	| originalName changedName |

	"Commit of just the owner does not commit the change to the component"
	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.
	reStore commit: testObject.
	self fetchTestObjects.
	self assert: (component name = originalName).

	"...and also with exclusion"
	component name: changedName.
	reStore commit: (testObject withRelatedComponents without: component).
	self fetchTestObjects.
	self assert: (component name = originalName)
]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testCommitComponentChangeWithExclusionDeeply [

	| originalName changedName |

	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	"Commit of just the owner does not commit the change to the component"
	component deepTest name: changedName.
	reStore commit: testObject.
	self fetchTestObjects.
	self assert: (component deepTest name = originalName).

	"Also test with exclusions"
	component deepTest name: changedName.
	reStore commit: (testObject withRelatedComponents without: component).
	self fetchTestObjects.
	self assert: (component deepTest name = originalName).

	component deepTest name: changedName.
	reStore commit: (testObject withRelatedComponents without: component deepTest).
	self fetchTestObjects.
	self assert: (component deepTest name = originalName).

	component deepTest name: changedName.
	reStore commit: (testObject withRelatedComponents withoutAll: {component. component deepTest}).
	self fetchTestObjects.
	self assert: (component deepTest name = originalName)
]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testForceRefreshComponent [

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

	"...but does withRelatedComponents"
	reStore forceRefresh: testObject withRelatedComponents.
	self assert: (component name = changedName)

]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testForceRefreshComponentDeeply [

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

	"...but does withRelatedComponents"
	reStore forceRefresh: testObject withRelatedComponents.
	self assert: (component deepTest name = changedName)
]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testForceRefreshComponentWithExclusion [

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

	"Test exclusion mechanism"
	reStore forceRefresh: (testObject withRelatedComponents without: component).
	self assert: (component name = originalName)

]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testForceRefreshComponentWithExclusionDeeply [

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

	"Check exclusion mechanism"

	reStore forceRefresh: (testObject withRelatedComponents without: component).
	self assert: (component deepTest name = originalName).

	reStore forceRefresh: (testObject withRelatedComponents without: component deepTest).
	self assert: (component deepTest name = originalName).

	reStore forceRefresh: (testObject withRelatedComponents withoutAll: {component. component deepTest}).
	self assert: (component deepTest name = originalName).

	"Check intermediate exclusion"
	originalName := component name.
	changedName := originalName, '_changed'.
	reStore connection 
		beginRWTxn;
		exec: ('update <1S> set name = <2P> where name = <3P>' expandMacrosWith: (reStore tableForClass: component class) name with: changedName with: originalName);
		commitTxn.

	reStore forceRefresh: (testObject withRelatedComponents without: component).
	self assert: (component name = originalName).

	reStore forceRefresh: (testObject withRelatedComponents withoutAll: {component. component deepTest}).
	self assert: (component name = originalName).

	reStore forceRefresh: (testObject withRelatedComponents without: component deepTest).
	self assert: (component name = changedName).



]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testRefreshComponentIfUpdated [

	| originalName changedName |

	originalName := component name.
	changedName := originalName, '_changed'.
	
	"Update via reStore2 so versioning is respected"
	self setUpReStore2.
	reStore2 evaluateAsTransaction: [((reStore2 instancesOf: component class) satisfying: [ :each | each name = originalName]) modify: [ :each | each name: changedName]].
	self refreshDelay.

	"Ensure reStore wasn't affected"
	self assert: (component name = originalName).

	"Refresh of just the owner does not refresh the component"
	reStore refreshIfUpdated: testObject.
	self assert: (component name = originalName).

	"...but does withRelatedComponents"
	reStore refreshIfUpdated: testObject withRelatedComponents.
	self assert: (component name = changedName)

]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testRefreshComponentIfUpdatedDeeply [

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
	reStore refreshIfUpdated: testObject.
	self assert: (component deepTest name = originalName).

	"...but does withRelatedComponents"
	reStore refreshIfUpdated: testObject withRelatedComponents.
	self assert: (component deepTest name = changedName)
]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testRefreshComponentIfUpdatedWithExclusion [

	| originalName changedName |

	originalName := component name.
	changedName := originalName, '_changed'.
	
	"Update via reStore2 so versioning is respected"
	self setUpReStore2.
	reStore2 evaluateAsTransaction: [((reStore2 instancesOf: component class) satisfying: [ :each | each name = originalName]) modify: [ :each | each name: changedName]].
	self refreshDelay.

	"Ensure reStore wasn't affected"
	self assert: (component name = originalName).

	"Refresh of just the owner does not refresh the component"
	reStore refreshIfUpdated: testObject.
	self assert: (component name = originalName).

	"Test exclusion mechanism"
	reStore refreshIfUpdated: (testObject withRelatedComponents without: component).
	self assert: (component name = originalName)

]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testRefreshComponentIfUpdatedWithExclusionDeeply [

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
	reStore refreshIfUpdated: testObject.
	self assert: (component deepTest name = originalName).

	"Test exclusion mechanism"
	reStore refreshIfUpdated: (testObject withRelatedComponents without: component).
	self assert: (component deepTest name = originalName).

	reStore refreshIfUpdated: (testObject withRelatedComponents without: component deepTest).
	self assert: (component deepTest name = originalName).

	reStore refreshIfUpdated: (testObject withRelatedComponents withoutAll: {component. component deepTest}).
	self assert: (component deepTest name = originalName)
]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testRefreshIfUpdatedRollbackRemovedComponentChange [

	| originalName changedName |

	originalName := component name.
	changedName := originalName, '_changed'.

	"Update via reStore2 so versioning is respected"
	self setUpReStore2.
	reStore2 evaluateAsTransaction: 
		[| testObject2 |
		testObject2 := (reStore2 instancesOf: testObject class) detect: [ :each | each name = testObject name].
		testObject2 component name: changedName.
		testObject2 component: nil].

	self refreshDelay.

	reStore refreshIfUpdated: testObject withRelatedComponents.
	self assert: (component name = changedName)
]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testRefreshRemovedLocallyComponentChange [

	| originalName changedName |

	originalName := component name.
	changedName := originalName, '_changed'.

	"Update component in other session; remove component in this session"
	self setUpReStore2.
	reStore2 evaluateAsTransaction: 
		[| testObject2 |
		testObject2 := (reStore2 instancesOf: testObject class) detect: [ :each | each name = testObject name].
		testObject2 component name: changedName].
	testObject component: nil.

	self refreshDelay.

	"Verify local change undone and remote change picked up" 
	reStore refresh: testObject withRelatedComponents.
	self assert: (testObject component == component).
	self assert: (component name = changedName)

]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testRefreshRemovedLocallyComponentChangeWithExclusion [

	| originalName changedName |

	originalName := component name.
	changedName := originalName, '_changed'.

	"Update component in other session; remove component in this session"
	self setUpReStore2.
	reStore2 evaluateAsTransaction: 
		[| testObject2 |
		testObject2 := (reStore2 instancesOf: testObject class) detect: [ :each | each name = testObject name].
		testObject2 component name: changedName].
	testObject component: nil.

	self refreshDelay.

	"Verify local change undone, but exclusion should not refresh component" 
	reStore refresh: (testObject withRelatedComponents without: component).
	self assert: (testObject component == component).
	self assert: (component name = originalName)

]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testRefreshRollbackComponentChange [

	| originalName changedName |

	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"Refresh of just the owner does not revert the change to the component"
	reStore refresh: testObject.
	self assert: (component name = changedName).

	"...but does withRelatedComponents"
	reStore refresh: testObject withRelatedComponents.
	self assert: (component name = originalName)

]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testRefreshRollbackComponentChangeDeeply [

	| originalName changedName |

	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	"Refresh of just the owner does not revert the change to the component"
	component deepTest name: changedName.
	reStore refresh: testObject.
	self assert: (component deepTest name = changedName).

	"...but does withRelatedComponents"
	reStore refresh: testObject withRelatedComponents.
	self assert: (component deepTest name = originalName)

]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testRefreshRollbackComponentChangeIfUpdated [

	| originalName changedName changedName2 |

	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"Update via reStore2 so versioning is respected"
	changedName2 := originalName, '_changed2'.
	self setUpReStore2.
	reStore2 evaluateAsTransaction: [((reStore2 instancesOf: component class) satisfying: [ :each | each name = originalName]) modify: [ :each | each name: changedName2]].
	self refreshDelay.

	"Refresh of just the owner does not revert the change to the component"
	reStore refreshIfUpdated: testObject.
	self assert: (component name = changedName).

	"...but does withRelatedComponents"
	reStore refreshIfUpdated: testObject withRelatedComponents.
	self assert: (component name = changedName2).

]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testRefreshRollbackComponentChangeIfUpdatedDeeply [

	| originalName changedName changedName2 |

	originalName := 'deep test'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	changedName := originalName, '_changed'.
	component deepTest name: changedName.

	"Update via reStore2 so versioning is respected"
	changedName2 := originalName, '_changed2'.
	self setUpReStore2.
	reStore2 evaluateAsTransaction: [((reStore2 instancesOf: component deepTest class) satisfying: [ :each | each name = originalName]) modify: [ :each | each name: changedName2]].
	self refreshDelay.

	"Refresh of just the owner does not revert the change to the component"
	reStore refreshIfUpdated: testObject.
	self assert: (component deepTest name = changedName).

	"...but should now withRelatedComponents, since the underlying object is changed"
	reStore refreshIfUpdated: testObject withRelatedComponents.
	self assert: (component deepTest name = changedName2).


]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testRefreshRollbackComponentChangeIfUpdatedWithExclusion [

	| originalName changedName changedName2 |

	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"Update via reStore2 so versioning is respected"
	changedName2 := originalName, '_changed2'.
	self setUpReStore2.
	reStore2 evaluateAsTransaction: [((reStore2 instancesOf: component class) satisfying: [ :each | each name = originalName]) modify: [ :each | each name: changedName2]].
	self refreshDelay.

	"Refresh of just the owner does not revert the change to the component"
	reStore refreshIfUpdated: testObject.
	self assert: (component name = changedName).

	"Test exclusion mechanism"
	reStore refreshIfUpdated: (testObject withRelatedComponents without: component).
	self assert: (component name = changedName)
]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testRefreshRollbackComponentChangeIfUpdatedWithExclusionDeeply [

	| originalName changedName changedName2 |

	originalName := 'deep test'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	changedName := originalName, '_changed'.
	component deepTest name: changedName.

	"Update via reStore2 so versioning is respected"
	changedName2 := originalName, '_changed2'.
	self setUpReStore2.
	reStore2 evaluateAsTransaction: [((reStore2 instancesOf: component deepTest class) satisfying: [ :each | each name = originalName]) modify: [ :each | each name: changedName2]].
	self refreshDelay.

	"Refresh of just the owner does not revert the change to the component"
	reStore refreshIfUpdated: testObject.
	self assert: (component deepTest name = changedName).

	"Test exclusion mechanism"
	reStore refreshIfUpdated: (testObject withRelatedComponents without: component).
	self assert: (component deepTest name = changedName).

	reStore refreshIfUpdated: (testObject withRelatedComponents without: component deepTest).
	self assert: (component deepTest name = changedName).

	reStore refreshIfUpdated: (testObject withRelatedComponents withoutAll: {component. component deepTest}).
	self assert: (component deepTest name = changedName)
]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testRefreshRollbackComponentChangeWithExclusion [

	| originalName changedName |

	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"Refresh of just the owner does not revert the change to the component"
	reStore refresh: testObject.
	self assert: (component name = changedName).

	"Test exclusion mechanism"
	reStore refresh: (testObject withRelatedComponents without: component).
	self assert: (component name = changedName)

]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testRefreshRollbackComponentChangeWithExclusionDeeply [

	| originalName changedName |

	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	"Refresh of just the owner does not revert the change to the component"
	component deepTest name: changedName.
	reStore refresh: testObject.
	self assert: (component deepTest name = changedName).

	"Test exclusion mechanism"
	reStore refresh: (testObject withRelatedComponents without: component).
	self assert: (component deepTest name = changedName).

	reStore refresh: (testObject withRelatedComponents without: component deepTest).
	self assert: (component deepTest name = changedName).

	reStore refresh: (testObject withRelatedComponents withoutAll: {component. component deepTest}).
	self assert: (component deepTest name = changedName)
]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testRefreshRollbackRemovedComponentChange [

	| originalName changedName |

	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"Update via reStore2 so versioning is respected"
	self setUpReStore2.
	reStore2 evaluateAsTransaction: [((reStore2 instancesOf: testObject class) satisfying: [ :each | each name = testObject name]) modify: [ :each | each component: nil]].

	reStore refresh: testObject withRelatedComponents.
	self assert: (component name = originalName)

]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testRefreshRollbackRemovedComponentChangeWithExclusion [

	| originalName changedName |

	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"Update via reStore2 so versioning is respected"
	self setUpReStore2.
	reStore2 evaluateAsTransaction: [((reStore2 instancesOf: testObject class) satisfying: [ :each | each name = testObject name]) modify: [ :each | each component: nil]].

	reStore refresh: (testObject withRelatedComponents without: component).
	self assert: (component name = changedName)

]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testRollbackComponentChange [

	| originalName changedName |

	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"Rollback of just the owner does not revert the change to the component"
	reStore rollback: testObject.
	self assert: (component name = changedName).

	"...but does withRelatedComponents"
	reStore rollback: testObject withRelatedComponents.
	self assert: (component name = originalName)

]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testRollbackComponentChangeDeeply [

	| originalName changedName |

	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	"Rollback of just the owner does not revert the change to the component"
	component deepTest name: changedName.
	reStore rollback: testObject.
	self assert: (component deepTest name = changedName).

	"...but does withRelatedComponents"
	reStore rollback: testObject withRelatedComponents.
	self assert: (component deepTest name = originalName)

]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testRollbackComponentChangeWithExclusion [

	| originalName changedName |

	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"Rollback of just the owner does not revert the change to the component"
	reStore rollback: testObject.
	self assert: (component name = changedName).

	"Test exclusion mechanism"
	reStore rollback: (testObject withRelatedComponents without: component).
	self assert: (component name = changedName)

]

{ #category : #'unit tests' }
SSWReStoreRelatedObjectTest >> testRollbackComponentChangeWithExclusionDeeply [

	| originalName changedName |

	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	"Rollback of just the owner does not revert the change to the component"
	component deepTest name: changedName.
	reStore rollback: testObject.
	self assert: (component deepTest name = changedName).

	"Test exclusion mechanism"
	reStore rollback: (testObject withRelatedComponents without: component).
	self assert: (component deepTest name = changedName).

	reStore rollback: (testObject withRelatedComponents without: component deepTest).
	self assert: (component deepTest name = changedName).

	reStore rollback: (testObject withRelatedComponents withoutAll: {component. component deepTest}).
	self assert: (component deepTest name = changedName)
]
