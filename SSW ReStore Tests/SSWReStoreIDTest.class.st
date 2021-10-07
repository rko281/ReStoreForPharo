Class {
	#name : #SSWReStoreIDTest,
	#superclass : #SSWReStoreTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #accessing }
SSWReStoreIDTest class >> allTestSelectors [

	^super allTestSelectors reject: [ :each | #(#testClass #testInstances) includes: each]
]

{ #category : #testing }
SSWReStoreIDTest class >> isAbstract [

	^self == SSWReStoreIDTest
]

{ #category : #accessing }
SSWReStoreIDTest class >> testSelectors [

	^super testSelectors reject: [ :each | #(#testClass #testInstances) includes: each]
]

{ #category : #running }
SSWReStoreIDTest >> addClassesTo: aReStore [

	aReStore addClass: self testClass
]

{ #category : #constants }
SSWReStoreIDTest >> testClass [

	^self subclassResponsibility
]

{ #category : #accessing }
SSWReStoreIDTest >> testInstances [

	^self testClass storedInstancesIn: reStore
]
