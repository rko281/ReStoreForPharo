"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBIDAccessor',
	#superclass : 'SSWDBPrivateAccessor',
	#category : 'SSW ReStore Tables',
	#package : 'SSW ReStore Tables'
}

{ #category : 'constants' }
SSWDBIDAccessor >> nameInDB [

	^#id_
]

{ #category : 'constants' }
SSWDBIDAccessor >> specialSymbol [

	"Accesses _id (unique ID) - this is a method defined by the object proxy"

	^#_id
]

{ #category : 'evaluating' }
SSWDBIDAccessor >> valueIn: anObject [

	"The receiver accesses the unique ID of objects.
	anObject should be DBproxy-wrapped"
	
	^anObject _id
]
