"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'MidPerson',
	#superclass : 'SuperPerson',
	#instVars : [
		'middleName',
		'midFlags',
		'midFriend'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'constants' }
MidPerson class >> mutableAspects [
	^super mutableAspects copyWith: #midFlags.
]

{ #category : 'public' }
MidPerson class >> reStoreDefinition [
	^super reStoreDefinition
		define: #middleName as: (String maxSize: 128);
		define: #midFriend as: SuperPerson;
		define: #midFlags as: TestBitmask;
		yourself.
]

{ #category : 'initializing' }
MidPerson >> initialize [
	super initialize.
	midFlags := TestBitmask new.
]

{ #category : 'accessing' }
MidPerson >> midFlags [
	^midFlags.
]

{ #category : 'accessing' }
MidPerson >> midFriend [
	^midFriend
]

{ #category : 'accessing' }
MidPerson >> midFriend: anObject [
	midFriend := anObject
]

{ #category : 'accessing' }
MidPerson >> middleName [
	^middleName
]

{ #category : 'accessing' }
MidPerson >> middleName: anObject [
	middleName := anObject
]
