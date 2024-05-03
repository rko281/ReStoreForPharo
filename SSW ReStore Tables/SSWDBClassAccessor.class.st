"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWDBClassAccessor,
	#superclass : #SSWDBPrivateAccessor,
	#category : #'SSW ReStore Tables'
}

{ #category : #constants }
SSWDBClassAccessor >> nameInDB [

	^#instClass_
]

{ #category : #constants }
SSWDBClassAccessor >> specialSymbol [

	^#class
]

{ #category : #updating }
SSWDBClassAccessor >> value: valueObject in: targetObject [

	"The receiver 'accesses' the class of objects - cannot be changed"
	
	^valueObject
]

{ #category : #evaluating }
SSWDBClassAccessor >> valueIn: anObject [

	"The receiver 'accesses' the class of objects.
	anObject should be DBproxy-wrapped"
	
	^anObject class
]
