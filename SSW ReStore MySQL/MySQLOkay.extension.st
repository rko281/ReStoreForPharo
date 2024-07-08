Extension { #name : 'MySQLOkay' }

{ #category : '*SSW ReStore MySQL' }
MySQLOkay >> close [

	"In Dolphin this closes the result set, leaving the statement open.
	Nothing to do here"
]

{ #category : '*SSW ReStore MySQL' }
MySQLOkay >> numRows [

	^self affectedRows
]

{ #category : '*SSW ReStore MySQL' }
MySQLOkay >> rowsAffected [

	^self affectedRows
]
