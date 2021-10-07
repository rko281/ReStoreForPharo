Class {
	#name : #SSWReStoreUUIDTest,
	#superclass : #SSWReStoreAlternativeIDTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #constants }
SSWReStoreUUIDTest >> testClass [

	^UUIDOwnedTest
]

{ #category : #running }
SSWReStoreUUIDTest >> testQueryUUID_ID [

	| obj id |

	obj := self testInstances detect: [:each | each name = 'test'].
	id := obj _id.

	self assert: (self testInstances detect: [:each | each _id = id] ifNone: [nil]) identicalTo: obj.
	self assert: (self testInstances detect: [:each | each _id = GUID newUnique] ifNone: [nil]) equals: nil
]

{ #category : #running }
SSWReStoreUUIDTest >> testVerifyIDIsUUID [

	| obj id |

	obj := self testInstances detect: [:each | each name = 'test'].

	id := obj _id.
	self assert: (id class name = #GUID or: [id class name = #UUID]). "Dolphin/Pharo"
]
