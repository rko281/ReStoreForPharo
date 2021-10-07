Class {
	#name : #SSWReStoreUUIDSubTest,
	#superclass : #SSWReStoreUUIDTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #tests }
SSWReStoreUUIDSubTest >> addClassesTo: aReStore [

	aReStore addClassWithSubclasses: UUIDOwnedTest
]

{ #category : #tests }
SSWReStoreUUIDSubTest >> testClass [

	^UUIDOwnedSubTest
]
