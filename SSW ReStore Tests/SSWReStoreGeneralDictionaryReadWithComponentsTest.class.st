Class {
	#name : 'SSWReStoreGeneralDictionaryReadWithComponentsTest',
	#superclass : 'SSWReStoreReadWithComponentsTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
SSWReStoreGeneralDictionaryReadWithComponentsTest class >> testSelectors [

	^self myTestSelectors, #(#testRefreshCollectionKey)
]

{ #category : 'helpers' }
SSWReStoreGeneralDictionaryReadWithComponentsTest >> addOrderFor: aProduct to: aCustomer quantity: anInteger [

	"Need to convert orders to Dictionary if not already done - ensure unproxied before transformation"
	aCustomer orders _deproxify.
	(aCustomer orders isKindOf: Dictionary) ifFalse: [aCustomer orders become: Dictionary new].

	^aCustomer orders at: (SimpleAddress new postcode: (aProduct description, anInteger displayString); yourself) put: 
		(SimpleProductOrder new 
			product: aProduct; 
			quantity: anInteger; 
			customer: aCustomer; 
			yourself)
]

{ #category : 'constants' }
SSWReStoreGeneralDictionaryReadWithComponentsTest >> ordersCollectionDefinition [

	^Dictionary of: (SimpleAddress related -> SimpleProductOrder related)
]

{ #category : 'unit tests' }
SSWReStoreGeneralDictionaryReadWithComponentsTest >> testCollection [

	super testCollection.

	self validateKeysAlreadyFetched
]

{ #category : 'unit tests' }
SSWReStoreGeneralDictionaryReadWithComponentsTest >> testEmptyCollection [

	super testEmptyCollection.

	self validateKeysAlreadyFetched
]

{ #category : 'unit tests' }
SSWReStoreGeneralDictionaryReadWithComponentsTest >> testProxyCollection [

	super testProxyCollection.

	self validateKeysAlreadyFetched
]

{ #category : 'unit tests' }
SSWReStoreGeneralDictionaryReadWithComponentsTest >> testProxyCollectionMultipleRead [

	super testProxyCollectionMultipleRead.

	self validateKeysAlreadyFetched
]

{ #category : 'unit tests' }
SSWReStoreGeneralDictionaryReadWithComponentsTest >> testProxySingleObject [

	super testProxySingleObject.

	self validateKeysAlreadyFetched
]

{ #category : 'unit tests' }
SSWReStoreGeneralDictionaryReadWithComponentsTest >> testProxySingleObjectMultipleRead [

	super testProxySingleObjectMultipleRead.

	self validateKeysAlreadyFetched
]

{ #category : 'unit tests' }
SSWReStoreGeneralDictionaryReadWithComponentsTest >> testRefreshCollection [

	super testRefreshCollection.

	self validateKeysAlreadyFetched
]

{ #category : 'unit tests' }
SSWReStoreGeneralDictionaryReadWithComponentsTest >> testRefreshCollectionKey [

	| allCustomers testAddress originalPostcode |

	allCustomers := customers asOrderedCollection.
	
	testAddress := allCustomers first orders keys anyOne.
	originalPostcode := testAddress postcode.

	"Update directly in database"
	reStore executeSQLAsTxn: {('update <1s> set postcode = ''x'' where id_ = <2p>' expandMacrosWith: (reStore tableForClass: testAddress class) name with: testAddress _id)}.

	"fetch: will miss the update since testOrder already exists in the image and has been viewed/touched"
	allCustomers fetch: #orders.
	self assert: testAddress postcode equals: originalPostcode.

	"Following a soft rollback however we should pick it up"
	reStore softRollback.
	allCustomers fetch: #orders.
	self assert: testAddress postcode equals: 'x'.
	self assert: ((SimpleAddress storedInstancesIn: reStore) select: [ :each | each postcode = 'x']) size equals: 1
]

{ #category : 'unit tests' }
SSWReStoreGeneralDictionaryReadWithComponentsTest >> testRefreshProxyCollection [

	super testRefreshProxyCollection.

	self validateKeysAlreadyFetched
]

{ #category : 'unit tests' }
SSWReStoreGeneralDictionaryReadWithComponentsTest >> testRefreshSingleObject [

	super testRefreshSingleObject.

	self validateKeysAlreadyFetched
]

{ #category : 'helpers' }
SSWReStoreGeneralDictionaryReadWithComponentsTest >> validateKeysAlreadyFetched [

	"Validate the keys are correct, and ensure they are already fetched (no further queries necessary)"

	"Need to ensure products are present"
	customer4 orders do: [ :each | each product description].

	self resetQueryCount.
	customer4 orders keysAndValuesDo: [ :address :order | self assert: address postcode equals: '<1s><2p>' << {order product description. order quantity}].
	self assert: self queryCount equals: 0
]
