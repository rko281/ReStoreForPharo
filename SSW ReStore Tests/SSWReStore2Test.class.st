"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWReStore2Test',
	#superclass : 'SSWReStoreTest',
	#instVars : [
		'reStore2'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
SSWReStore2Test class >> isAbstract [

	^self == SSWReStore2Test
]

{ #category : 'running' }
SSWReStore2Test >> setUp [

	super setUp.

	reStore2 := SSWReStore new.
	self initReStore: reStore2.
	reStore2 connect.
	self addClassesTo: reStore2
]

{ #category : 'running' }
SSWReStore2Test >> tearDown [

	reStore2 isNil ifFalse: 
		[self releaseReStore: reStore2.
		reStore2 := nil].

	super tearDown
]
