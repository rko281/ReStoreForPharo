"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBVersionAccessor',
	#superclass : 'SSWDBPrivateAccessor',
	#category : 'SSW ReStore Tables',
	#package : 'SSW ReStore Tables'
}

{ #category : 'constants' }
SSWDBVersionAccessor >> nameInDB [

	^#version_
]

{ #category : 'constants' }
SSWDBVersionAccessor >> specialSymbol [

	"Accesses _version - this is a method defined by the object proxy"

	^#_version
]

{ #category : 'updating' }
SSWDBVersionAccessor >> value: valueObject in: targetObject [

	"The receiver accesses the version number of objects.
	targetObject should be DBproxy-wrapped"
	
	targetObject _version: valueObject.
	^valueObject
]

{ #category : 'evaluating' }
SSWDBVersionAccessor >> valueIn: anObject [

	"The receiver accesses the version number of objects.
	anObject should be DBproxy-wrapped"
	
	^anObject _version
]
