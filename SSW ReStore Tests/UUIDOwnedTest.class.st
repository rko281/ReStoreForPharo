Class {
	#name : #UUIDOwnedTest,
	#superclass : #OwnedTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #persistence }
UUIDOwnedTest class >> reStoreIDClass [

	^GUID
]

{ #category : #persistence }
UUIDOwnedTest class >> shouldInheritPersistency [

	^false
]
