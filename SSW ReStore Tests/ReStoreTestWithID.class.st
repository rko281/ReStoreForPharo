"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #ReStoreTestWithID,
	#superclass : #Object,
	#instVars : [
		'name',
		'nmbr',
		'other'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #'instance creation' }
ReStoreTestWithID class >> name: aString nmbr: anInteger [

	^self new
		name: aString;
		nmbr: anInteger;
		yourself
]

{ #category : #persistency }
ReStoreTestWithID class >> reStoreDefinition [

	^super reStoreDefinition
		defineAsID: #nmbr;
		define: #name as: (String maxSize: 64);
		define: #other as: ReStoreTestWithID;
		yourself
]

{ #category : #persistency }
ReStoreTestWithID class >> shouldSubclassesInheritPersistency [

	^false
]

{ #category : #accessing }
ReStoreTestWithID >> name [
	^name
]

{ #category : #accessing }
ReStoreTestWithID >> name: anObject [
	name := anObject
]

{ #category : #accessing }
ReStoreTestWithID >> nmbr [
	^nmbr
]

{ #category : #accessing }
ReStoreTestWithID >> nmbr: anObject [
	nmbr := anObject
]

{ #category : #accessing }
ReStoreTestWithID >> other [
	^other
]

{ #category : #accessing }
ReStoreTestWithID >> other: anObject [
	other := anObject
]
