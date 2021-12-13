Extension { #name : #ODBCErrorDetails }

{ #category : #'*SSW ReStore ODBC' }
ODBCErrorDetails >> isCommunicationLinkFailure [

	^self sqlState = '08S01'
]

{ #category : #'*SSW ReStore ODBC' }
ODBCErrorDetails >> isInvalidCursorPosition [

	^self sqlState = 'S1109'
]

{ #category : #'*SSW ReStore ODBC' }
ODBCErrorDetails >> isInvalidTransactionState [

	^self sqlState = '25000'
]
