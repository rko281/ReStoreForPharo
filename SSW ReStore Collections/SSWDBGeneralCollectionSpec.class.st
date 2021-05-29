"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBGeneralCollectionSpec,
	#superclass : #SSWDBCollectionSpec,
	#instVars : [
		'sourceField',
		'targetField',
		'collectionTable'
	],
	#category : #'SSW ReStore Collections'
}

{ #category : #accessing }
SSWDBGeneralCollectionSpec >> collectionTable [

	"collectionTable stores an SSWDBTable that is used to store 'instances'
	of the collection modelled by the receiver"
	
	collectionTable == nil ifTrue: [self createCollectionTable].
	
	^collectionTable
]

{ #category : #accessing }
SSWDBGeneralCollectionSpec >> collectionTable: anSSWDBTable [

	"collectionTable stores an SSWDBTable that is used to store 'instances'
	of the collection modelled by the receiver"
	
	collectionTable := anSSWDBTable
]

{ #category : #evaluating }
SSWDBGeneralCollectionSpec >> containedTables [

	^Array with: self collectionTable
]

{ #category : #initializing }
SSWDBGeneralCollectionSpec >> createCollectionTable [

	| sourceName targetName |
	
	sourceName := self table containedTableNameRoot.
	targetName := self table sqlDialect transformInstVarName: self accessor name.
	
	self collectionTable: 
		(self entryClass dbTableNamed: (sourceName, targetName) in: self table reStore)
]

{ #category : #'actions - api' }
SSWDBGeneralCollectionSpec >> deleteEntry: anSSWDBCollectionEntry [

	| query |

	query := SSWSQLDeleteObjectQuery forObject: anSSWDBCollectionEntry.

	(self collectionTable deleteStatementGeneratedFrom: query)
		values: query values;
		exec; 
		close
]

{ #category : #constants }
SSWDBGeneralCollectionSpec >> entryClass [

	"Return the class of collection entry appropriate for the receiver"
	
	^SSWDBCollectionEntry
]

{ #category : #'actions - api' }
SSWDBGeneralCollectionSpec >> insertEntry: anSSWDBCollectionEntry [

	| query statement |

	query := SSWSQLInsertQuery forObject: anSSWDBCollectionEntry.

	statement := self collectionTable insertStatementGeneratedFrom: query.
	statement values: query values.
	statement exec; close
]

{ #category : #constants }
SSWDBGeneralCollectionSpec >> queryClass [

	"Return the class of select query appropriate for the receiver"
	
	^SSWSQLSelectQuery
]

{ #category : #accessing }
SSWDBGeneralCollectionSpec >> sourceField [

	"sourceField stores the SSWDBField in the receiver's collectionTable
	that points to the collection owner"
	
	sourceField == nil ifTrue: [sourceField := self collectionTable fieldAccessing: #sourceID].
	
	^sourceField
]

{ #category : #accessing }
SSWDBGeneralCollectionSpec >> sourceField: anSSWDBField [

	"sourceField stores the SSWDBField in the receiver's collectionTable
	that points to the collection owner"
	
	sourceField := anSSWDBField
]

{ #category : #accessing }
SSWDBGeneralCollectionSpec >> targetField [

	"targetField stores the SSWDBField in the receiver's collectionTable
	that points to the objects that belong in the collection"
	
	targetField == nil ifTrue: [targetField := self collectionTable fieldAccessing: #target].
	
	^targetField
]

{ #category : #accessing }
SSWDBGeneralCollectionSpec >> targetField: anSSWDBField [

	"targetField stores the SSWDBField in the receiver's collectionTable
	that points to the objects that belong in the collection"
	
	targetField := anSSWDBField
]
