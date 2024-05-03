Extension { #name : 'SSWPostgreSQLDialect' }

{ #category : '*SSW ReStore for Pharo' }
SSWPostgreSQLDialect >> platformSpecificFunctions [

	^Dictionary new
		at: #month put: ('EXTRACT(MONTH FROM %1)' asSQLFunctionWithResultClass: Month);
		yourself
]
