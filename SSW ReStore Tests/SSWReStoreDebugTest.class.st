Class {
	#name : #SSWReStoreDebugTest,
	#superclass : #SSWReStoreAbstractQueryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #helpers }
SSWReStoreDebugTest >> makeIDEClass [

	Process methodDictionary
		at: #isInIDECallStackOrig put: (Process>>#isInIDECallStack);
		at: #isInIDECallStack put: (Process>>#isInIDECallStackAlwaysTrue).

	Process flushMethodCache
]

{ #category : #'unit tests' }
SSWReStoreDebugTest >> testDebugModeCommitErrorHandling [

	"Verify errors during transaction commit are passed when debug mode is active"

	| john actualErrorText |

	john := self john.

	"Standard behaviour - errors are trapped and re-raised at the end"
	john firstName: '<ERROR ON COMMIT>'.
	self should: [john storeIn: reStore] raise: Error matching: 
		[ :exc || reraisePrefix |
		reraisePrefix := 'An error occured during commit: '.
		(exc messageText beginsWith: reraisePrefix)
			ifTrue: [actualErrorText := exc messageText readStream skip: reraisePrefix size; upToEnd. true]
			ifFalse: [false]].

	reStore enterDebugMode.

	"Debug mode behaviour - errors are raised immediately they occur (actually trapped and passed)"
	john firstName: '<ERROR ON COMMIT>'.
	self should: [john storeIn: reStore] raise: Error matching: [ :exc | exc description = actualErrorText]
]

{ #category : #'unit tests' }
SSWReStoreDebugTest >> testDebugModeMutex [

	"Verify critial section check is bypassed when a send originates in a specific class, when ReStore is in debug mode"

	| sem proc1 proc2 done |

	sem := Semaphore new.
	done := false.

	reStore enterDebugMode.

	"Check default behaviour first"
	proc1 := [reStore transactionCritical: [sem wait]] forkAt: Processor activeProcess priority + 2.
	self deny: proc1 isTerminated.

	proc2 := [reStore transactionCritical: [done := true]] forkAt: Processor activeProcess priority + 1.
	self deny: proc1 isTerminated.
	self deny: done.

	sem signal.
	self assert: proc1 isTerminated.
	self assert: proc2 isTerminated.
	self assert: done.

	"Now make ourselves an IDE class (effectively) and retest"
	self makeIDEClass.
	[done := false.
	proc1 := [reStore transactionCritical: [sem wait]] forkAt: Processor activeProcess priority + 2.
	self deny: proc1 isTerminated.

	proc2 := [reStore transactionCritical: [done := true]] forkAt: Processor activeProcess priority + 1.
	self assert: proc2 isTerminated.
	self assert: done.

	"Allow proc1 to finish"
	sem signal.
	self assert: proc1 isTerminated.

	"Finally leave debug mode and verify things back to normal"
	reStore leaveDebugMode.
	done := false.
	proc1 := [reStore transactionCritical: [sem wait]] forkAt: Processor activeProcess priority + 2.
	self deny: proc1 isTerminated.

	proc2 := [reStore transactionCritical: [done := true]] forkAt: Processor activeProcess priority + 1.
	self deny: proc1 isTerminated.
	self deny: done.

	sem signal.
	self assert: proc1 isTerminated.
	self assert: proc2 isTerminated.
	self assert: done] ensure: [self unmakeIDEClass]
]

{ #category : #'unit tests' }
SSWReStoreDebugTest >> testDebugModePreCommitErrorHandling [

	"Verify errors during transaction pre-commit are passed when debug mode is active"

	| actualErrorText |

	"Standard behaviour - errors are trapped and re-raised at the end"
	reStore beginTransaction.
	reStore transaction currentReferencedObjects add: self.
	self should: [reStore commitTransaction] raise: Error matching: 
		[ :exc || reraisePrefix |
		reraisePrefix := 'An error occured during pre-commit: '.
		(exc messageText beginsWith: reraisePrefix)
			ifTrue: [actualErrorText := exc messageText readStream skip: reraisePrefix size; upToEnd. true]
			ifFalse: [false]].
	reStore transaction currentReferencedObjects remove: self.
	reStore rollbackTransaction.

	reStore enterDebugMode.

	"Debug mode behaviour - errors are raised immediately they occur (actually trapped and passed)"
	reStore beginTransaction.
	reStore transaction currentReferencedObjects add: self.
	self should: [reStore commitTransaction] raise: Error matching: [ :exc | exc description = actualErrorText].
	reStore transaction allReferencedObjects remove: self.
	reStore rollbackTransaction

]

{ #category : #'unit tests' }
SSWReStoreDebugTest >> testDebugModeProxyInstVarAt [

	"Verify instVarAt: accesses directed to a proxy return the proxy's own instance variables when debug mode is active.
	This allows easier use of developement tools with proxies"

	| john |
	
	john := self john.
	self assert: john isDBProxy.

	"Non-debug mode should access the proxiedObject's instance variables"
	self assert: reStore isDebugging not.
	self assert: (john instVarAt: 1 "proxiedObject") equals: 'John'.
	self assert: (john _instVarAt: 1 "firstName") equals: 'John'.

	"Debug mode instVarAt: should access the proxy's instance variables"
	reStore enterDebugMode.
	self makeIDEClass.
	[self assert: john isDBProxy.
	self assert: (john instVarAt: 1 "proxiedObject") identicalTo: john _proxiedObject.
	self assert: (john _instVarAt: 1 "firstName") equals: 'John'] ensure: [self unmakeIDEClass]
]

{ #category : #helpers }
SSWReStoreDebugTest >> unmakeIDEClass [

	Process methodDictionary at: #isInIDECallStack put: (Process methodDictionary removeKey: #isInIDECallStackOrig).
	Process flushMethodCache
]
