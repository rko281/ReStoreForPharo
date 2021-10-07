Class {
	#name : #StringIDOwnedTest,
	#superclass : #UUIDOwnedTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #persistence }
StringIDOwnedTest class >> reStoreIDClass [

	^String maxSize: 32
]

{ #category : #persistence }
StringIDOwnedTest >> reStoreNewUniqueID [

	(Delay forMilliseconds: 1) wait.
	^Time millisecondClockValue printString
]
