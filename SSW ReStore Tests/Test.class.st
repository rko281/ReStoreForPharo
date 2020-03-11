"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #Test,
	#superclass : #Object,
	#instVars : [
		'name'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
Test class >> reStoreDefinition [

	^super reStoreDefinition
		define: #name as: (String maxSize: 128);
		yourself
]

{ #category : #comparing }
Test >> <= a [

	^self name <= a name
]

{ #category : #comparing }
Test >> = a [

	^self name = a name
]

{ #category : #public }
Test >> handleUpdateClash: aSymbol from: old to: new [

	aSymbol = #name ifFalse: [^false].
	(new name beginsWith: 'BLOCK') ifTrue: [^false].

	self name: (self name, ' (overriden ', new name, ')').
	^true
]

{ #category : #comparing }
Test >> hash [

	^self name hash
]

{ #category : #accessing }
Test >> name [
	"Private - Answer the value of the receiver's ''name'' instance variable."

	^name
]

{ #category : #accessing }
Test >> name: anObject [
	"Private - Set the value of the receiver's ''name'' instance variable to the argument, anObject."

	name := anObject
]

{ #category : #public }
Test >> printOn: aStream [

	aStream nextPutAll: self name
]
