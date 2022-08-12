"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWDBSingleTransaction,
	#superclass : #SSWDBAbstractSingleTransaction,
	#instVars : [
		'updateStatementsCache'
	],
	#category : #'SSW ReStore Main'
}

{ #category : #actions }
SSWDBSingleTransaction >> commitTo: aDBConnection [

	"Commit the receiver's objects without any checking (done in prepareToCommit).
	Use aDBConnection for database-level transaction (Txn) control."
	
	aDBConnection beginRWTxn.
	self preCommit.
	self changedObjects 
		do: [ :proxyObj | proxyObj _commitChangesPhase1];
		do: [ :proxyObj | proxyObj _commitChangesPhase2].
	aDBConnection commitTxn.

	self postCommit.

	self resetChangedObjects.
	self beginObjectCollection

]

{ #category : #actions }
SSWDBSingleTransaction >> freeStatements [

	self updateStatementsCache do: [ :stmts | stmts do: [ :stmt | stmt free]]
]

{ #category : #testing }
SSWDBSingleTransaction >> hasChanges [

	^self currentReferencedObjects anySatisfy: [ :obj | obj _checkHasChanged]
]

{ #category : #testing }
SSWDBSingleTransaction >> hasFailedCommit [

	"The receiver does not support commit-time checking of update clashes.
	Therefore commits are always considered to succeed.
	Subclasses may do something smarter"
	
	^false
]

{ #category : #actions }
SSWDBSingleTransaction >> postCommit [

	self postCommitAllocatedIDs.
	self changedObjects do: [ :proxyObj | proxyObj _postCommitChanges].
	self freeStatements
]

{ #category : #actions }
SSWDBSingleTransaction >> postRollback [

	self endObjectCollection
]

{ #category : #actions }
SSWDBSingleTransaction >> preCommit [

	self updateStatementsCache: IdentityDictionary new.
	self commitAllocatedIDs
]

{ #category : #actions }
SSWDBSingleTransaction >> rollback [

	| rolledBack |

	rolledBack := OrderedCollection new: (self currentReferencedObjects size * 2).

	self currentReferencedObjects isNil ifFalse:
		[[self currentReferencedObjects isEmpty] whileFalse:
			[| toRollback |
			toRollback := self currentReferencedObjects copy.
			self currentReferencedObjects: (self newEmptyObjectsSet: (toRollback size // 2)). 
			toRollback do: [ :proxy | proxy _rollbackChanges].
			rolledBack addAll: toRollback]].

	self postRollback.

	^rolledBack
]

{ #category : #public }
SSWDBSingleTransaction >> statementForUpdateQuery: anUpdateQuery ifAbsent: aBlock [

	^(self updateStatementsCache at: anUpdateQuery table ifAbsentPut: [Dictionary new])
		at: anUpdateQuery updatedFields ifAbsentPut: [aBlock value]
]

{ #category : #public }
SSWDBSingleTransaction >> updateStatementsCache [
	^updateStatementsCache
]

{ #category : #public }
SSWDBSingleTransaction >> updateStatementsCache: anObject [
	updateStatementsCache := anObject
]
