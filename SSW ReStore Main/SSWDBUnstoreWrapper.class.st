"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBUnstoreWrapper',
	#superclass : 'SSWDBWrapper',
	#category : 'SSW ReStore Main',
	#package : 'SSW ReStore Main'
}

{ #category : 'testing' }
SSWDBUnstoreWrapper >> _checkHasChangedIn: aReStore [

	"Unstored, therefore changed"

	^true
]

{ #category : 'operations' }
SSWDBUnstoreWrapper >> _commitIn: anSSWReStore [

	"Commit the wrapped object by unstoring it"

	self object unstore
]

{ #category : 'accessing' }
SSWDBUnstoreWrapper >> _dbProxyIfNone: aBlock [

	^self object _dbProxyIfNone: aBlock
]

{ #category : 'accessing' }
SSWDBUnstoreWrapper >> _reStoreIfNone: aBlock [

	^self object _reStoreIfNone: aBlock
]
