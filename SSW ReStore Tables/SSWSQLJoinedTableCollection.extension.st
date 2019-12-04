Extension { #name : #SSWSQLJoinedTableCollection }

{ #category : #'*SSW ReStore Tables' }
SSWSQLJoinedTableCollection >> add: anSSWDBTable joinedWithField: anSSWDBField [

	"Patched for issue 120-001 (revised, replaces original patch)

	Add the given table joined with the given field (match on ID fields); return the table added.
	Duplicate entries are permitted - see withoutDuplicates"

	self add: anSSWDBTable joinedWith: (SSWSQLCondition field: anSSWDBTable idField equalTo: anSSWDBField)
]

{ #category : #'*SSW ReStore Tables' }
SSWSQLJoinedTableCollection >> addAliasingDuplicates: anSSWDBTable joinedWithField: anSSWDBField [

	"Add the given table joined with the given field; return the table added.
	Unlike add:joinedWith:, duplicate occurrences of anSSWDBTable are not permitted
	 - if anSSWDBTable already occurs in the receiver, then it is aliased"

	| repetition |

	repetition := self occurrencesOfIncludingRepetitions: anSSWDBTable.

	^repetition = 0 
		ifTrue: [self add: anSSWDBTable joinedWithField: anSSWDBField]
		ifFalse: [self add: (SSWDBQueryTable forRepetition: repetition of: anSSWDBTable) 	
					joinedWithField: anSSWDBField]
]

{ #category : #'*SSW ReStore Tables' }
SSWSQLJoinedTableCollection >> joinFields [

	| joinFields |

	joinFields := OrderedCollection new.
	self joinConditions isEmpty ifTrue: [^joinFields].

	self joinConditions flattened do: [ :each | (joinFields includes: each value) ifFalse: [joinFields add: each value]].

	^joinFields
]

{ #category : #'*SSW ReStore Tables' }
SSWSQLJoinedTableCollection >> lastJoinField [

	"Patched for issue 120-001(revised)"
	
	^self joinConditions last value
]
