"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SubPerson,
	#superclass : #MidPerson,
	#instVars : [
		'age',
		'subFlags'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #constants }
SubPerson class >> mutableAspects [
	^super mutableAspects copyWith: #subFlags.
]

{ #category : #public }
SubPerson class >> reStoreDefinition [
	^super reStoreDefinition
		define: #age as: Integer;
		define: #subFlags as: TestBitmask;
		yourself.
]

{ #category : #accessing }
SubPerson >> age [
	^age
]

{ #category : #accessing }
SubPerson >> age: anObject [
	age := anObject
]

{ #category : #initializing }
SubPerson >> initialize [
	super initialize.
	subFlags := TestBitmask new.
]

{ #category : #accessing }
SubPerson >> subFlags [
	^subFlags.
]
