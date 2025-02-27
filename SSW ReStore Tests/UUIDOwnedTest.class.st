Class {
	#name : 'UUIDOwnedTest',
	#superclass : 'GenericOwnedTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
UUIDOwnedTest class >> reStoreIDClass [

	^GUID
]

{ #category : 'public' }
UUIDOwnedTest class >> shouldInheritPersistency [

	^false
]
