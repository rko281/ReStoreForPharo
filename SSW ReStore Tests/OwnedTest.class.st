"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'OwnedTest',
	#superclass : 'Test',
	#instVars : [
		'owner'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
OwnedTest class >> reStoreDefinition [

	^super reStoreDefinition
		define: #owner as: OwnerTest;
		yourself
]

{ #category : 'accessing' }
OwnedTest >> owner [
	"Private - Answer the value of the receiver's ''owner'' instance variable."

	^owner
]

{ #category : 'accessing' }
OwnedTest >> owner: anObject [
	"Private - Set the value of the receiver's ''owner'' instance variable to the argument, anObject."

	owner := anObject
]

{ #category : 'public' }
OwnedTest >> testOnRollback [

	self owner name
]
