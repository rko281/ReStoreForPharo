"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBKeyedCollectionEntry',
	#superclass : 'SSWDBCollectionEntry',
	#instVars : [
		'index'
	],
	#category : 'SSW ReStore Collections',
	#package : 'SSW ReStore Collections'
}

{ #category : 'persistence' }
SSWDBKeyedCollectionEntry class >> dbTableNamed: aString in: anSSWReStore [

	| table |

	table := super dbTableNamed: aString in: anSSWReStore.
	
	(table define: #index as: Integer) name: (anSSWReStore sqlDialect transformInstVarName: #index_).
		
	^table
]

{ #category : 'actions' }
SSWDBKeyedCollectionEntry >> addTargetTo: aCollection [

	aCollection _dbAdd: self target suggestedIndex: self index
]

{ #category : 'actions' }
SSWDBKeyedCollectionEntry >> copyTargetTo: aCollection [

	self hasMutableIndex 
	ifTrue: 
		[self hasMutableTarget
			ifTrue: [aCollection _dbAdd: self target copy suggestedIndex: self index copy]
			ifFalse: [aCollection _dbAdd: self target suggestedIndex: self index copy]]
	ifFalse:
		[aCollection _dbAdd: self target copy suggestedIndex: self index]
]

{ #category : 'testing' }
SSWDBKeyedCollectionEntry >> hasMutableIndex [

	^self index class isMutableDirectlyPersistedNonBaseClass
]

{ #category : 'accessing' }
SSWDBKeyedCollectionEntry >> index [

	"index stores the index (key) of the target object in the collection"
	
	^index
]

{ #category : 'accessing' }
SSWDBKeyedCollectionEntry >> index: anInteger [

	"index stores the index (key) of the target object in the collection"
	
	index := anInteger
]

{ #category : 'actions' }
SSWDBKeyedCollectionEntry >> prepareToCommitFor: anSSWDBCachingCollectionProxy [

	^self index _ensureActiveIn: anSSWDBCachingCollectionProxy _reStore

]
