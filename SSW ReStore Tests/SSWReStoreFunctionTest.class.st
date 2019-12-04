"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreFunctionTest,
	#superclass : #SSWReStoreQueryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreFunctionTest class >> shouldInheritSelectors [

	^false
]

{ #category : #'unit tests' }
SSWReStoreFunctionTest >> testConditionAsFunctionReceiver [

	"Test where the a function is applied to a condition rather than a field.
	Previously unsupported"

	| results |

	results := (SimplePerson storedInstancesIn: reStore) collect: [ :each | each || ((each age > 20) then: 'old' else: 'young')].

	self assert: (results allSatisfy: [ :each | each first age > 20 ifTrue: [each last = 'old'] ifFalse: [each last = 'young']])
]

{ #category : #'unit tests' }
SSWReStoreFunctionTest >> testModelClassAsFunctionReceiver [

	"Test where the receiver of a function is a model class (as opposed to Number, String etc. type).
	Previously unsupported"

	| results |

	results := (SimplePerson storedInstancesIn: reStore) collect: [ :each | each || (each friend ifNull: each ifNotNull: each friend)].

	self assert: (results allSatisfy: [ :each | each first friend isNil ifTrue: [each last == each first] ifFalse: [each last == each first friend]])
]

{ #category : #'unit tests' }
SSWReStoreFunctionTest >> testModelClassAsFunctionReceiverWithJoin [

	"Test where the receiver of a function is a model class (as opposed to Number, String etc. type), where there are multiple function classes encountered in the function, including a join.
	Previously failed"

	| persons results |

	persons := SimplePerson storedInstancesIn: reStore.
	(persons detect: [ :each | each fullName = 'John Smith']) address: (SimpleAddress new line1: 'somewhere'; yourself); store.

	"Previously the 'each friend' final argument to the function overrode the 'each friend address' receiver. Ensure this is no longer the case"
	results := (SimplePerson storedInstancesIn: reStore) collect: [ :each | each || (each friend address ifNull: each ifNotNull: each friend)].

	self assert: 
		(results allSatisfy: 
			[ :each || person result |
			person := each first.
			result := each last.
			(person friend isNil or: [person friend address isNil])
				ifTrue: [result == person] 
				ifFalse: [result == person friend]])
]

{ #category : #'unit tests' }
SSWReStoreFunctionTest >> testStaticValueAsFunctionResult [

	"Test where the result of a function is a fixed value, not a field"

	| results |

	results := (SimplePerson storedInstancesIn: reStore) collect: [ :each | each || (each friend ifNull: 1 ifNotNull: 2)].

	self assert: (results allSatisfy: [ :each | each first friend isNil ifTrue: [each last = 1] ifFalse: [each last = 2]])
]

{ #category : #'unit tests' }
SSWReStoreFunctionTest >> testTargetFieldFromArgument [

	"Test where the result of a function is the class of an argument, not the class of the receiver"

	| results |

	results := (SimplePerson storedInstancesIn: reStore) collect: [ :each | each || ((each age > 20) then: each else: each friend)].

	self assert: (results allSatisfy: [ :each | each first age > 20 ifTrue: [each last == each first] ifFalse: [each last == each first friend]])
]
