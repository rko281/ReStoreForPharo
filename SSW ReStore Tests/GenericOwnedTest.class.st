"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #GenericOwnedTest,
	#superclass : #Test,
	#instVars : [
		'owner',
		'deepTest'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
GenericOwnedTest class >> reStoreDefinition [

	^super reStoreDefinition
		define: #owner as: GenericTest;
		define: #deepTest as: Test dependent;
		yourself
]

{ #category : #public }
GenericOwnedTest class >> shouldInheritPersistency [

	^true
]

{ #category : #accessing }
GenericOwnedTest >> deepTest [
	^deepTest
]

{ #category : #accessing }
GenericOwnedTest >> deepTest: anObject [
	deepTest := anObject
]

{ #category : #accessing }
GenericOwnedTest >> owner [
	"Private - Answer the value of the receiver's ''owner'' instance variable."

	^owner
]

{ #category : #accessing }
GenericOwnedTest >> owner: anObject [
	"Private - Set the value of the receiver's ''owner'' instance variable to the argument, anObject."

	owner := anObject
]
