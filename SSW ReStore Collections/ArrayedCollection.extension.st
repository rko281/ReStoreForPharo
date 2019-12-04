Extension { #name : #ArrayedCollection }

{ #category : #'*SSW ReStore Collections' }
ArrayedCollection >> _changesFrom: aCollectionOfEntries [

	"Return the changes made to the receiver compared to aCollectionOf(Collection)Entries.
	For an array, there are no additions or removals - just updates"

	| entriesSize changes |

	entriesSize := aCollectionOfEntries size. 
	changes := OrderedCollection new: (self size // 10).

	self keysAndValuesDo:
		[ :index :each |
		index > entriesSize
		ifTrue:
			[each isNil ifFalse: 
				[changes add: (SSWDBCollectionAddition added: each at: index)]]
		ifFalse:
			[| entry |
			entry := aCollectionOfEntries at: index.
			entry target == each ifFalse: 
				[changes add: (SSWDBCollectionUpdate entry: entry newTarget: each)]]].

	^changes
]

{ #category : #'*SSW ReStore Collections' }
ArrayedCollection >> directAdd: anObject suggestedIndex: anInteger [

	"Translate to at:put:"

	^self at: anInteger put: anObject


]
