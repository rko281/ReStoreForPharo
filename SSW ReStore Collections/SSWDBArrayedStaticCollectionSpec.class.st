Class {
	#name : #SSWDBArrayedStaticCollectionSpec,
	#superclass : #SSWDBOrderedStaticCollectionSpec,
	#category : #'SSW ReStore Collections'
}

{ #category : #'change detection' }
SSWDBArrayedStaticCollectionSpec >> changesTo: aCollection from: aCollectionOfEntries [

	"Return the changes made to aCollection compared to aCollectionOf(Collection)Entries.
	For an array, there are no additions or removals - just updates"

	| entriesSize changes |

	entriesSize := aCollectionOfEntries size. 
	changes := OrderedCollection new: (aCollection size // 10).

	aCollection keysAndValuesDo:
		[ :index :each || entry |
		index > entriesSize
		ifTrue:
			[each isNil ifFalse: [changes add: (SSWDBCollectionAddition added: each at: index)]]
		ifFalse:
			[entry := aCollectionOfEntries at: index.
			(entry target == each or: [self shouldCompareChangesByEquality and: [entry target = each]]) ifFalse: [changes add: (SSWDBCollectionUpdate entry: entry newTarget: each)]]].

	^changes
]
