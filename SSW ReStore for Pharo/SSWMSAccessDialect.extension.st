Extension { #name : 'SSWMSAccessDialect' }

{ #category : '*SSW ReStore for Pharo' }
SSWMSAccessDialect >> platformSpecificFunctions [

	^Dictionary new
		at: #month put: ('DATEPART(''m'',%1)' asSQLFunctionWithResultClass: Month);
		yourself
]
