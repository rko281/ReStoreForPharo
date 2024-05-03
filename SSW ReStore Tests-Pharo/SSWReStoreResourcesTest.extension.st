Extension { #name : #SSWReStoreResourcesTest }

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreResourcesTest >> _testStatementFreedAfter: aBlock [

	| templateStatement prevStatements newStatements |

	templateStatement := reStore prepareStatementForQuery: (SSWSQLSelectQuery new table: (reStore tableForClass: SimplePerson); conditions: #(); yourself).
	prevStatements := templateStatement class allInstances.

	aBlock value.
	newStatements := templateStatement class allInstances difference: prevStatements.
	self assert: (newStatements allSatisfy: [ :each | each isFreed]).

	templateStatement free
]
