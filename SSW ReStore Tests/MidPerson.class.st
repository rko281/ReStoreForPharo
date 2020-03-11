"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #MidPerson,
	#superclass : #SuperPerson,
	#instVars : [
		'middleName'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
MidPerson class >> reStoreDefinition [

	^super reStoreDefinition
		define: #middleName as: (String maxSize: 128);
		yourself
]

{ #category : #accessing }
MidPerson >> middleName [
	^middleName
]

{ #category : #accessing }
MidPerson >> middleName: anObject [
	middleName := anObject
]
