"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWDBDumbTransaction,
	#superclass : #SSWDBAbstractSingleTransaction,
	#category : #'SSW ReStore Main'
}

{ #category : #testing }
SSWDBDumbTransaction >> canCommit [

	"The purpose of the receiver is to absorb objects traversed when not in a 'real' transaction.
	As such, it cannot commit any changes"
	
	^false
]

{ #category : #actions }
SSWDBDumbTransaction >> commitTo: aReStore [

	"Cannot actually commit (just here to satisfy subclassResponsibility protocol)"

]

{ #category : #testing }
SSWDBDumbTransaction >> hasChanges [

	"Cannot commit, therefore does not track changes (just here to satisfy subclassResponsibility protocol)"

	^false
]

{ #category : #testing }
SSWDBDumbTransaction >> hasFailedCommit [

	"Cannot commit, therefore cannot fail (just here to satisfy subclassResponsibility protocol)"

	^false
]

{ #category : #testing }
SSWDBDumbTransaction >> isDumb [

	"The purpose of the receiver is to absorb objects traversed when not in a 'real' transaction.
	As such, it is a dumb transaction"
	
	^true
]

{ #category : #actions }
SSWDBDumbTransaction >> rollback [

	"To rollback the receiver just abandon it.
	Note that since the receiver is 'dumb', we return an empty collection of changed objects"
	
	self abandon.

	^#()
]
