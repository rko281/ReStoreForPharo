Class {
	#name : #SSWDBTransactionError,
	#superclass : #Error,
	#instVars : [
		'reStore',
		'isRecovered'
	],
	#category : #'SSW ReStore Main'
}

{ #category : #'instance creation' }
SSWDBTransactionError class >> signalWith: anException in: aReStore [

	^self new signalWith: anException in: aReStore
]

{ #category : #handling }
SSWDBTransactionError >> _autoRecover [

	self subclassResponsibility
]

{ #category : #handling }
SSWDBTransactionError >> autoRecover [

	isRecovered ifFalse: 
		[self _autoRecover.
		isRecovered := true]
]

{ #category : #handling }
SSWDBTransactionError >> defaultAction [

	^self sessionManager onUnhandledTransactionError: self
]

{ #category : #testing }
SSWDBTransactionError >> isRecovered [

	^isRecovered
]

{ #category : #handling }
SSWDBTransactionError >> signalWith: anException in: aReStore [

	reStore := aReStore.
	isRecovered := false.
	
	[aReStore isDebugging 
		ifTrue: [anException pass]
		ifFalse: [self signal: 'An error occurred during <1s>: <2s>' << {self stage. anException description} with: anException]] ensure: [self autoRecover]
]

{ #category : #constants }
SSWDBTransactionError >> stage [

	^self subclassResponsibility
]

{ #category : #accessing }
SSWDBTransactionError >> transaction [

	^reStore transaction
]
