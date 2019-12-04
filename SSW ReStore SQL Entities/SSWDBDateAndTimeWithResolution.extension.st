Extension { #name : #SSWDBDateAndTimeWithResolution }

{ #category : #'*SSW ReStore SQL Entities' }
SSWDBDateAndTimeWithResolution >> writeSQLTypeOn: aStream  using: anSQLDialect [

	aStream nextPutAll: (anSQLDialect datetimeWithResolution expandMacrosWith: self resolution)
]
