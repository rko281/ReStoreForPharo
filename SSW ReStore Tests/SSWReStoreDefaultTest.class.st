"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreDefaultTest,
	#superclass : #SSWReStoreAbstractQueryTest,
	#instVars : [
		'reStore2'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreDefaultTest class >> isAbstract [

	^self == SSWReStoreDefaultTest
]

{ #category : #running }
SSWReStoreDefaultTest >> createReStore [

	"Private - Use the default instance"

	reStore := ReStore
]

{ #category : #Running }
SSWReStoreDefaultTest >> newAlan [

	^SimplePerson new
		surname: 'Jones'; 
		firstName: 'Alan'; 
		emailAddress: 'alan@jones.co'; 
		age: 39;
		address: (SimpleAddress new postcode: 'A1 1AA');
		yourself
]

{ #category : #running }
SSWReStoreDefaultTest >> setUp [

	super setUp.

	reStore2 := SSWReStore new.
	self initReStore: reStore2.

	reStore2 connect.
	self addClassesTo: reStore2
]

{ #category : #running }
SSWReStoreDefaultTest >> tearDown [

	reStore2 isNil ifFalse: 
		[self releaseReStore: reStore2.
		reStore2 := nil].

	super tearDown.

	SSWReStore reset
]
