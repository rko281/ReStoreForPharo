"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBGeneralCollectionSpec',
	#superclass : 'SSWDBCollectionSpec',
	#instVars : [
		'sourceField',
		'targetField',
		'collectionTable'
	],
	#category : 'SSW ReStore Collections',
	#package : 'SSW ReStore Collections'
}

{ #category : 'change detection' }
SSWDBGeneralCollectionSpec >> allAdditionsTo: aCollection [

	"Return an OrderedCollection of SSWDBCollectionAdditions representing the addition of all aCollection's elements to itself, starting when empty"

	"Must return an OrderedCollection, so don't use collect:"
	^aCollection inject: (OrderedCollection new: aCollection size) into: [ :all :each | all add: (SSWDBCollectionAddition added: each); yourself]
]

{ #category : 'change detection' }
SSWDBGeneralCollectionSpec >> changesTo: aCollection from: aCollectionOfEntries [

	"Return the changes made to aCollection compared to aCollectionOf(Collection)Entries"

	^self subclassResponsibility
]

{ #category : 'accessing' }
SSWDBGeneralCollectionSpec >> collectionTable [

	"collectionTable stores an SSWDBTable that is used to store 'instances'
	of the collection modelled by the receiver"
	
	collectionTable == nil ifTrue: [self createCollectionTable].
	
	^collectionTable
]

{ #category : 'accessing' }
SSWDBGeneralCollectionSpec >> collectionTable: anSSWDBTable [

	"collectionTable stores an SSWDBTable that is used to store 'instances'
	of the collection modelled by the receiver"
	
	collectionTable := anSSWDBTable
]

{ #category : 'evaluating' }
SSWDBGeneralCollectionSpec >> containedTables [

	^Array with: self collectionTable
]

{ #category : 'initializing' }
SSWDBGeneralCollectionSpec >> createCollectionTable [

	| sourceName targetName |
	
	sourceName := self table containedTableNameRoot.
	targetName := self table sqlDialect transformInstVarName: self accessor name.
	
	self collectionTable: 
		(self entryClass dbTableNamed: (sourceName, targetName) in: self table reStore)
]

{ #category : 'actions - api' }
SSWDBGeneralCollectionSpec >> deleteEntry: anSSWDBCollectionEntry [

	| query |

	query := SSWSQLDeleteObjectQuery forObject: anSSWDBCollectionEntry.

	(self collectionTable deleteStatementGeneratedFrom: query)
		values: query values;
		exec; 
		close
]

{ #category : 'constants' }
SSWDBGeneralCollectionSpec >> entryClass [

	"Return the class of collection entry appropriate for the receiver"
	
	^SSWDBCollectionEntry
]

{ #category : 'testing' }
SSWDBGeneralCollectionSpec >> hasMutableElements [

	^self targetClass isMutableDirectlyPersistedNonBaseClass
]

{ #category : 'actions - api' }
SSWDBGeneralCollectionSpec >> insertEntry: anSSWDBCollectionEntry [

	| query statement |

	query := SSWSQLInsertQuery forObject: anSSWDBCollectionEntry.

	statement := self collectionTable insertStatementGeneratedFrom: query.
	statement values: query values.
	statement exec; close
]

{ #category : 'constants' }
SSWDBGeneralCollectionSpec >> queryClass [

	"Return the class of select query appropriate for the receiver"
	
	^SSWSQLSelectQuery
]

{ #category : 'change detection' }
SSWDBGeneralCollectionSpec >> shouldCompareChangesByEquality [

	"Generally, directly-persisted objects are compared by equality, and persistent object stored in their own table are compared by identity.
	The former could be slightly optimised for e.g. collections of Symbols"

	^self targetClass isDirectlyPersisted
]

{ #category : 'accessing' }
SSWDBGeneralCollectionSpec >> sourceField [

	"sourceField stores the SSWDBField in the receiver's collectionTable
	that points to the collection owner"
	
	sourceField == nil ifTrue: [sourceField := self collectionTable fieldAccessing: #sourceID].
	
	^sourceField
]

{ #category : 'accessing' }
SSWDBGeneralCollectionSpec >> sourceField: anSSWDBField [

	"sourceField stores the SSWDBField in the receiver's collectionTable
	that points to the collection owner"
	
	sourceField := anSSWDBField
]

{ #category : 'accessing' }
SSWDBGeneralCollectionSpec >> targetField [

	"targetField stores the SSWDBField in the receiver's collectionTable
	that points to the objects that belong in the collection"
	
	targetField == nil ifTrue: [targetField := self collectionTable fieldAccessing: #target].
	
	^targetField
]

{ #category : 'accessing' }
SSWDBGeneralCollectionSpec >> targetField: anSSWDBField [

	"targetField stores the SSWDBField in the receiver's collectionTable
	that points to the objects that belong in the collection"
	
	targetField := anSSWDBField
]
