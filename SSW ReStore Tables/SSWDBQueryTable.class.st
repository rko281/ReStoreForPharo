"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBQueryTable,
	#superclass : #Object,
	#instVars : [
		'table',
		'repetitionIndex'
	],
	#category : #'SSW ReStore Tables'
}

{ #category : #'instance creation' }
SSWDBQueryTable class >> forRepetition: anInteger of: anSSWDBTable [

	^self new
		table: anSSWDBTable;
		repetitionIndex: anInteger;
		yourself
]

{ #category : #comparing }
SSWDBQueryTable >> = anSSWDBQueryTable [

	^self name = anSSWDBQueryTable name and: [self repetitionIndex = anSSWDBQueryTable repetitionIndex]
]

{ #category : #enumerating }
SSWDBQueryTable >> allFieldsDetect: aBlock ifNone: noneBlock [

	^self table allFieldsDetect: aBlock ifNone: noneBlock
]

{ #category : #enumerating }
SSWDBQueryTable >> allFieldsDo: aBlock [

	^self table allFieldsDo: aBlock
]

{ #category : #evaluating }
SSWDBQueryTable >> collectionAccessing: aSymbol [

	"Forward to the real table"
	
	^self table collectionAccessing: aSymbol
]

{ #category : #evaluating }
SSWDBQueryTable >> fieldAccessing: aSymbol [

	"Forward to the real table"
	
	^self table fieldAccessing: aSymbol
]

{ #category : #evaluating }
SSWDBQueryTable >> hasStaticConditions [

	"Forward to the real table"
	
	^self table hasStaticConditions
]

{ #category : #comparing }
SSWDBQueryTable >> hash [

	^self name hash + self repetitionIndex
]

{ #category : #evaluating }
SSWDBQueryTable >> idField [

	"Generate an ID field with the same details as that of the receiver's table,
	but belonging to the receiver"
	
	^SSWDBQueryTableField forField: self table idField in: self
]

{ #category : #accessing }
SSWDBQueryTable >> instanceClass [

	^self table instanceClass
]

{ #category : #accessing }
SSWDBQueryTable >> name [

	^self table name
]

{ #category : #accessing }
SSWDBQueryTable >> reStore [

	^self table reStore
]

{ #category : #accessing }
SSWDBQueryTable >> repetitionIndex [

	"repetitionIndex specifies which repetition of the receiver's table the receiver replaces.
	e.g. the first repetition (second occurrence) has a repetitionIndex of 1"
	
	^repetitionIndex
]

{ #category : #accessing }
SSWDBQueryTable >> repetitionIndex: anInteger [

	"repetitionIndex specifies which repetition of the receiver's table the receiver replaces.
	e.g. the first repetition (second occurrence) has a repetitionIndex of 1"
	
	repetitionIndex := anInteger
]

{ #category : #accessing }
SSWDBQueryTable >> sqlAndStaticConditionsWith: anSQLConditionCollection [

	"Created for issue 120-015

	Return the receiver's staticConditions ANDed with anSQLConditionCollection"
	
	"The receiver's staticConditions are redundant if there is a unique ID condition"
	^(anSQLConditionCollection anySatisfy: [ :cond | cond field = self idField and: [cond operator isEquality and: [cond value notNil]]]) 
		ifTrue: [anSQLConditionCollection]
		ifFalse: [self staticConditions sqlAnd: anSQLConditionCollection]
]

{ #category : #accessing }
SSWDBQueryTable >> sqlDialect [

	^self table sqlDialect
]

{ #category : #accessing }
SSWDBQueryTable >> staticConditions [

	"Created for issue 120-015

	Copy from the table"

	^self table staticConditions copyForQueryTable: self
]

{ #category : #accessing }
SSWDBQueryTable >> table [

	"The receiver is created to stand in place of a regular SSWDBTable when 
	that table is referenced more than once in a query (in different roles).
	The second (third, fourth...) occurrences are replaced by instances of the receiver's class.
	
	table stores the original table which the receiver is standing in place of"
	
	^table
]

{ #category : #accessing }
SSWDBQueryTable >> table: anSSWDBTable [

	"The receiver is created to stand in place of a regular SSWDBTable when 
	that table is referenced more than once in a query (in different roles).
	The second (third, fourth...) occurrences are replaced by instances of the receiver's class.
	
	table stores the original table which the receiver is standing in place of"
	
	table := anSSWDBTable
]

{ #category : #accessing }
SSWDBQueryTable >> withAllFields [

	self table: self table withAllFields.
	^self

]

{ #category : #output }
SSWDBQueryTable >> writeSQLNameOn: aStream [

	"Append to aStream a name for the receiver based on the repetitionIndex.
	This should be unique within any query the receiver is involved in"
	
	aStream nextPutAliasedTable: self
]

{ #category : #output }
SSWDBQueryTable >> writeSQLOn: aStream [

	"Alias the actual table name if necessary"
		
	aStream nextPutAll: self table name.

	self repetitionIndex > 0 ifTrue:
		[aStream nextPutAll: ' AS '.
		self writeSQLNameOn: aStream]
]
