Class {
	#name : 'SSWReStoreDeleteDependentDictionaryTest',
	#superclass : 'SSWReStoreDeleteDependentGeneralCollectionTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
SSWReStoreDeleteDependentDictionaryTest class >> isAbstract [

	^self = SSWReStoreDeleteDependentDictionaryTest
]

{ #category : 'running' }
SSWReStoreDeleteDependentDictionaryTest >> addOrderFor: aProduct to: aCustomer quantity: anInteger [

	"Need to convert orders to Dictionary if not already done"
	reStore abandonTransaction.
	(aCustomer orders _proxiedObject isKindOf: Dictionary) ifFalse: [aCustomer orders _proxiedObject become: Dictionary new].

	^aCustomer orders at: (SimpleAddress new postcode: (aProduct description, anInteger displayString); yourself) put: 
		(SimpleProductOrder new 
			product: aProduct; 
			quantity: anInteger; 
			customer: aCustomer; 
			yourself)
]
