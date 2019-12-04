"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBVersionedCachingObjectProxy,
	#superclass : #SSWDBCachingObjectProxy,
	#instVars : [
		'version'
	],
	#category : #'SSW ReStore Main'
}

{ #category : #'instance creation' }
SSWDBVersionedCachingObjectProxy class >> _forNewObject: anObject withID: anInteger inReStore: aReStore [

	"Overriden to set initial version number"
	
	^(super _forNewObject: anObject withID: anInteger inReStore: aReStore)
		_version: 1;
		yourself
]

{ #category : #constants }
SSWDBVersionedCachingObjectProxy class >> controlFields [

	"Overriden to set version controlField"

	^super controlFields
		add: self versionControlField;
		yourself
]

{ #category : #constants }
SSWDBVersionedCachingObjectProxy class >> modifyUpdatesFor: anSSWDBTable [

	^(super modifyUpdatesFor: anSSWDBTable)
		add: [ :obj | obj _version: obj _version + 1];
		yourself
	
]

{ #category : #'instance creation' }
SSWDBVersionedCachingObjectProxy class >> new [

	"Overriden to set initial version number"
	
	^super new
		_version: 1;
		yourself
]

{ #category : #constants }
SSWDBVersionedCachingObjectProxy class >> versionControlField [

	^SSWDBStaticField new
		accessor: SSWDBVersionAccessor new;
		targetClass: Integer;
		yourself
	
]

{ #category : #'actions-internal' }
SSWDBVersionedCachingObjectProxy >> _commitUpdates [

	"Reimplemented to include version increment"

	| updates |

	updates := self _fieldUpdates.
	
	^updates isEmpty 
	ifTrue: 
		[true]
	ifFalse: 
		[updates add: self _incrementVersionUpdate.
		(reStore applyUpdates: updates toObject: self)]
]

{ #category : #'actions-internal' }
SSWDBVersionedCachingObjectProxy >> _incrementVersion [

	version == nil
		ifTrue: [version := 1]
		ifFalse: [version := version + 1]
]

{ #category : #'accessing:derived' }
SSWDBVersionedCachingObjectProxy >> _incrementVersionUpdate [

	"Create and return an update that will increment the version number
	of the row corresponding to the receiver's proxiedObject"
	
	^version == nil
		ifTrue: [SSWSQLFieldAssignment field: (self _dbTable fieldAccessing: #_version) value: 1]
		ifFalse: [SSWSQLFieldAssignment field: (self _dbTable fieldAccessing: #_version) value: (version + 1)]
]

{ #category : #'actions-internal' }
SSWDBVersionedCachingObjectProxy >> _matchStateOf: aProxy [

	"Match the internal proxy (non data) state of aProxy"

	version := aProxy _version
]

{ #category : #'actions-internal' }
SSWDBVersionedCachingObjectProxy >> _postCommitUpdates [

	"Reimplemented to increment version"

	| updates |

	updates := self _fieldUpdates.
	
	updates isEmpty ifFalse: 
		[updates applyTo: copyObject. 
		self _incrementVersion]
]

{ #category : #'actions-refresh' }
SSWDBVersionedCachingObjectProxy >> _refreshIfUpdated [

	"Using the receiver's version it is possible to refresh the receiver only if it has actually been updated in the database"

	self _isRecovered ifTrue: 
		[(reStore refreshProxyIfUpdated: self) ifTrue:
			["Update the copyObject"
			self _aquireCopyObject]]
]

{ #category : #accessing }
SSWDBVersionedCachingObjectProxy >> _version [

	"version stores an Integer representing the version or revision number
	of the object proxy'd by the receiver.
	
	This number is incremented each time the object is changed in the DB"
	
	^version
]

{ #category : #accessing }
SSWDBVersionedCachingObjectProxy >> _version: anInteger [

	"version stores an Integer representing the version or revision number
	of the object proxy'd by the receiver.
	
	This number is incremented each time the object is changed in the DB"
	
	version := anInteger
]
