Extension { #name : #Object }

{ #category : #'*SSW ReStore SQL Entities' }
Object >> ifNull: aValue [

	"SQL control flow message; maps to IFNULL().
	Really just here to prevent unimplemented selector warnings but can be used where image/database agnostic code is needed"

	^self ifNil: [aValue]
]

{ #category : #'*SSW ReStore SQL Entities' }
Object >> ifNull: aValue ifNotNull: otherValue [

	"SQL control flow message; maps to a CASE statement.
	Really just here to prevent unimplemented selector warnings but can be used where image/database agnostic code is needed"

	^self ifNil: [aValue] ifNotNil: [otherValue]
]

{ #category : #'*SSW ReStore SQL Entities' }
Object >> isSQLNull [

	^false
]

{ #category : #'*SSW ReStore SQL Entities' }
Object >> sqlCanBeParameterized [

	"Can the SQL representation of the receiver be parameterized?"
	^true
]

{ #category : #'*SSW ReStore SQL Entities' }
Object >> sqlStringIn: anSSWSQLDialect [

	| stream |
	
	stream := anSSWSQLDialect sqlWriteStream.
	
	self writeSQLOn: stream.
	
	^stream contents
]

{ #category : #'*SSW ReStore SQL Entities' }
Object >> writeSQLOn: aStream forCondition: aSQLCondition [

	^self writeSQLOn: aStream forField: aSQLCondition field
]

{ #category : #'*SSW ReStore SQL Entities' }
Object >> writeSQLOn: aStream forField: aField [

	^aStream nextPut: self forField: aField
]

{ #category : #'*SSW ReStore SQL Entities' }
Object class >> writeSQLTypeOn: aStream using: anSQLDialect [

	"If not overriden, assume a persistent class with a unique ID"
	
	self reStoreIDClass writeSQLTypeOn: aStream using: anSQLDialect
]
