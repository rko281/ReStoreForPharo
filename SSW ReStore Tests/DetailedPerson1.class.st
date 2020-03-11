"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #DetailedPerson1,
	#superclass : #SuperPerson,
	#instVars : [
		'friend2'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
DetailedPerson1 class >> reStoreDefinition [

	^super reStoreDefinition
		define: #friend2 as: DetailedPerson2;
		yourself
]

{ #category : #accessing }
DetailedPerson1 >> friend2 [
	^friend2
]

{ #category : #accessing }
DetailedPerson1 >> friend2: anObject [
	friend2 := anObject
]
