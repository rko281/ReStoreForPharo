"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBKeyedCollectionEntry,
	#superclass : #SSWDBCollectionEntry,
	#instVars : [
		'index'
	],
	#category : #'SSW ReStore Collections'
}

{ #category : #persistence }
SSWDBKeyedCollectionEntry class >> dbTableNamed: aString in: anSSWReStore [

	| table |

	table := super dbTableNamed: aString in: anSSWReStore.
	
	(table define: #index as: Integer) name: (anSSWReStore sqlDialect transformInstVarName: #index_).
		
	^table
]

{ #category : #actions }
SSWDBKeyedCollectionEntry >> addTargetTo: aCollection [

	aCollection _dbAdd: self target suggestedIndex: self index
]

{ #category : #accessing }
SSWDBKeyedCollectionEntry >> index [

	"index stores the index (key) of the target object in the collection"
	
	^index
]

{ #category : #accessing }
SSWDBKeyedCollectionEntry >> index: anInteger [

	"index stores the index (key) of the target object in the collection"
	
	index := anInteger
]

{ #category : #actions }
SSWDBKeyedCollectionEntry >> prepareToCommitFor: anSSWDBCachingCollectionProxy [

	^self index _ensureActiveIn: anSSWDBCachingCollectionProxy _reStore

]
