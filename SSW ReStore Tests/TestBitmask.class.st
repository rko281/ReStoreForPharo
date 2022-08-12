Class {
	#name : #TestBitmask,
	#superclass : #SSWDBDirectlyPersistedObject,
	#instVars : [
		'value'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #'instance creation' }
TestBitmask class >> fromReStoreValue: aValue [

	^aValue ifNotNil: 
		[self new 
			value: aValue;
			yourself]
]

{ #category : #testing }
TestBitmask class >> hasMutablePersistentInstances [

	^true
]

{ #category : #'instance creation' }
TestBitmask class >> new [
	^super new initialize
]

{ #category : #accessing }
TestBitmask class >> reStoreValueClass [

	^Integer
]

{ #category : #'instance creation' }
TestBitmask class >> value: anInteger [

	^self new 
		value: anInteger; 
		yourself
]

{ #category : #public }
TestBitmask >> bitAnd2 [

	^self value & 2
]

{ #category : #public }
TestBitmask >> bitSet: anInteger [

	value := value setBit: anInteger
]

{ #category : #'initialize/release' }
TestBitmask >> initialize [

	value := 0
]

{ #category : #testing }
TestBitmask >> isBitSet: anInteger [

	"Implement directly for database in form that can be translated to SQL for queries"

	^self 
		imageDo: [self value isBitSet: anInteger] 
		databaseDo: [(self value & (2 ** (anInteger - 1))) > 0]
]

{ #category : #accessing }
TestBitmask >> reStoreValue [

	^self value
]

{ #category : #accessing }
TestBitmask >> value [
	^value
]

{ #category : #accessing }
TestBitmask >> value: anObject [
	value := anObject
]
