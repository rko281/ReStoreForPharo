Extension { #name : #SSWSQLServerDialect }

{ #category : #'*SSW ReStore for Pharo' }
SSWSQLServerDialect >> platformSpecificFunctions [

	^Dictionary new
		at: #month put: ('MONTH(%1)' asSQLFunctionWithResultClass: Month);
		yourself
]
