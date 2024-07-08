Class {
	#name : 'SSWReStoreIDTest',
	#superclass : 'SSWReStoreTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
SSWReStoreIDTest class >> allTestSelectors [

	^super allTestSelectors reject: [ :each | #(#testClass #testInstances) includes: each]
]

{ #category : 'public' }
SSWReStoreIDTest class >> isAbstract [

	^self == SSWReStoreIDTest
]

{ #category : 'public' }
SSWReStoreIDTest class >> testSelectors [

	^super testSelectors reject: [ :each | #(#testClass #testInstances) includes: each]
]

{ #category : 'running' }
SSWReStoreIDTest >> addClassesTo: aReStore [

	aReStore addClass: self testClass
]

{ #category : 'constants' }
SSWReStoreIDTest >> testClass [

	^self subclassResponsibility
]

{ #category : 'accessing' }
SSWReStoreIDTest >> testInstances [

	^self testClass storedInstancesIn: reStore
]
