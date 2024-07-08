Class {
	#name : 'SSWMutableInstVarAccessor',
	#superclass : 'SSWInstVarAccessor',
	#category : 'SSW ReStore Tables',
	#package : 'SSW ReStore Tables'
}

{ #category : 'evaluating' }
SSWMutableInstVarAccessor >> copyValue: anObject in: targetObject [

	"Since the receiver accesses mutable objects we must perform a copy"

	self value: anObject copy in: targetObject
]

{ #category : 'evaluating' }
SSWMutableInstVarAccessor >> copyValueIn: sourceObject to: targetObject [

	"Since the receiver accesses mutable objects we must perform a copy"

	self copyValue: (self valueIn: sourceObject) in: targetObject
]
