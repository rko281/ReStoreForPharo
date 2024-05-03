"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #StoreFailure,
	#superclass : #Notification,
	#category : #'SSW ReStore Main'
}

{ #category : #operations }
StoreFailure >> abandon [

	self reStore abandonTransaction
]

{ #category : #operations }
StoreFailure >> commit [

	"Returns success"

	^self reStore commitTransaction
]

{ #category : #operations }
StoreFailure >> defaultAction [

	"Default is to abandon the active (failed) transaction"

	self abandon
]

{ #category : #accessing }
StoreFailure >> failedObjects [

	^self reStore transactionCommitFailures
]

{ #category : #accessing }
StoreFailure >> reStore [

	^self tag
]

{ #category : #operations }
StoreFailure >> refreshAndRollforward [

	self reStore refreshAndRollforwardTransaction
]

{ #category : #operations }
StoreFailure >> rollback [

	self reStore rollbackTransaction
]

{ #category : #operations }
StoreFailure >> rollbackAndRefresh [

	self reStore rollbackAndRefreshTransaction
]
