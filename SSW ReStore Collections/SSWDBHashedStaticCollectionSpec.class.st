Class {
	#name : 'SSWDBHashedStaticCollectionSpec',
	#superclass : 'SSWDBStaticCollectionSpec',
	#category : 'SSW ReStore Collections',
	#package : 'SSW ReStore Collections'
}

{ #category : 'change detection' }
SSWDBHashedStaticCollectionSpec >> changesTo: aCollection from: aCollectionOfEntries [

	"Return the changes made to aCollection compared to aCollectionOf(Collection)Entries"

	^self shouldCompareChangesByEquality
		ifTrue: [self equalityChangesTo: aCollection from: aCollectionOfEntries]
		ifFalse: [self identityChangesTo: aCollection from: aCollectionOfEntries]
]

{ #category : 'change detection' }
SSWDBHashedStaticCollectionSpec >> equalityChangesTo: aCollection from: aCollectionOfEntries [

	"Return the changes made to aCollection compared to aCollectionOf(Collection)Entries, comparing via equality (=)"

	| changes previous |

	changes := OrderedCollection new.
	previous := aCollectionOfEntries collect: [ :entry | entry target].

	aCollection do: [ :each | (previous includes: each) ifFalse: [changes add: (SSWDBCollectionAddition added: each)]].
	aCollectionOfEntries do: [ :entry | (aCollection includes: entry target) ifFalse: [changes add: (SSWDBCollectionRemoval newWithEntry: entry)]].

	^changes
]

{ #category : 'change detection' }
SSWDBHashedStaticCollectionSpec >> identityChangesTo: aCollection from: aCollectionOfEntries [

	"Return the changes made to aCollection compared to aCollectionOf(Collection)Entries, comparing via identity (==)"

	| changes previous |

	changes := OrderedCollection new.
	previous := aCollectionOfEntries collect: [ :entry | entry target].

	aCollection do: [ :each | (previous identityIncludes: each) ifFalse: [changes add: (SSWDBCollectionAddition added: each)]].
	aCollectionOfEntries do: [ :entry | (aCollection identityIncludes: entry target) ifFalse: [changes add: (SSWDBCollectionRemoval newWithEntry: entry)]].

	^changes
]
