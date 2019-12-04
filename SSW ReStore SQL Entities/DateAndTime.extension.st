Extension { #name : #DateAndTime }

{ #category : #'*SSW ReStore SQL Entities' }
DateAndTime >> asSQLStringIn: aSQLDialect [

	^aSQLDialect dateAndTimeStringFor: self
]

{ #category : #'*SSW ReStore SQL Entities' }
DateAndTime >> withoutMilliseconds [

	"ODBC Timestamps may or may not include milliseconds (or may have a ms resolution > 1), hence it can be useful/necessary to drop milliseconds for comparison purposes"

	^self - (Duration nanoseconds: self nanosecond)
]

{ #category : #'*SSW ReStore SQL Entities' }
DateAndTime class >> writeSQLTypeOn: aStream using: anSQLDialect [

	aStream nextPutAll: anSQLDialect datetime
]
