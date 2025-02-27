Class {
	#name : 'ReStoreTestWithIDOnly',
	#superclass : 'Object',
	#instVars : [
		'nmbr'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'persistency' }
ReStoreTestWithIDOnly class >> reStoreDefinition [

	^super reStoreDefinition
		defineAsID: #nmbr;
		yourself
]

{ #category : 'accessing' }
ReStoreTestWithIDOnly >> nmbr [
	^nmbr
]

{ #category : 'accessing' }
ReStoreTestWithIDOnly >> nmbr: anObject [
	nmbr := anObject
]
