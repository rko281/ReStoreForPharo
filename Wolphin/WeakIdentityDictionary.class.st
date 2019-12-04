Class {
	#name : #WeakIdentityDictionary,
	#superclass : #WeakIdentityKeyDictionary,
	#category : #Wolphin
}

{ #category : #'instance creation' }
WeakIdentityDictionary class >> newWithWeakKeys: anInteger [

	^self new: anInteger
]
