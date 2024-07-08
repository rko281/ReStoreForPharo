Class {
	#name : 'SSWDBTransactionPreCommitError',
	#superclass : 'SSWDBTransactionError',
	#category : 'SSW ReStore Main',
	#package : 'SSW ReStore Main'
}

{ #category : 'handling' }
SSWDBTransactionPreCommitError >> _autoRecover [

	self transaction autoRecoverPreCommitIn: self
]

{ #category : 'constants' }
SSWDBTransactionPreCommitError >> stage [

	^'pre-commit'
]
