Extension { #name : 'SSWDBDateAndTimeTimezoneAware' }

{ #category : '*SSW ReStore SQL Entities' }
SSWDBDateAndTimeTimezoneAware >> writeSQLTypeOn: aStream  using: anSQLDialect [

	self resolution isNil 
		ifTrue: [aStream nextPutAll: (anSQLDialect datetimeTimezoneAware ifNil: [anSQLDialect datetime])]
		ifFalse: [aStream nextPutAll: ((anSQLDialect datetimeTimezoneAwareWithResolution ifNil: [anSQLDialect datetimeWithResolution]) expandMacrosWith: self resolution)]
]
