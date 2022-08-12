"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #MidPerson,
	#superclass : #SuperPerson,
	#instVars : [
		'middleName',
		'midFriend'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
MidPerson class >> reStoreDefinition [

	^super reStoreDefinition
		define: #middleName as: (String maxSize: 128);
		define: #midFriend as: SuperPerson;
		yourself
]

{ #category : #accessing }
MidPerson >> midFriend [
	^midFriend
]

{ #category : #accessing }
MidPerson >> midFriend: anObject [
	midFriend := anObject
]

{ #category : #accessing }
MidPerson >> middleName [
	^middleName
]

{ #category : #accessing }
MidPerson >> middleName: anObject [
	middleName := anObject
]
