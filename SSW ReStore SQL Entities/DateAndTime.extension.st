Extension { #name : 'DateAndTime' }

{ #category : '*SSW ReStore SQL Entities' }
DateAndTime >> asSQLStringIn: aSQLDialect [

	^aSQLDialect dateAndTimeStringFor: self
]

{ #category : '*SSW ReStore SQL Entities' }
DateAndTime class >> writeSQLTypeOn: aStream using: anSQLDialect [

	aStream nextPutAll: anSQLDialect datetime
]
