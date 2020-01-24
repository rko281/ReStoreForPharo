"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #NumberWithCurrency,
	#superclass : #Object,
	#instVars : [
		'number',
		'currency'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
NumberWithCurrency class >> reStoreDefinition [

	^super reStoreDefinition
		define: #number as: Float;
		define: #currency as: (String maxSize: 3)
]

{ #category : #public }
NumberWithCurrency class >> shouldInlinePersistency [

	^true
]

{ #category : #comparing }
NumberWithCurrency >> = aNumberWithCurrency [

	^(self number = aNumberWithCurrency number) & (self currency = aNumberWithCurrency currency)
]

{ #category : #accessing }
NumberWithCurrency >> currency [
	^currency
]

{ #category : #accessing }
NumberWithCurrency >> currency: anObject [
	currency := anObject
]

{ #category : #displaying }
NumberWithCurrency >> displayString [

	^self number printString, ' ', self currency
]

{ #category : #accessing }
NumberWithCurrency >> hash [

	^self number hash
]

{ #category : #accessing }
NumberWithCurrency >> number [
	^number
]

{ #category : #accessing }
NumberWithCurrency >> number: anObject [
	number := anObject
]
