Extension { #name : #HashedCollection }

{ #category : #'*SSW ReStore for Pharo' }
HashedCollection >> _changesFrom: aSetOfEntries [

	"Private - 20/5/2001

	Return the changes made to the receiver compared to aSetOf(Collection)Entries.
	For a Set, consider additions and removals and removal only"

	| changes oldSet |

	changes := OrderedCollection new.
	oldSet := aSetOfEntries collect: [ :entry | entry target].

	self do: [ :each | (oldSet identityIncludes: each) ifFalse: 
						[changes add: (SSWDBCollectionAddition added: each)]].

	aSetOfEntries do: [ :entry | (self identityIncludes: entry target) ifFalse: 
						[changes add: (SSWDBCollectionRemoval newWithEntry: entry)]].

	^changes
]
