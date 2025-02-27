Extension { #name : 'SSWSQLTableCollection' }

{ #category : '*SSW ReStore Tables' }
SSWSQLTableCollection >> occurrencesOfIncludingRepetitions: aTable [

	"Return the number of occurrences of the given table in the receiver.
	Include any previous repetitions, disguised as QueryTables"

	"Each table can appear only once as itself.
	If it does not appear once, then there are no repetitions"
	(self includes: aTable) ifFalse: [^0].

	^(self select: [ :table | (table class = SSWDBQueryTable) and: [table table == aTable]]) size + 1
]
