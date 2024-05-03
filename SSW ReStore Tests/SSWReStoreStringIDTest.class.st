Class {
	#name : #SSWReStoreStringIDTest,
	#superclass : #SSWReStoreAlternativeIDTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #constants }
SSWReStoreStringIDTest >> testClass [

	^StringIDOwnedTest
]

{ #category : #'unit tests' }
SSWReStoreStringIDTest >> testQueryStringID [

	| obj id |

	obj := self testInstances detect: [:each | each name = 'test'].
	id := obj _id.

	self assert: (self testInstances detect: [:each | each _id = id] ifNone: [nil]) identicalTo: obj.
	self assert: (self testInstances detect: [:each | each _id = 'blahblah'] ifNone: [nil]) equals: nil
]

{ #category : #'unit tests' }
SSWReStoreStringIDTest >> testVerifyIDIsString [

	| obj id |

	obj := self testInstances detect: [:each | each name = 'test'].

	id := obj _id.
	self assert: (id isKindOf: String).
	self assert: (Integer readFrom: id readStream) > (Time millisecondClockValue - 10000) "Allow 10secs from creating test data to here"
]
