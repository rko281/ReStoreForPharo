"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWAccessor,
	#superclass : #Object,
	#category : #'SSW ReStore Tables'
}

{ #category : #initializing }
SSWAccessor >> access: aSymbol in: aClass [

	"Configure the receiver to access the inst var of aClass which is named aSymbol"
	
	self subclassResponsibility
]

{ #category : #testing }
SSWAccessor >> accesses: aSymbol [

	"Return a Boolean indicating whether the receiver access the instance variable
	named aSymbol"
	
	^self subclassResponsibility
]

{ #category : #evaluating }
SSWAccessor >> name [

	"Return the name of the inst var accessed by the receiver.
	Default - nil (unknown/undefined).
	Subclasses which can interpret this concept meaningfully should override"
	
	^nil
]

{ #category : #updating }
SSWAccessor >> value: valueObject in: targetObject [

	"Set the attribute of targetObject which the receiver accesses to valueObject"
	
	self subclassResponsibility
]

{ #category : #updating }
SSWAccessor >> valueIfChanged: valueObject in: targetObject [

	"Set the attribute of targetObject which the receiver accesses to valueObject, 
	if targetObject's current value for that attribute is different.
	Return whether it was updating or not"
	
	| currentValue |

	currentValue := self valueIn: targetObject.

	^(currentValue _hasChangedFrom: valueObject)
		ifTrue: [self value: valueObject in: targetObject. true]
		ifFalse: [false]
]

{ #category : #evaluating }
SSWAccessor >> valueIn: anObject [

	"Extract and return the value of anObject which the receiver accesses"
	
	^self subclassResponsibility
]
