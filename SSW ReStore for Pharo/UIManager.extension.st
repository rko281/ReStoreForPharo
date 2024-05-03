Extension { #name : 'UIManager' }

{ #category : '*SSW ReStore for Pharo' }
UIManager >> onUnhandledTransactionError: anSSWDBTransactionError [

	anSSWDBTransactionError autoRecover.
	self unhandledErrorDefaultAction: anSSWDBTransactionError
]
