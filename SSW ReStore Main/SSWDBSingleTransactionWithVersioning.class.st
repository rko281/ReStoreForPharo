"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBSingleTransactionWithVersioning,
	#superclass : #SSWDBSingleTransaction,
	#instVars : [
		'proxyCommitFailures'
	],
	#category : #'SSW ReStore Main'
}

{ #category : #accessing }
SSWDBSingleTransactionWithVersioning >> commitFailures [

	"Return the actual objects (not proxies) which failed to commit"
	
	^self proxyCommitFailures collect: [ :proxy | proxy _proxiedObject]
]

{ #category : #actions }
SSWDBSingleTransactionWithVersioning >> commitTo: aDBConnection [

	"Commit the receiver's objects without any checking (done in prepareToCommit).
	Use aDBConnection for database-level transaction (Txn) control.
	Set commitFailures accordingly"
	
	| toCommit conflicts resolved failures |

	toCommit := self changedObjects. 

	"Iteratively commit, resolving update conflicts and retrying if all are resolved"
	[aDBConnection beginRWTxn.
	self preCommit.
	conflicts := toCommit reject: [ :proxyObj | proxyObj _commitChanges].
	resolved := OrderedCollection new.
	failures := OrderedCollection new.

	conflicts isEmpty ifFalse:
		[aDBConnection rollbackTxn.
		conflicts do: 
			[ :proxyObj | 
			([proxyObj _resolveUpdateConflicts] on: Error do: [ :exc | exc return: false])
				ifTrue: [resolved add: proxyObj]
				ifFalse: [failures add: proxyObj _proxiedObject]]].	"Use the proxiedObject so we get the proxy after _swapReferences"

	failures isEmpty and: [resolved isEmpty not]] whileTrue.

	"currentReferencedObjects usually empty, but could contain objects ref'd during conflict resolution"
	self currentReferencedObjects do: [ :obj | obj _swapReferences].
	self beginObjectCollection.

	self proxyCommitFailures: failures.
	self hasFailedCommit 
	ifTrue: 
		[aDBConnection rollbackTxn.
		self freeStatements.
		self currentReferencedObjects: (self changedObjects collect: [ :obj | obj _swapReferences])]
	ifFalse: 
		[aDBConnection commitTxn.
		self postCommit].

	self resetChangedObjects
]

{ #category : #actions }
SSWDBSingleTransactionWithVersioning >> ensureHasFailedCommit [

	self hasFailedCommit ifFalse: [self error: 'Transaction has not failed a commit'].
]

{ #category : #testing }
SSWDBSingleTransactionWithVersioning >> hasFailedCommit [

	^self proxyCommitFailures notNil and: [self proxyCommitFailures isEmpty not]
]

{ #category : #actions }
SSWDBSingleTransactionWithVersioning >> postRollback [

	self proxyCommitFailures: nil.
	super postRollback
]

{ #category : #accessing }
SSWDBSingleTransactionWithVersioning >> proxyCommitFailures [

	"proxyCommitFailures stores an OrderdCollection of those proxy objects which error
	when an attempt is made to commit them"
	
	^proxyCommitFailures
]

{ #category : #accessing }
SSWDBSingleTransactionWithVersioning >> proxyCommitFailures: anOrderedCollection [

	"proxyCommitFailures stores an OrderdCollection of those proxy objects which error
	when an attempt is made to commit them"
	
	proxyCommitFailures := anOrderedCollection
]

{ #category : #actions }
SSWDBSingleTransactionWithVersioning >> refreshAndRollforward [

	self ensureHasFailedCommit.
	
	self proxyCommitFailures do: 
		[ :proxyObj |
		(proxyObj _refreshAndRollforward) ifFalse: [self currentReferencedObjects remove: proxyObj]]
]

{ #category : #actions }
SSWDBSingleTransactionWithVersioning >> rollbackAndRefresh [

	self ensureHasFailedCommit.
	
	self proxyCommitFailures do: 
		[ :proxyObj | 
		self currentReferencedObjects remove: proxyObj.
		proxyObj _swapReferences _forgetProxiedObject].

	self rollback
]
