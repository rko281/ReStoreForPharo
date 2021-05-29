Class {
	#name : #SSWReStoreDeleteDependentDictionaryTest,
	#superclass : #SSWReStoreDeleteDependentGeneralCollectionTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreDeleteDependentDictionaryTest class >> isAbstract [

	^self = SSWReStoreDeleteDependentDictionaryTest
]

{ #category : #running }
SSWReStoreDeleteDependentDictionaryTest >> addOrderFor: aProduct to: aCustomer quantity: anInteger [

	"Need to convert orders to Dictionary if not already done - ensure unproxied before transformation"
	aCustomer orders size.
	(aCustomer orders isKindOf: Dictionary) ifFalse: [aCustomer orders become: Dictionary new].

	^aCustomer orders at: (SimpleAddress new postcode: (aProduct description, anInteger displayString); yourself) put: 
		(SimpleProductOrder new 
			product: aProduct; 
			quantity: anInteger; 
			customer: aCustomer; 
			yourself)
]
