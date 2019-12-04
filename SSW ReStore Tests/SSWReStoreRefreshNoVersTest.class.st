"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreRefreshNoVersTest,
	#superclass : #SSWReStoreRefreshTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #Running }
SSWReStoreRefreshNoVersTest >> initReStore: aReStore [

	super initReStore: aReStore.
	aReStore useTransactionsWithoutVersioning

]

{ #category : #public }
SSWReStoreRefreshNoVersTest >> usesVersioning [

	^false
]
