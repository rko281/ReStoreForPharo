Class {
	#name : 'SSWReStoreUUIDSubTest',
	#superclass : 'SSWReStoreUUIDTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'running' }
SSWReStoreUUIDSubTest >> addClassesTo: aReStore [

	aReStore addClassWithSubclasses: UUIDOwnedTest
]

{ #category : 'running' }
SSWReStoreUUIDSubTest >> testClass [

	^UUIDOwnedSubTest
]
