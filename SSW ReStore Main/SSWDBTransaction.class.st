"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWDBTransaction,
	#superclass : #Object,
	#category : #'SSW ReStore Main'
}

{ #category : #actions }
SSWDBTransaction >> beginWithin: anotherTransaction [

	"Initialize the receiver transaction as a nested transaction within anotherTransaction.
	anotherTransaction may be nil - i.e. receiver is root transaction"
	
	self subclassResponsibility
]

{ #category : #testing }
SSWDBTransaction >> canCommit [

	"Return whether the receiver is capable of committing.
	Default - true"
	
	^true
]

{ #category : #actions }
SSWDBTransaction >> commitTo: aDBConnection [

	"Write the changes associated with the receiver transaction.
	Use aDBConnection for database-level transaction (Txn) control"
	
	self subclassResponsibility
]

{ #category : #testing }
SSWDBTransaction >> hasChanges [

	"Return whether receiver contains any changed (modified/created/deleted) objects"
	
	^self subclassResponsibility
]

{ #category : #testing }
SSWDBTransaction >> hasFailedCommit [

	"Return whether the receiver's last commit failed"
	
	^self subclassResponsibility
]

{ #category : #testing }
SSWDBTransaction >> includesProxy: anSSWDBProxy [

	"Return a Boolean indicating whether the given proxy is contained in this transaction"

	^self subclassResponsibility
]

{ #category : #testing }
SSWDBTransaction >> isDumb [

	"Return whether the receiver is a 'dumb' transaction
	 - one which absorbs traversed objects but cannot commit changes"
	
	^false
]

{ #category : #evaluating }
SSWDBTransaction >> ownerTransaction [

	"Return the transaction that the receiver is nested within, or nil if none (root transaction).
	This becomes the current transaction after the receiver is commit'd/rollback'd"
	
	^self subclassResponsibility
]

{ #category : #actions }
SSWDBTransaction >> prepareToCommit [

	self subclassResponsibility
]

{ #category : #'proxy tracking' }
SSWDBTransaction >> proxy: aProxydObject forwarded: aMessage [

	"aProxydObject has forwarded the given message to its proxiedObject. 
	Act accordingly"
	
	self subclassResponsibility
]

{ #category : #actions }
SSWDBTransaction >> rollback [

	"Forget the changes associated with the receiver transaction.
	Also refresh all changed objects.
	Return the collection of changed objects"
	
	^self subclassResponsibility
]
