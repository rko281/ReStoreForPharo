Class {
	#name : #StringIDOwnedTest,
	#superclass : #UUIDOwnedTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
StringIDOwnedTest class >> reStoreIDClass [

	^String maxSize: 32
]

{ #category : #public }
StringIDOwnedTest >> reStoreNewUniqueID [

	(Delay forMilliseconds: 1) wait.
	^Time millisecondClockValue printString
]
