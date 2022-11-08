"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWDBCachingObjectProxy,
	#superclass : #SSWDBObjectProxy,
	#instVars : [
		'copyObject'
	],
	#category : #'SSW ReStore Main'
}

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _acquireCopyObject [

	copyObject := self _dbTable copyForProxy: proxiedObject
]

{ #category : #testing }
SSWDBCachingObjectProxy >> _checkHasChanged [

	"Use the copy object to determine these"
	
	^self _isDeleted or:
		[self _isNew or: 
			[self _dbTable dataFields anySatisfy:
				[ :field || accessor current |
				accessor := field accessor.
				current := accessor valueIn: proxiedObject.
				current _hasChangedFrom: (accessor valueIn: copyObject)]]]
]

{ #category : #accessing }
SSWDBCachingObjectProxy >> _copyObject [

	"The receiver automatically detects changes to its proxiedObject by maintaining a shallow copy
	of the proxiedObject. This is held in copyObject"
	
	^copyObject
]

{ #category : #accessing }
SSWDBCachingObjectProxy >> _copyObject: anObject [

	"The receiver automatically detects changes to its proxiedObject by maintaining a shallow copy
	of the proxiedObject. This is held in copyObject"
	
	copyObject := anObject
]

{ #category : #'accessing:derived' }
SSWDBCachingObjectProxy >> _fieldUpdates [

	"Use the copy object to determine these"
	
	^self _dbTable dataFields inject: SSWSQLFieldAssignmentCollection new into: 
		[ :updates :field || accessor current |
		accessor := field accessor.
		current := accessor valueIn: proxiedObject.
		(current _hasChangedFrom: (accessor valueIn: copyObject)) ifTrue: 
			[updates add: (SSWSQLFieldAssignment field: field value: current)].
		updates]
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _forgetProxiedObject [

	"Override to reset the copyObject"
	
	copyObject := nil.
	^super _forgetProxiedObject
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _matchStateOf: aProxy [

	"Match the internal proxy (non data) state of aProxy"

	^self
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _postCommitStore [

	super _postCommitStore.
	self _acquireCopyObject
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _postCommitUpdates [

	| updates |

	updates := self _fieldUpdates.
	
	updates isEmpty ifFalse: [updates copyTo: copyObject]
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _prepareToCommit [

	"Intercept to check for overwriten dependent objects - unstore these (issue#0006)"

	(self _isPersistent and: [self _isDeleted not]) ifTrue:
		[| replacedDependentFields |
		replacedDependentFields := self _dbTable dependentDataFieldsSelect:
			[ :field | (field accessor valueIn: proxiedObject) ~~ (field accessor valueIn: copyObject)].
		replacedDependentFields isEmpty ifFalse:
			[| heldObjects |
			"Only delete replaced dependent objects if they are not held elsewhere in proxiedObject"
			heldObjects := self _dbTable dataFields collect: [ :field | field accessor valueIn: proxiedObject].
			replacedDependentFields do: 
				[ :field | 
				(heldObjects identityIncludes: (field accessor valueIn: copyObject)) ifFalse:
					[(field accessor valueIn: copyObject) unstore]]]].

	^super _prepareToCommit
]

{ #category : #accessing }
SSWDBCachingObjectProxy >> _proxiedObject: anObject [

	"Overriden to set the copyObject"
	
	super _proxiedObject: anObject.
	self _acquireCopyObject
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _recoverProxiedObject [

	"Override to check for deleted status"
	
	self _isDeleted ifTrue: [nil error: 'Attempt to reference deleted persistent object'].
	
	super _recoverProxiedObject
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _refreshAndRollforward [

	"Apply the changes made to the receiver to the current representation in the DB.
	Return a Boolean indicating if the receiver should be re-commited"

	| currentProxy |

	currentProxy := self _currentVersion.

	^(self _refreshAndRollforwardFrom: currentProxy)
		ifTrue: [self _matchStateOf: currentProxy. true]
		ifFalse: [false]
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _refreshAndRollforwardFrom: currentProxyObject [

	"Update the receiver such that it is based on the state of currentProxyObject
	with its own changes (compared to copyObject) applied on top.
	Return a Boolean indicating if the receiver should be re-commited"

	| currentObject |

	currentObject := currentProxyObject _proxiedObject.

	^self _isDeleted
	ifTrue:
		[currentObject isDBDeleted 
			ifTrue: [false]
			ifFalse: [true]]
	ifFalse:
		[currentObject isDBDeleted
		ifTrue:
			["Re-insert the receiver by marking it as new"
			copyObject := nil.
			currentProxyObject _matchStateOf: self]
		ifFalse:
			[| myUpdates |
			myUpdates := self _fieldUpdates.
			currentProxyObject _copyObject: copyObject.
			currentProxyObject _fieldUpdates applyTo: proxiedObject.
			myUpdates applyTo: proxiedObject].
		true]
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _refreshFromRow: aDatabaseRow table: aDBTable [

	"Return whether the proxiedObject was refreshed at all.
	table is passed in as an optimisation"

	^(super _refreshFromRow: aDatabaseRow table: aDBTable)
	ifTrue: 
		["Update the copyObject"
		self _acquireCopyObject]
	ifFalse:
		[false]
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _resolveUpdateConflicts [

	"Changes to the receiver have failed to commit in anSSWReStore due to another client's changes.
	Attempt to resolve the conflicts.

	For implementation details, see _resolveUpdateConflictsWith:"	

	| currentProxy |

	currentProxy := self _currentVersion.

	^(self _resolveUpdateConflictsWith: currentProxy)
		ifTrue: [self _matchStateOf: currentProxy. true]
		ifFalse: [false]
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _resolveUpdateConflictsWith: currentProxyObject [

	"Changes to the receiver have failed to commit in anSSWReStore due to another client's changes.
	Analyse all changes made (between the receiver's copyObject, proxiedObject and currentProxyObject)
	and attempt to bring the receiver up to date with the state of currentProxyObject,
	whilst maintaining the receiver's changes from its copyObject.

	Return true if the receiver was able to resolve the conflict, false otherwise"

	| newVersion |

	newVersion := currentProxyObject _proxiedObject.
	newVersion isDBDeleted ifTrue: [^false].

	self _dbTable dataFields do:
		[ :field || accessor oldValue myValue newValue |
		accessor := field accessor.
		oldValue := accessor valueIn: copyObject.
		myValue := accessor valueIn: proxiedObject.
		newValue := accessor valueIn: newVersion.

		(myValue _hasChangedFrom: oldValue) 
		ifTrue: 
			["Receiver has changed this attribute.
			If newVersion has also changed it, then there is a clash.
			Ask the proxiedObject to resolve this"
			(newValue _hasChangedFrom: oldValue) ifTrue:
				[(proxiedObject 
					safeHandleUpdateClash: accessor name 
					from: copyObject
					to: newVersion) ifFalse: [^false]]]
		ifFalse:
			["Receiver has not changed this attribute (no clash). 
			Check for change in newVersion, and ask proxiedObject to handle it (usually by merging)"
			(newValue _hasChangedFrom: oldValue) ifTrue: 
				[(proxiedObject 
					safeMergeUpdateFrom: newVersion 
					newValue: newValue
					accessor: accessor) ifFalse:[^false]]]].

	^true
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _rollbackUpdates [

	"Private - Forget any updates by instantiating from the copyObject.
	Also transfer over any events registered against the current proxiedObject"

	| me him |

	me := proxiedObject.
	him := self.

	self _unswap.

	me _checkHasChanged ifTrue: 
		[me _setProxiedObject: (me _dbTable copyForProxy: me _copyObject).
		him getEvents ifNotNil: [ :events | me _proxiedObject setEvents: events]]
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _updateCollectionProxyUsing: aCollectionSpec [

	| collectionProxy |

	collectionProxy := super _updateCollectionProxyUsing: aCollectionSpec.
	copyObject notNil ifTrue: [aCollectionSpec accessor value: collectionProxy in: copyObject].

	^collectionProxy
]

{ #category : #accessing }
SSWDBCachingObjectProxy >> _valuesForAccessor: anInstVarAccessor [

	"Return the value(s) in the receiver's proxy object(s) which could be accessed by anInstVarAccessor.
	Also need to consider the copyObject"

	| proxyValue copyValue |

	proxyValue := proxiedObject ifNotNil: [anInstVarAccessor valueIn: proxiedObject].
	copyValue := copyObject ifNotNil: [anInstVarAccessor valueIn: copyObject].

	^proxyValue == copyValue 
		ifTrue: [Array with: proxyValue]
		ifFalse: [Array with: proxyValue with: copyValue]
]

{ #category : #forwarding }
SSWDBCachingObjectProxy >> inspect [

	"Prevent inspecting of a deleted object"

	^self _isDeleted
		ifTrue: [nil inspect]
		ifFalse: [super inspect]
]
