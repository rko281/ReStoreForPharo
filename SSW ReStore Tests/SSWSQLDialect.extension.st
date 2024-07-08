Extension { #name : 'SSWSQLDialect' }

{ #category : '*SSW ReStore Tests' }
SSWSQLDialect >> shouldDropTablesForTestCases [

	"For efficiency during SUnit test runs, for some databases we don't drop tables (this can take a long time) but erase all data instead.
	Return true to drop tables prior to a test, false to erase data instead"

	^true
]
