Extension { #name : #String }

{ #category : #'*SSW ReStore SQL Entities' }
String >> asSQLFunction [

	^SSWSQLFunction new
		parameterizedString: self;
		yourself
]

{ #category : #'*SSW ReStore SQL Entities' }
String >> asSQLFunctionBooleanResult [

	^self asSQLFunctionWithResultClass: Integer
]

{ #category : #'*SSW ReStore SQL Entities' }
String >> asSQLFunctionIntegerResult [

	^self asSQLFunctionWithResultClass: Integer
]

{ #category : #'*SSW ReStore SQL Entities' }
String >> asSQLFunctionStringResult [

	^self asSQLFunctionWithResultClass: String
]

{ #category : #'*SSW ReStore SQL Entities' }
String >> asSQLFunctionWithResultClass: aClass [

	^self asSQLFunction
		staticResultClass: aClass;
		yourself
]

{ #category : #'*SSW ReStore SQL Entities' }
String >> writeSQLOn: aStream [

	"Avoid SQL injection and other issues by always using parameterized values for Strings"
	self writeSQLOn: aStream forField: (SSWSQLParameterField forValue: self)
]

{ #category : #'*SSW ReStore SQL Entities' }
String >> writeSQLOn: aStream forField: aField [

	"Opt out of the Collection implementation"
	^aStream nextPut: self forField: aField
]

{ #category : #'*SSW ReStore SQL Entities' }
String class >> writeSQLTypeOn: aStream using: anSQLDialect [

	"As this is the non-sized variant, use a reasonably-sized variable text type"
	
	aStream nextPutAll: anSQLDialect unsizedString
]
