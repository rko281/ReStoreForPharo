"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBGeneralCollectionBlockReceiver',
	#superclass : 'SSWDBCollectionBlockReceiver',
	#instVars : [
		'intermediateCollection'
	],
	#category : 'SSW ReStore Querying',
	#package : 'SSW ReStore Querying'
}

{ #category : 'accessing' }
SSWDBGeneralCollectionBlockReceiver >> collectionParser [

	^self intermediateCollection parser

]

{ #category : 'parsing-collection messages' }
SSWDBGeneralCollectionBlockReceiver >> includes: anObject [

	"Can be done with just the intermediate table"

	^self localAnySatisfy: [ :each | each target = anObject]
]

{ #category : 'parsing-collection messages' }
SSWDBGeneralCollectionBlockReceiver >> includesAssociation: anAssociation [

	"For dictionaires - turn into an equivalent anySatisfy:"

	^self localAnySatisfy: [ :each | (each index = anAssociation key) & (each target = anAssociation value)]
]

{ #category : 'parsing-collection messages' }
SSWDBGeneralCollectionBlockReceiver >> includesKey: anObject [

	"For dictionaires - turn into an equivalent anySatisfy:"

	^self localAnySatisfy: [ :each | each index = anObject]
]

{ #category : 'accessing' }
SSWDBGeneralCollectionBlockReceiver >> intermediateCollection [

	"Return a stored instances pseudo-collection representing the entries in the intermediate table.
	This uses a custom parser to allow these entries to be traversed like standard persistent objects"

	^intermediateCollection ifNil: 
		[intermediateCollection := self reStore instancesOf: self collectionSpec entryClass.
		intermediateCollection parser argumentTable: self collectionSpec collectionTable.
		intermediateCollection]

]

{ #category : 'helpers' }
SSWDBGeneralCollectionBlockReceiver >> localAnySatisfy: aBlock [

	"Private - For subqueries requiring only the intermediate table"

	^self conditionWithQuery: 
		((self localSelectQueryFrom: aBlock)
			fields: self targetField;
			yourself)
]

{ #category : 'helpers' }
SSWDBGeneralCollectionBlockReceiver >> qualifyCollectionParserWith: aBlock [

	"Start with the target collection, not the intermediate"

	self collectionParser qualifyWith: [ :each | aBlock value: each target]
]

{ #category : 'helpers' }
SSWDBGeneralCollectionBlockReceiver >> selectQueryFrom: aBlock [

	"Start with the elements of the target collection, not the intermediate table's collection entries"

	^super selectQueryFrom: [ :each | aBlock value: each target]
]

{ #category : 'accessing' }
SSWDBGeneralCollectionBlockReceiver >> targetField [

	"Confusingly, in this context the target field is the source field of the intermediate table. 
	This is in order to be equivalent to the target field (backpointer) in an owned collection"

	^self collectionSpec collectionTable fieldAccessing: #sourceID
]

{ #category : 'accessing' }
SSWDBGeneralCollectionBlockReceiver >> targetFieldCollectQuery [

	"Confusingly, in this context the target field is the source field of the intermediate table. 
	This is in order to be equivalent to the target field (backpointer) in an owned collection"

	^self collectionParser collectQueryFrom: [ :each | each sourceID]
]

{ #category : 'accessing' }
SSWDBGeneralCollectionBlockReceiver >> targetTableFromParser [

	"Ensure the target collection table is included in the parser.
	Return the table, aliased if necessary"

	| collectionTable collectionSourceField targetTable |

	"We also need to ensure the intermediate collection table is added to the parser"
	collectionTable := self collectionSpec collectionTable.
	collectionSourceField := collectionTable fieldsAccessing: #sourceID.
	(self parser referencedTables tableJoinedWithField: collectionSourceField) isNil ifTrue:
		[| sourceTable occurrences |
		sourceTable := self collectionSpec table.
		occurrences := self parser referencedTables occurrencesOf: collectionTable.
		occurrences > 0 ifTrue: [collectionTable := SSWDBQueryTable forRepetition: occurrences of: collectionTable].
		self parser referencedTables add: collectionTable joinedWith: (SSWSQLCondition field: sourceTable idField equalTo: collectionSourceField)].

	targetTable := self collectionSpec targetTable.
	^(self parser referencedTables tableJoinedWithField: targetTable idField) ifNil:
		[| occurrences |
		occurrences := self parser referencedTables occurrencesOf: targetTable.
		occurrences > 0 ifTrue: [targetTable := SSWDBQueryTable forRepetition: occurrences of: targetTable].
		self parser referencedTables add: targetTable joinedWith: (SSWSQLCondition field: (collectionTable fieldAccessing: #target) equalTo: targetTable idField)]
]
