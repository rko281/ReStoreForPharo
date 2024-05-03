Extension { #name : 'SSWMySQLDialect' }

{ #category : '*SSW ReStore for Pharo' }
SSWMySQLDialect >> platformSpecificFunctions [

	^Dictionary new
		at: #month put: ('MONTH(%1)' asSQLFunctionWithResultClass: Month);
		yourself
]
