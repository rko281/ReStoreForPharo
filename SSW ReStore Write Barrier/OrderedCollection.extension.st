Extension { #name : 'OrderedCollection' }

{ #category : '*SSW ReStore Write Barrier' }
OrderedCollection >> compact [
	"remove all empty slots to the end of array, while keeping the empty slots at the front."

    | newArray |
    newArray := self class arrayType new: lastIndex.
    newArray
        replaceFrom: firstIndex
        to: lastIndex
        with: array
        startingAt: firstIndex.
    array := newArray.
	self setArrayImmutability
]

{ #category : '*SSW ReStore Write Barrier' }
OrderedCollection >> growAtFirst [
	"Add new empty slots to the front of array, while keeping the empty slots at the end."

	"OrderedCollection new capacity >>> 10"
	"(OrderedCollection new growAtFirst; capacity) >>> 20"


	| newArray newFirstIndex newLastIndex |
	newArray := self class arrayType new: (array size * 2 max: 1).
	newFirstIndex := newArray size - array size + firstIndex.
	newLastIndex := newFirstIndex + lastIndex - firstIndex.
	newArray
		replaceFrom: newFirstIndex
		to: newLastIndex
		with: array
		startingAt: firstIndex.
	array := newArray.
	firstIndex := newFirstIndex.
	lastIndex := newLastIndex.
	self setArrayImmutability
]

{ #category : '*SSW ReStore Write Barrier' }
OrderedCollection >> growAtLast [
	"Add new empty slots to the end of array, while keeping the empty slots at the front."

	"OrderedCollection new capacity >>> 10"
	"(OrderedCollection new growAtLast; capacity) >>> 20"

	| newArray |
	newArray := self class arrayType new: (array size * 2 max: 1).
	newArray
		replaceFrom: firstIndex
		to: lastIndex
		with: array
		startingAt: firstIndex.
	array := newArray.
	self setArrayImmutability
]

{ #category : '*SSW ReStore Write Barrier' }
OrderedCollection >> isDBImmutable: aBoolean [

	super isDBImmutable: aBoolean.
	array 
		isImmutable: aBoolean;
		dbImmutabilityHandler: self
]

{ #category : '*SSW ReStore Write Barrier' }
OrderedCollection >> postCopy [
	array := array copy.
	self setArrayImmutability
]

{ #category : '*SSW ReStore Write Barrier' }
OrderedCollection >> postCopyFrom: startIndex to: endIndex [
	"finish copying the array in a certain range."

	endIndex < startIndex ifFalse: [
		"Because actual size of the array may be greater than used size,
		postCopyFrom:to: may fail to fail and answer an incorrect result
		if this sanity check were not applied."
		(startIndex between: 1 and: self size) ifFalse: [^SubscriptOutOfBounds signalFor: startIndex lowerBound: (1 min: self size) upperBound: self size in: self].
		(endIndex between: 1 and: self size) ifFalse: [^SubscriptOutOfBounds signalFor: endIndex lowerBound: (1 min: self size) upperBound: self size in: self]].

	"Add a protection that lacks in Array>>postcopy"
	array := array copyFrom: startIndex + firstIndex - 1 to: (endIndex max: startIndex - 1) + firstIndex - 1.
	firstIndex := 1.
	lastIndex := array size.
	self setArrayImmutability
]

{ #category : '*SSW ReStore Write Barrier' }
OrderedCollection >> setArrayImmutability [

	self isImmutable ifTrue: 
		[ array 
			isImmutable: true;
			dbImmutabilityHandler: self ]
]

{ #category : '*SSW ReStore Write Barrier' }
OrderedCollection >> setCollection: anArray [
	array := anArray.
	self reset.
	self setArrayImmutability
]

{ #category : '*SSW ReStore Write Barrier' }
OrderedCollection >> setContents: anArray [
	array := anArray.
	firstIndex := 1.
	lastIndex := array size.
	self setArrayImmutability
]
