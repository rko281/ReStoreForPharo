"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SuperPerson,
	#superclass : #Object,
	#instVars : [
		'surname',
		'firstName'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SuperPerson class >> reStoreDefinition [

	^super reStoreDefinition
		define: #surname as: (String maxSize: 255);
		define: #firstName as: (String maxSize: 255);
		yourself
]

{ #category : #public }
SuperPerson >> firstName [

	^firstName
]

{ #category : #public }
SuperPerson >> firstName: a [

	firstName := a
]

{ #category : #public }
SuperPerson >> surname [

	^surname
]

{ #category : #public }
SuperPerson >> surname: a [

	surname := a
]
