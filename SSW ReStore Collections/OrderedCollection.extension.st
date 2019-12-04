Extension { #name : #OrderedCollection }

{ #category : #'*SSW ReStore Collections' }
OrderedCollection >> _changesFrom: aCollectionOfEntries [

	"Return the changes made to the receiver compared to aCollectionOf(Collection)Entries.
	For an OrderedCollection, must include full keyed (indexed) changes"

	^self _keyedChangesFrom: aCollectionOfEntries
]
