Trait {
	#name : 'SSWReStoreDBStatement',
	#instVars : [
		'query',
		'sqlString',
		'parametersCount',
		'results'
	],
	#category : 'SSW ReStore for Pharo',
	#package : 'SSW ReStore for Pharo'
}

{ #category : 'initialize-release' }
SSWReStoreDBStatement >> close [

	"In Dolphin this closes the result set, leaving the statement open"
	
	self results ifNotNil: [ :res | res close ]
]

{ #category : 'initialize-release' }
SSWReStoreDBStatement >> closeAfter: aBlock [

	^[ aBlock value: self ] ensure: [ self close ]
]

{ #category : 'accessing' }
SSWReStoreDBStatement >> describeParam: anInteger [

	^nil
]

{ #category : 'querying' }
SSWReStoreDBStatement >> exec [

	self logQueryExecution.
	self results: self execute
]

{ #category : 'initialize-release' }
SSWReStoreDBStatement >> free [

	"We have completely finished with the receiver; usually equivalent to Statement>>close in Pharo"

	[super close] on: Error do: [  :exc | exc return: nil ]
]

{ #category : 'public' }
SSWReStoreDBStatement >> logQueryExecution [

	self parent logStatementExecution: self
]

{ #category : 'accessing' }
SSWReStoreDBStatement >> numRows [

	^self results numRows
]

{ #category : 'accessing' }
SSWReStoreDBStatement >> parametersCount [
	^ parametersCount
]

{ #category : 'accessing' }
SSWReStoreDBStatement >> parametersCount: anObject [
	parametersCount := anObject
]

{ #category : 'accessing' }
SSWReStoreDBStatement >> query [

	^query
]

{ #category : 'initialize-release' }
SSWReStoreDBStatement >> readValuesFrom: aStream [

	| size index |

	size := self parametersCount.
	self values: (Array new: size).
	index := 1.

	[aStream atEnd or: [index > size]] whileFalse: 
		[self valueAt: index put: aStream next.
		index := index + 1]
]

{ #category : 'accessing' }
SSWReStoreDBStatement >> results [
	^ results
]

{ #category : 'accessing' }
SSWReStoreDBStatement >> results: anObject [
	results := anObject
]

{ #category : 'accessing' }
SSWReStoreDBStatement >> rowsAffected [

	^self closeAfter: [ :stmt | stmt numRows]
]

{ #category : 'accessing' }
SSWReStoreDBStatement >> setQuery: anSSWSQLQuery [
	query := anSSWSQLQuery 
]

{ #category : 'accessing' }
SSWReStoreDBStatement >> sqlDialect [

	^self parent sqlDialect
]

{ #category : 'accessing' }
SSWReStoreDBStatement >> sqlString [
	^ sqlString
]

{ #category : 'accessing' }
SSWReStoreDBStatement >> sqlString: anObject [
	sqlString := anObject
]

{ #category : 'writing' }
SSWReStoreDBStatement >> writeDebugInfoOn: aStream [

	| readStream valuesStream sqlStream |

	self parametersCount = 0 ifTrue: [^aStream nextPutAll: self sqlString; nextPut: $;; cr].

	readStream := ReadStream on: self sqlString.
	valuesStream := ReadStream on: self values.
	sqlStream := self sqlDialect sqlWriteStream.

	[| nextChunk |
	nextChunk := readStream upTo: $?.
	nextChunk isEmpty ifFalse: 
		[sqlStream nextPutAll: nextChunk.
		valuesStream atEnd ifFalse: [valuesStream nextAvailable printOn: sqlStream]].
	readStream atEnd] whileFalse.

	aStream nextPutAll: sqlStream contents; nextPut: $;; cr
]
