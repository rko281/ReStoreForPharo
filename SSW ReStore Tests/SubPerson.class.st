"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SubPerson,
	#superclass : #MidPerson,
	#instVars : [
		'age'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SubPerson class >> reStoreDefinition [

	^super reStoreDefinition
		define: #age as: Integer;
		yourself
]

{ #category : #accessing }
SubPerson >> age [
	^age
]

{ #category : #accessing }
SubPerson >> age: anObject [
	age := anObject
]
