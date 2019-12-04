"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBUnstoreWrapper,
	#superclass : #SSWDBWrapper,
	#category : #'SSW ReStore Main'
}

{ #category : #testing }
SSWDBUnstoreWrapper >> _checkHasChangedIn: aReStore [

	"Unstored, therefore changed"

	^true
]

{ #category : #operations }
SSWDBUnstoreWrapper >> _commitIn: anSSWReStore [

	"Commit the wrapped object by unstoring it"

	self object unstore
]
