"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'GenericOwnedTest',
	#superclass : 'Test',
	#instVars : [
		'owner',
		'key',
		'deepTest'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
GenericOwnedTest class >> reStoreDefinition [

	^super reStoreDefinition
		define: #owner as: GenericTest;
		define: #key as: (String maxSize: 128);
		define: #deepTest as: Test dependent;
		yourself
]

{ #category : 'accessing' }
GenericOwnedTest >> deepTest [
	^deepTest
]

{ #category : 'accessing' }
GenericOwnedTest >> deepTest: anObject [
	deepTest := anObject
]

{ #category : 'accessing' }
GenericOwnedTest >> key [
	^key
]

{ #category : 'accessing' }
GenericOwnedTest >> key: anObject [
	key := anObject
]

{ #category : 'accessing' }
GenericOwnedTest >> owner [
	"Private - Answer the value of the receiver's ''owner'' instance variable."

	^owner
]

{ #category : 'accessing' }
GenericOwnedTest >> owner: anObject [
	"Private - Set the value of the receiver's ''owner'' instance variable to the argument, anObject."

	owner := anObject
]
