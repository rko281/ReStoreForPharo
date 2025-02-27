Class {
	#name : 'UUIDOwnedSubTest',
	#superclass : 'UUIDOwnedTest',
	#instVars : [
		'number'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
UUIDOwnedSubTest class >> reStoreDefinition [

	^super reStoreDefinition
		define: #number as: Integer;
		yourself
]

{ #category : 'public' }
UUIDOwnedSubTest class >> shouldInheritPersistency [

	^true
]

{ #category : 'accessing' }
UUIDOwnedSubTest >> number [
	^number
]

{ #category : 'accessing' }
UUIDOwnedSubTest >> number: anObject [
	number := anObject
]
