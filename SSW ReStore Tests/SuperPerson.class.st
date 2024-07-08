"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SuperPerson',
	#superclass : 'Object',
	#instVars : [
		'firstName',
		'superFlags',
		'surname'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'constants' }
SuperPerson class >> mutableAspects [
	^#(#superFlags).
]

{ #category : 'public' }
SuperPerson class >> reStoreDefinition [
	^super reStoreDefinition
		define: #surname as: (String maxSize: 255);
		define: #firstName as: (String maxSize: 255);
		define: #superFlags as: TestBitmask;
		yourself.
]

{ #category : 'accessing' }
SuperPerson >> firstName [

	^firstName
]

{ #category : 'accessing' }
SuperPerson >> firstName: a [

	firstName := a
]

{ #category : 'accessing' }
SuperPerson >> fullName [

	^self firstName, ' ', self surname
]

{ #category : 'initialization' }
SuperPerson >> initialize [
	super initialize.
	superFlags := TestBitmask new.
]

{ #category : 'accessing' }
SuperPerson >> superFlags [
	^superFlags.
]

{ #category : 'accessing' }
SuperPerson >> surname [

	^surname
]

{ #category : 'accessing' }
SuperPerson >> surname: a [

	surname := a
]
