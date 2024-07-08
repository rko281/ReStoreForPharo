Class {
	#name : 'SSWDBTransactionCommitError',
	#superclass : 'SSWDBTransactionError',
	#category : 'SSW ReStore Main',
	#package : 'SSW ReStore Main'
}

{ #category : 'handling' }
SSWDBTransactionCommitError >> _autoRecover [

	[reStore connection rollbackTxn] on: Error do: [ :txnExc | txnExc return].
	self transaction autoRecoverCommitIn: self
]

{ #category : 'constants' }
SSWDBTransactionCommitError >> stage [

	^'commit'
]
