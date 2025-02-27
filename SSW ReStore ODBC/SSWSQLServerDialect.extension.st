Extension { #name : 'SSWSQLServerDialect' }

{ #category : '*SSW ReStore ODBC' }
SSWSQLServerDialect >> canDescribeParameters [

	"Appears to be supported by the native ODBC driver, but flaky (doesn't work with > 1 param?), so let's act as if it doesn't work"

	^false
]
