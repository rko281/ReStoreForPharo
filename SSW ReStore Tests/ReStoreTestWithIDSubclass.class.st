Class {
	#name : #ReStoreTestWithIDSubclass,
	#superclass : #ReStoreTestWithIDOnly,
	#instVars : [
		'name',
		'other'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #'instance creation' }
ReStoreTestWithIDSubclass class >> name: aString nmbr: anInteger [

	^self new
		name: aString;
		nmbr: anInteger;
		yourself
]

{ #category : #persistency }
ReStoreTestWithIDSubclass class >> reStoreDefinition [

	^super reStoreDefinition
		define: #name as: (String maxSize: 64);
		define: #other as: ReStoreTestWithIDOnly;
		yourself
]

{ #category : #accessing }
ReStoreTestWithIDSubclass >> name [
	^name
]

{ #category : #accessing }
ReStoreTestWithIDSubclass >> name: anObject [
	name := anObject
]

{ #category : #accessing }
ReStoreTestWithIDSubclass >> other [
	^other
]

{ #category : #accessing }
ReStoreTestWithIDSubclass >> other: anObject [
	other := anObject
]
