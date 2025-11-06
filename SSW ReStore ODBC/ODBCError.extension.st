Extension { #name : #ODBCError }

{ #category : #'*SSW ReStore ODBC' }
ODBCError >> isCommunicationLinkFailure [

	^tag notNil and: [tag errors anySatisfy: [ :each | each isCommunicationLinkFailure]]
]

{ #category : #'*SSW ReStore ODBC' }
ODBCError >> isInvalidTransactionState [

	^tag notNil and: [tag errors anySatisfy: [ :each | each isInvalidTransactionState]]
]

{ #category : #'*SSW ReStore ODBC' }
ODBCError >> isRecordDeletedError [

	^tag notNil and: [tag errors anySatisfy: [ :each | each isInvalidCursorPosition]]
]
