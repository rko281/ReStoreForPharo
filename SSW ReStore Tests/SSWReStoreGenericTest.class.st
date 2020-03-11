"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreGenericTest,
	#superclass : #SSWReStore2Test,
	#instVars : [
		'testObject'
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
SSWReStoreGenericTest >> createTestData [

	self createTestObject.

	self fetchTestObjects
]

{ #category : #running }
SSWReStoreGenericTest >> createTestObject [

	reStore evaluateAsTransaction: [self templateTestObject storeIn: reStore]
]

{ #category : #running }
SSWReStoreGenericTest >> fetchTestObjects [

	(Delay forMilliseconds: 10) wait.
	reStore simulateReconnect.

	testObject := (GenericTest storedInstancesIn: reStore) first
]

{ #category : #accessing }
SSWReStoreGenericTest >> templateTestObject [

	^self subclassResponsibility
]
