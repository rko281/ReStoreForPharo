Extension { #name : #ByteArray }

{ #category : #'*SSW ReStore SQL Entities' }
ByteArray >> writeSQLOn: aStream [

	"Avoid SQL injection and other issues by always using parameterized values for ByeArrays"
	self writeSQLOn: aStream forField: (SSWSQLParameterField forValue: self)
]

{ #category : #'*SSW ReStore SQL Entities' }
ByteArray >> writeSQLOn: aStream forField: aField [

	"Opt out of the Collection implementation"
	^aStream nextPut: self forField: aField
]

{ #category : #'*SSW ReStore SQL Entities' }
ByteArray class >> writeSQLTypeOn: aStream using: aSQLDialect [

	aStream nextPutAll: aSQLDialect blob
]
