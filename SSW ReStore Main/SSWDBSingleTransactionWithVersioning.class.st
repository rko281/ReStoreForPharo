"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBSingleTransactionWithVersioning',
	#superclass : 'SSWDBSingleTransaction',
	#instVars : [
		'proxyCommitFailures'
	],
	#category : 'SSW ReStore Main',
	#package : 'SSW ReStore Main'
}

{ #category : 'accessing' }
SSWDBSingleTransactionWithVersioning >> commitFailures [

	"Return the actual objects (not proxies) which failed to commit"

	^self proxyCommitFailures "Under write barrier, due to no pre-swap proxyCommitFailures contains actual objects"
]

{ #category : 'actions' }
SSWDBSingleTransactionWithVersioning >> commitTo: aDBConnection [

	"Commit the receiver's objects without any checking (done in prepareToCommit).
	Use aDBConnection for database-level transaction (Txn) control.
	Set commitFailures accordingly"
	
	| toCommit conflicts resolved failures |

	toCommit := self changedObjects. 

	"Iteratively commit, resolving update conflicts and retrying if all are resolved"
	[aDBConnection beginRWTxn.
	self preCommit.
	conflicts := toCommit reject: [ :proxyObj | proxyObj _commitChangesPhase1].
	conflicts addAll: (toCommit reject: [ :proxyObj | proxyObj _commitChangesPhase2]).
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

	self beginObjectCollection.
	self proxyCommitFailures: failures.
	self hasFailedCommit 
	ifTrue: 
		[aDBConnection rollbackTxn.
		self currentReferencedObjects: self changedObjects.
		self freeStatements]
	ifFalse: 
		[aDBConnection commitTxn.
		self postCommit]
]

{ #category : 'actions' }
SSWDBSingleTransactionWithVersioning >> ensureHasFailedCommit [

	self hasFailedCommit ifFalse: [self error: 'Transaction has not failed a commit'].
]

{ #category : 'testing' }
SSWDBSingleTransactionWithVersioning >> hasFailedCommit [

	^self proxyCommitFailures notNil and: [self proxyCommitFailures isEmpty not]
]

{ #category : 'actions' }
SSWDBSingleTransactionWithVersioning >> postRollback [

	self proxyCommitFailures: nil.
	super postRollback
]

{ #category : 'accessing' }
SSWDBSingleTransactionWithVersioning >> proxyCommitFailures [

	"proxyCommitFailures stores an OrderdCollection of those proxy objects which error
	when an attempt is made to commit them"
	
	^proxyCommitFailures
]

{ #category : 'accessing' }
SSWDBSingleTransactionWithVersioning >> proxyCommitFailures: anOrderedCollection [

	"proxyCommitFailures stores an OrderdCollection of those proxy objects which error
	when an attempt is made to commit them"
	
	proxyCommitFailures := anOrderedCollection
]

{ #category : 'actions' }
SSWDBSingleTransactionWithVersioning >> refreshAndRollforward [

	self ensureHasFailedCommit.

	self proxyCommitFailures do: 
		[ :obj |
		(self activeProxiesMap at: obj) _refreshAndRollforward ifFalse: [self currentReferencedObjects remove: obj]]
]

{ #category : 'actions' }
SSWDBSingleTransactionWithVersioning >> rollbackAndRefresh [

	| failures |

	self ensureHasFailedCommit.
	
	failures := self proxyCommitFailures.
	self currentReferencedObjects: self activeProxiesMap values. 
	self activeProxiesMap: IdentityDictionary new.

	self rollback.

	failures do: [ :each | each _forgetProxiedObject]
]
