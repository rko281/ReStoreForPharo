"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWDBIDAccessor,
	#superclass : #SSWDBPrivateAccessor,
	#instVars : [
		'instanceAccessor'
	],
	#category : #'SSW ReStore Tables'
}

{ #category : #testing }
SSWDBIDAccessor >> accesses: aSymbol [

	"Additionally check the instanceAccessor"
	
	^(super accesses: aSymbol) or: 
		[self instanceAccessor notNil and: [self instanceAccessor accesses: aSymbol]]
]

{ #category : #accessing }
SSWDBIDAccessor >> instanceAccessor [

	"instanceAccessor optionally stores an SSWInstVarAccessor that is used to assign 
	the ID value to actual persistent object instances (in addition to their proxy).

	By default this is nil - persistent objects do not normally store their ID
	If changed to a SSWInstVarAccessor, the ID value is assigned to an instance variable"

	^instanceAccessor
]

{ #category : #accessing }
SSWDBIDAccessor >> instanceAccessor: anSSWAccessor [

	"instanceAccessor optionally stores an SSWInstVarAccessor that is used to assign 
	the ID value to actual persistent object instances (in addition to their proxy).

	By default this is nil - persistent objects do not normally store their ID
	If changed to a SSWInstVarAccessor, the ID value is assigned to an instance variable"

	instanceAccessor := anSSWAccessor
]

{ #category : #constants }
SSWDBIDAccessor >> nameInDB [

	^#id_
]

{ #category : #constants }
SSWDBIDAccessor >> specialSymbol [

	"Accesses _id (unique ID) - this is a method defined by the object proxy"

	^#_id
]

{ #category : #updating }
SSWDBIDAccessor >> value: valueObject in: targetObject [

	"The receiver accesses the unique ID of objects.
	However it never explicity sets the ID of a proxy (a proxy is created with this).
	Instead, it's instanceAccessor may set the ID within the persistent object itself"
	
	self instanceAccessor ~~ nil ifTrue: 
		[self instanceAccessor value: valueObject in: targetObject _proxiedObject].
	^valueObject
]

{ #category : #evaluating }
SSWDBIDAccessor >> valueIn: anObject [

	"The receiver accesses the unique ID of objects.
	anObject should be DBproxy-wrapped"
	
	^anObject _id
]
