Extension { #name : 'SSWSQLCondition' }

{ #category : '*SSW ReStore Tables' }
SSWSQLCondition >> copyForQueryTable: aQueryTable [

	"Created for issue 120-015

	Return a copy of the receiver with the field changed to QueryTableFields assigned to aQueryTable"

	^self copy
		field: (SSWDBQueryTableField forField: self field in: aQueryTable);
		yourself
	
]
