Extension { #name : #SSWSQLConditionCollection }

{ #category : #'*SSW ReStore Tables' }
SSWSQLConditionCollection >> copyForQueryTable: aQueryTable [

	"Created for issue 120-015

	Return a copy of the receiver with all fields changed to QueryTableFields assigned to aQueryTable"

	^self collect: [ :each | each copyForQueryTable: aQueryTable]

	
]
