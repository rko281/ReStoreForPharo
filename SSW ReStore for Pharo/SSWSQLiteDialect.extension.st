Extension { #name : 'SSWSQLiteDialect' }

{ #category : '*SSW ReStore for Pharo' }
SSWSQLiteDialect >> platformSpecificFunctions [

	^Dictionary new
		at: #month put: ('CAST(STRFTIME(''%%m'',%1) AS INTEGER)' asSQLFunctionWithResultClass: Month);
		yourself
]
