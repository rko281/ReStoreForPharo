Class {
	#name : #WeakIdentityDictionary,
	#superclass : #WeakIdentityValueDictionary,
	#category : #Wolphin
}

{ #category : #'instance creation' }
WeakIdentityDictionary class >> newWithWeakKeys: anInteger [

	^WeakIdentityKeyDictionary new: anInteger
]
