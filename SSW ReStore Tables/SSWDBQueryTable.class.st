"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBQueryTable',
	#superclass : 'Object',
	#instVars : [
		'table',
		'repetitionIndex',
		'allFields'
	],
	#category : 'SSW ReStore Tables',
	#package : 'SSW ReStore Tables'
}

{ #category : 'instance creation' }
SSWDBQueryTable class >> forRepetition: anInteger of: anSSWDBTable [

	^self new
		table: anSSWDBTable;
		repetitionIndex: anInteger;
		yourself
]

{ #category : 'comparing' }
SSWDBQueryTable >> = anSSWDBTable [

	^self == anSSWDBTable or: [self species == anSSWDBTable species and: [self name = anSSWDBTable name and: [self repetitionIndex = anSSWDBTable repetitionIndex]]]
]

{ #category : 'accessing' }
SSWDBQueryTable >> allFields [

	^allFields ifNil: [allFields := self table allFields collect: [ :each | SSWDBQueryTableField forField: each in: self]]
]

{ #category : 'enumerating' }
SSWDBQueryTable >> allFieldsDetect: aBlock ifNone: noneBlock [

	^self allFields detect: aBlock ifNone: noneBlock
]

{ #category : 'enumerating' }
SSWDBQueryTable >> allFieldsDo: aBlock [

	^self allFields do: aBlock
]

{ #category : 'evaluating' }
SSWDBQueryTable >> collectionAccessing: aSymbol [

	"Forward to the real table"
	
	^self table collectionAccessing: aSymbol
]

{ #category : 'evaluating' }
SSWDBQueryTable >> fieldAccessing: aSymbol [

	^self allFieldsDetect: [ :field | field accessor accesses: aSymbol] ifNone: [nil]
]

{ #category : 'accessing' }
SSWDBQueryTable >> fieldNamed: aString [

	^self allFieldsDetect: [ :field | field name = aString] ifNone: [nil]
]

{ #category : 'testing' }
SSWDBQueryTable >> hasNamespace [

	^self table hasNamespace
]

{ #category : 'testing' }
SSWDBQueryTable >> hasStaticConditions [

	"Forward to the real table"
	
	^self table hasStaticConditions
]

{ #category : 'comparing' }
SSWDBQueryTable >> hash [

	^self name hash bitXor: self repetitionIndex
]

{ #category : 'accessing' }
SSWDBQueryTable >> idField [

	^self allFields detect: [ :each | each field == self table idField]
]

{ #category : 'accessing' }
SSWDBQueryTable >> instanceClass [

	^self table instanceClass
]

{ #category : 'accessing' }
SSWDBQueryTable >> instanceClassFromRow: aRow [

	"isKindOf: test to avoid aliasing the row if not needed"
	^(self table isKindOf: SSWDBInheritedTable)
		ifTrue: [self instanceClass]
		ifFalse: [self table instanceClassFromRow: (aRow copy deAliasQueryFieldsFor: self)]
]

{ #category : 'accessing' }
SSWDBQueryTable >> name [

	^self table name
]

{ #category : 'accessing' }
SSWDBQueryTable >> originalTable [

	"Return the original table wrapped by the receiver.
	This may be == self table, however where the receiver wraps a withAllFields table it will be different"

	^self reStore tableForClass: self instanceClass
]

{ #category : 'accessing' }
SSWDBQueryTable >> reStore [

	^self table reStore
]

{ #category : 'operations' }
SSWDBQueryTable >> recoverInstanceFromRow: aRow into: aDBProxy [

	^self originalTable recoverInstanceFromRow: (aRow copy deAliasQueryFieldsFor: self) into: aDBProxy
]

{ #category : 'operations' }
SSWDBQueryTable >> refreshProxy: aDBProxy whereChangedFromRow: aRow [

	^self originalTable refreshProxy: aDBProxy whereChangedFromRow: (aRow copy deAliasQueryFieldsFor: self)
]

{ #category : 'accessing' }
SSWDBQueryTable >> repetitionIndex [

	"repetitionIndex specifies which repetition of the receiver's table the receiver replaces.
	e.g. the first repetition (second occurrence) has a repetitionIndex of 1"
	
	^repetitionIndex
]

{ #category : 'accessing' }
SSWDBQueryTable >> repetitionIndex: anInteger [

	"repetitionIndex specifies which repetition of the receiver's table the receiver replaces.
	e.g. the first repetition (second occurrence) has a repetitionIndex of 1"
	
	repetitionIndex := anInteger
]

{ #category : 'accessing' }
SSWDBQueryTable >> sqlAndStaticConditionsWith: anSQLConditionCollection [

	"Created for issue 120-015

	Return the receiver's staticConditions ANDed with anSQLConditionCollection"
	
	"The receiver's staticConditions are redundant if there is a unique ID condition"
	^(anSQLConditionCollection anySatisfy: [ :cond | cond field = self idField and: [cond operator isEquality and: [cond value notNil]]]) 
		ifTrue: [anSQLConditionCollection]
		ifFalse: [self staticConditions sqlAnd: anSQLConditionCollection]
]

{ #category : 'accessing' }
SSWDBQueryTable >> sqlDialect [

	^self table sqlDialect
]

{ #category : 'accessing' }
SSWDBQueryTable >> staticConditions [

	"Created for issue 120-015

	Copy from the table"

	^self table staticConditions copyForQueryTable: self
]

{ #category : 'accessing' }
SSWDBQueryTable >> table [

	"The receiver is created to stand in place of a regular SSWDBTable when 
	that table is referenced more than once in a query (in different roles).
	The second (third, fourth...) occurrences are replaced by instances of the receiver's class.
	
	table stores the original table which the receiver is standing in place of"
	
	^table
]

{ #category : 'accessing' }
SSWDBQueryTable >> table: anSSWDBTable [

	"The receiver is created to stand in place of a regular SSWDBTable when 
	that table is referenced more than once in a query (in different roles).
	The second (third, fourth...) occurrences are replaced by instances of the receiver's class.
	
	table stores the original table which the receiver is standing in place of"
	
	table := anSSWDBTable
]

{ #category : 'accessing' }
SSWDBQueryTable >> versionControlField [

	| versionControlField |

	versionControlField := self table versionControlField.

	^self allFields detect: [ :each | each field == versionControlField]
]

{ #category : 'accessing' }
SSWDBQueryTable >> withAllFields [

	self table: self table withAllFields.
	^self

]

{ #category : 'output' }
SSWDBQueryTable >> writeSQLNameOn: aStream [

	"Append to aStream a name for the receiver based on the repetitionIndex.
	This should be unique within any query the receiver is involved in"
	
	aStream nextPutAliasedTable: self
]

{ #category : 'output' }
SSWDBQueryTable >> writeSQLOn: aStream [

	"Alias the actual table name if necessary"
		
	self table writeSQLNameOn: aStream.

	self repetitionIndex > 0 ifTrue:
		[aStream nextPutAll: ' AS '.
		self writeSQLNameOn: aStream]
]
