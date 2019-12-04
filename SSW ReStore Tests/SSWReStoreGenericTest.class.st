"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreGenericTest,
	#superclass : #SSWReStoreTest,
	#instVars : [
		'testObject',
		'reStore2'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreGenericTest class >> isAbstract [

	^self == SSWReStoreGenericTest
]

{ #category : #running }
SSWReStoreGenericTest >> addClassesTo: aReStore [

	super addClassesTo: aReStore.

	GenericTest componentDefinition: self componentDefinition.
	aReStore addClass: GenericTest
]

{ #category : #accessing }
SSWReStoreGenericTest >> componentDefinition [

	^self subclassResponsibility
]

{ #category : #running }
SSWReStoreGenericTest >> createTestObject [

	reStore evaluateAsTransaction: [self templateTestObject storeIn: reStore]
]

{ #category : #running }
SSWReStoreGenericTest >> fetchTestObjects [

	(Delay forMilliseconds: 10) wait.
	reStore simulateReconnect.

	testObject := (reStore instancesOf: GenericTest) first
]

{ #category : #running }
SSWReStoreGenericTest >> setUp [

	super setUp.

	reStore destroyAllClasses; synchronizeAllClasses.

	self createTestObject.

	self fetchTestObjects
]

{ #category : #running }
SSWReStoreGenericTest >> setUpReStore2 [

	reStore2 := SSWReStore new.
	self initReStore: reStore2.
	reStore2 connect.
	self addClassesTo: reStore2
]

{ #category : #running }
SSWReStoreGenericTest >> tearDown [

	super tearDown.
	reStore2 isNil ifFalse: 
		[reStore2 disconnect. 
		reStore2 := nil]
]

{ #category : #accessing }
SSWReStoreGenericTest >> templateTestObject [

	^self subclassResponsibility
]
