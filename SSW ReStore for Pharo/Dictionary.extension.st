Extension { #name : 'Dictionary' }

{ #category : '*SSW ReStore for Pharo' }
Dictionary >> _superValuesRemovedBy: aCollectionOfChanges [

	"Pass-thru to default implementation of _valuesRemovedBy: for benefit of non-Set subclasses
	(Dictionary is a subclass of Set in Dolphin)"

	^super _valuesRemovedBy: aCollectionOfChanges

]
