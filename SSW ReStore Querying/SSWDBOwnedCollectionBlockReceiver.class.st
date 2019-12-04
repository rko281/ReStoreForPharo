"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBOwnedCollectionBlockReceiver,
	#superclass : #SSWDBCollectionBlockReceiver,
	#category : #'SSW ReStore Querying'
}

{ #category : #accessing }
SSWDBOwnedCollectionBlockReceiver >> targetField [

	self collectionSpec ownerField isNil ifTrue: [self collectionSpec setOwnerFieldFrom: self reStore].

	^self collectionSpec ownerField
]

{ #category : #accessing }
SSWDBOwnedCollectionBlockReceiver >> targetFieldCollectQuery [

	^self collectionParser collectQueryFrom: [ :each | (each perform: self targetField accessor name) _id]
]

{ #category : #accessing }
SSWDBOwnedCollectionBlockReceiver >> targetTableFromParser [

	"Ensure the target collection table is included in the parser.
	Return the table, aliased if necessary"

	^(self parser referencedTables tableJoinedWithField: self targetField) ifNil:
		[| sourceTable targetTable occurrences |
		sourceTable := self collectionSpec table.
		targetTable := self collectionSpec targetTable.
		occurrences := self parser referencedTables occurrencesOf: targetTable.
		occurrences > 0 ifTrue: [targetTable := SSWDBQueryTable forRepetition: occurrences of: targetTable].
		self parser referencedTables add: targetTable joinedWith: (SSWSQLCondition field: sourceTable idField equalTo: self targetField)]
]
