Class {
	#name : 'TestWithBitmask',
	#superclass : 'Test',
	#instVars : [
		'number1',
		'number2',
		'bitmask',
		'orderedCollection',
		'sortedCollection',
		'array',
		'set',
		'dictionary'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'instance creation' }
TestWithBitmask class >> new [

	^super new
		bitmask: TestBitmask new;
		orderedCollection: OrderedCollection new;
		sortedCollection: SortedCollection new;
		array: (Array new: 8);
		set: Set new;
		dictionary: Dictionary new;
		yourself
]

{ #category : 'persistency' }
TestWithBitmask class >> reStoreDefinition [

	^super reStoreDefinition

		"These two are just here so the bitmask accessor is out of range for SSWDBDeletedObject (see SSWReStoreDirectlyPersistedTest>>testDeletedObjectRecovery)"
		define: #number1 as: Integer;
		define: #number2 as: Integer;

		define: #bitmask as: TestBitmask;
		define: #orderedCollection as: (OrderedCollection of: TestBitmask);
		define: #sortedCollection as: (SortedCollection of: TestBitmask);
		define: #array as: ((Array new: 8) of: TestBitmask);
		define: #set as: (Set of: TestBitmask);
		define: #dictionary as: (Dictionary of: TestBitmask -> TestBitmask);
		yourself
]

{ #category : 'persistency' }
TestWithBitmask class >> shouldInheritPersistency [

	^false
]

{ #category : 'accessing' }
TestWithBitmask >> array [
	^array
]

{ #category : 'accessing' }
TestWithBitmask >> array: anObject [
	array := anObject
]

{ #category : 'accessing' }
TestWithBitmask >> bitmask [
	^bitmask
]

{ #category : 'accessing' }
TestWithBitmask >> bitmask: anObject [
	bitmask := anObject
]

{ #category : 'accessing' }
TestWithBitmask >> dictionary [
	^dictionary
]

{ #category : 'accessing' }
TestWithBitmask >> dictionary: anObject [
	dictionary := anObject
]

{ #category : 'accessing' }
TestWithBitmask >> number1 [
	^number1
]

{ #category : 'accessing' }
TestWithBitmask >> number1: anObject [
	number1 := anObject
]

{ #category : 'accessing' }
TestWithBitmask >> number2 [
	^number2
]

{ #category : 'accessing' }
TestWithBitmask >> number2: anObject [
	number2 := anObject
]

{ #category : 'accessing' }
TestWithBitmask >> orderedCollection [
	^orderedCollection
]

{ #category : 'accessing' }
TestWithBitmask >> orderedCollection: anObject [
	orderedCollection := anObject
]

{ #category : 'accessing' }
TestWithBitmask >> set [
	^set
]

{ #category : 'accessing' }
TestWithBitmask >> set: anObject [
	set := anObject
]

{ #category : 'accessing' }
TestWithBitmask >> sortedCollection [
	^sortedCollection
]

{ #category : 'accessing' }
TestWithBitmask >> sortedCollection: anObject [
	sortedCollection := anObject
]
