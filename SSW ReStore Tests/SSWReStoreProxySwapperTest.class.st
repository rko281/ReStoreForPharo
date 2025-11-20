Class {
	#name : 'SSWReStoreProxySwapperTest',
	#superclass : 'SSWReStoreProductOrdersTest',
	#instVars : [
		'ownerTest'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'asserting' }
SSWReStoreProxySwapperTest >> assertAllSwapped: aCollection [

	aCollection do: [ :each | self assertIsSwapped: each]
]

{ #category : 'asserting' }
SSWReStoreProxySwapperTest >> assertAllUnswapped: aCollection [

	aCollection do: [ :each | self assertIsUnswapped: each]
]

{ #category : 'asserting' }
SSWReStoreProxySwapperTest >> assertIsSwapped: anObject [

	| proxy |

	self deny: anObject isDBProxy.
	self assert: (reStore transaction includesProxiedObject: anObject).
	self shouldnt: [proxy := anObject _dbProxyIn: reStore] raise: Error.
	self assert: proxy _isSwapped
]

{ #category : 'asserting' }
SSWReStoreProxySwapperTest >> assertIsUnswapped: anObject [
	
	self assert: anObject isDBProxy.
	self deny: anObject _isSwapped.

	reStore hasTransaction ifTrue: 
		[self deny: (reStore transaction includesProxy: anObject).
		self deny: (reStore transaction activeProxiesMap includesKey: anObject)] "tests for previous error with removeProxy: after unswap"

]

{ #category : 'running' }
SSWReStoreProxySwapperTest >> createTestData [

	| orders |

	super createTestData.

	orders := OrderedCollection new.

	1 to: 5 do: [ :index | orders add: (SimpleProductOrder new product: widget; quantity: index; customer: customer1; yourself)].
	1 to: 5 do: [ :index | orders add: (SimpleProductOrder new product: widget; quantity: index; customer: customer2; yourself)].

	orders storeAllIn: reStore.
	{customer1. customer2} refreshAll.

	"Also need to test general collections"
	ownerTest := 
		OwnerTest new
			arrayOfNames: #('a' 'b') copy;
			ordered: (#('a' 'b' 'c') collect: [ :each | Test new name: each]);
			keyedBaseDictionary: (Dictionary withAll: (#('a' 'b' 'c') collect: [ :each | each -> (Test new name: each)]));
			keyedIdentityDictionary: (Dictionary withAll: ({'a' -> 'x'. 'b' -> 'y'. 'c' -> 'z'} collect: [ :each | (Test new name: each key) -> (Test new name: each value)]));
			yourself.
	ownerTest selfReferencingOrdered: (OrderedCollection with: OwnerTest new with: OwnerTest new with: ownerTest).
	ownerTest storeIn: reStore.
	ownerTest refresh
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testDumbTransactionAbandon [

	"Verify abandoning a dumb transaction unswaps touched objects"

	| orders sampleOrder product |

	orders := customer1 orders.
	sampleOrder := orders first.
	product := sampleOrder product.
	product description.

	ownerTest arrayOfNames first.
	ownerTest ordered first name.
	ownerTest keyedBaseDictionary do: [ :each | each name].
	ownerTest keyedIdentityDictionary keysAndValuesDo: [ :a :b | a name. b name].

	self assertAllSwapped: {customer1. orders. sampleOrder. product}.
	self assertAllSwapped: 
		{ownerTest. ownerTest arrayOfNames. ownerTest ordered. ownerTest ordered first. 
		ownerTest keyedBaseDictionary. ownerTest keyedBaseDictionary values anyOne. 
		ownerTest keyedIdentityDictionary. ownerTest keyedIdentityDictionary keys anyOne. ownerTest keyedIdentityDictionary values anyOne}.
	
	reStore abandonTransaction.

	self assertAllUnswapped: {customer1. orders. sampleOrder. product}.
	self assertAllUnswapped: 
		{ownerTest. ownerTest _proxiedObject arrayOfNames. ownerTest _proxiedObject ordered. ownerTest _proxiedObject ordered _proxiedObject first. 
		ownerTest _proxiedObject keyedBaseDictionary. ownerTest _proxiedObject keyedBaseDictionary _proxiedObject values anyOne. 
		ownerTest _proxiedObject keyedIdentityDictionary. ownerTest _proxiedObject keyedIdentityDictionary _proxiedObject keys anyOne. ownerTest _proxiedObject keyedIdentityDictionary _proxiedObject values anyOne}
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testPersistentComponentCollectionSwapping [

	"Verify swapping a collection proxy also swaps its persistent elements"

	| orders |

	orders := customer1 orders.

	self 
		assertIsUnswapped: orders;
		assertAllUnswapped: orders _proxiedObject;
		assertAllUnswapped: {ownerTest arrayOfNames. ownerTest ordered. ownerTest keyedBaseDictionary. ownerTest keyedIdentityDictionary};
		assertAllUnswapped: ownerTest ordered _proxiedObject;
		assertAllUnswapped: ownerTest keyedBaseDictionary _proxiedObject values;
		assertAllUnswapped: ownerTest keyedIdentityDictionary _proxiedObject keys;
		assertAllUnswapped: ownerTest keyedIdentityDictionary _proxiedObject values.
	
	"Swap collections via a trivial message"
	orders _deproxify.
	ownerTest arrayOfNames _deproxify.
	ownerTest ordered _deproxify.
	ownerTest keyedBaseDictionary _deproxify.
	ownerTest keyedIdentityDictionary _deproxify.

	"Ensure collections and their contents are all swapped"
	self 	
		assertIsSwapped: orders;
		assertAllSwapped: orders;
		assertAllSwapped: {ownerTest arrayOfNames. ownerTest ordered. ownerTest keyedBaseDictionary. ownerTest keyedIdentityDictionary};
		assertAllSwapped: ownerTest ordered;
		assertAllSwapped: ownerTest keyedBaseDictionary values;
		assertAllSwapped: ownerTest keyedIdentityDictionary keys;
		assertAllSwapped: ownerTest keyedIdentityDictionary values
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testPersistentComponentSelfReferencingCollectionSwapping [

	"Verify swapping a collection proxy also swaps its persistent elements.
	Specific sub-case - the collection contains a reference to its owner"

	| collectionSpec collectionProxy |

	self 
		assertIsUnswapped: ownerTest selfReferencingOrdered;
		assertAllUnswapped: (ownerTest selfReferencingOrdered _proxiedObject first: 2); "owner is last"
		assertIsSwapped: (ownerTest selfReferencingOrdered _proxiedObject last);
		assert: (ownerTest selfReferencingOrdered _proxiedObject last) identicalTo: ownerTest.
	
	ownerTest selfReferencingOrdered _deproxify.

	self 
		assertIsSwapped: ownerTest selfReferencingOrdered;
		assertAllSwapped: ownerTest selfReferencingOrdered;
		assert: (ownerTest selfReferencingOrdered last) identicalTo: ownerTest.

	"Verify internal structure is correct"
	collectionSpec := (reStore tableForClass: OwnerTest) collectionSpecs detect: [ :each | each accessor name = #selfReferencingOrdered].
	collectionProxy := (ownerTest _dbProxyIn: reStore) _collectionProxies at: collectionSpec.

	self assert: collectionProxy isDBProxy.
	self assert: collectionProxy _owner isDBProxy
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testPersistentComponentSelfReferencingCollectionSwappingOwnerUnswapped [

	"Verify swapping a collection proxy also swaps its persistent elements.
	Specific sub-case - the collection contains a reference to its owner AND the owner is unswapped"

	| collection collectionSpec collectionProxy |

	collection := ownerTest selfReferencingOrdered.
	reStore unswapAll: {ownerTest}.

	self 
		assertIsUnswapped: collection;
		assertAllUnswapped: collection _proxiedObject.
	
	collection _deproxify.

	self 
		assertIsSwapped: ownerTest selfReferencingOrdered;
		assertAllSwapped: ownerTest selfReferencingOrdered;
		assert: (ownerTest selfReferencingOrdered last) identicalTo: ownerTest.

	"Verify internal structure is correct"
	collectionSpec := (reStore tableForClass: OwnerTest) collectionSpecs detect: [ :each | each accessor name = #selfReferencingOrdered].
	collectionProxy := (ownerTest _dbProxyIn: reStore) _collectionProxies at: collectionSpec.

	self assert: collectionProxy isDBProxy.
	self assert: collectionProxy _owner isDBProxy
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testPreSwappingDumbTransaction [

	| allObjects |

	reStore dumbTransactionClass: SSWDBPreSwappingDumbTransaction.
	reStore ensureNoActiveTransaction.

	allObjects := OrderedCollection new.
	reStore tableCache keysDo: 
		[ :cls |
		allObjects addAll: (cls storedInstancesIn: reStore) asOrderedCollection].

	self deny: reStore hasTransaction.

	"Referencing one object should swap everything"
	allObjects first _deproxify.

	self assert: reStore hasTransaction.
	self assert: reStore transaction class equals: SSWDBPreSwappingDumbTransaction.
	self deny: reStore transaction isEmpty.
	self assert: (reStore proxyCache allSatisfy: [ :proxies | proxies allSatisfy: [ :each | each isDBProxy not]]).

	"Also check collection proxies have been swapped"
	self assert: ({customer1. customer2. customer3. customer4} allSatisfy: [ :each | each orders isDBProxy not])
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testPreserveSwappedProxiesFollowingCommit [

	"Verify that swapped objects are preserved following a transaction commit"

	| orders sampleOrder product deletedProduct |

	orders := customer1 orders.
	sampleOrder := orders first.
	product := sampleOrder product.
	product description: 'updated'.
	deletedProduct := wobulator.
	deletedProduct description.

	self assertAllSwapped: {customer1. orders. sampleOrder. product. deletedProduct}.

	reStore enterDebugMode.
	reStore preserveSwappedProxiesFollowingTransaction: [{product. deletedProduct unstored} storeAll].
	
	self assertAllSwapped: {customer1. orders. sampleOrder. product}.
	self deny: deletedProduct isDBProxy.
	self assert: (deletedProduct _dbProxyIn: reStore ifNone: [nil]) isNil
	
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testPreserveSwappedProxiesFollowingLazyRefreshAll [

	"Verify that swapped objects can be preserved after a lazyRefreshAll: operation"

	| orders sampleOrder product deletedProduct reStore2 products2 |

	orders := customer1 orders.
	sampleOrder := orders first.
	product := sampleOrder product.
	product description.
	deletedProduct := wobulator.
	deletedProduct description.

	self assertAllSwapped: {customer1. orders. sampleOrder. product. deletedProduct}.

	"Update in another session"
	reStore2 := SSWReStore new.
	self initReStore: reStore2.
	reStore2 connect.
	products2 := SimpleProduct storedInstancesIn: reStore2.
	reStore2 evaluateAsTransaction:
		[(products2 detect: [ :each | each _id = product _id]) description: 'updated2'.
		(products2 detect: [ :each | each _id = deletedProduct _id]) unstore].
	reStore2 disconnect.
	
	reStore preserveSwappedProxiesFollowingTransaction: [reStore lazyRefreshAll: {product. deletedProduct}].
	
	self assertAllSwapped: {customer1. orders. sampleOrder}.
	self assertIsUnswapped: product. "due to lazy refresh"
	self assert: product description equals: 'updated2'.
	self assert: deletedProduct isDBDeleted
	
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testPreserveSwappedProxiesFollowingRefresh [

	"Verify that swapped objects are preserved following a transaction refresh"

	| orders sampleOrder product deletedProduct reStore2 products2 |

	orders := customer1 orders.
	sampleOrder := orders first.
	product := sampleOrder product.
	product description.
	deletedProduct := wobulator.
	deletedProduct description.

	self assertAllSwapped: {customer1. orders. sampleOrder. product. deletedProduct}.

	"Update in another session"
	reStore2 := SSWReStore new.
	self initReStore: reStore2.
	reStore2 connect.
	products2 := SimpleProduct storedInstancesIn: reStore2.
	reStore2 evaluateAsTransaction:
		[(products2 detect: [ :each | each _id = product _id]) description: 'updated2'.
		(products2 detect: [ :each | each _id = deletedProduct _id]) unstore].
	reStore2 disconnect.
	
	reStore preserveSwappedProxiesFollowingTransaction: [{product. deletedProduct} refreshAll].
	
	self assertAllSwapped: {customer1. orders. sampleOrder. product}.
	self assert: product description equals: 'updated2'.
	self assert: deletedProduct isDBDeleted
	
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testPreserveSwappedProxiesFollowingRollback [

	"Verify that swapped objects are preserved following a transaction rollback"

	| orders sampleOrder product |

	orders := customer1 orders.
	sampleOrder := orders first.
	product := sampleOrder product.
	product description: 'updated'.

	self assertAllSwapped: {customer1. orders. sampleOrder. product}.

	reStore enterDebugMode.
	reStore preserveSwappedProxiesFollowingTransaction: [product rollback].
	
	self assertAllSwapped: {customer1. orders. sampleOrder. product}.
	self assert: product description equals: 'widget'
	
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testSwapAll [

	"Test the ability to swap all recovered persistent objects"

	| allCustomers allOrderCollections allOrders allProducts |

	allCustomers := (SimplePerson storedInstancesIn: reStore) asOrderedCollection.
	self assertAllUnswapped: allCustomers.
	allOrderCollections := allCustomers collect: [ :each | each _proxiedObject orders].
	self assertAllUnswapped: allOrderCollections.
	allOrders := (SimpleProductOrder storedInstancesIn: reStore) asOrderedCollection.
	self assertAllUnswapped: allOrders.
	allProducts := (SimpleProduct storedInstancesIn: reStore) asOrderedCollection.
	self assertAllUnswapped: allProducts.

	"Also test that having already-swapped objects doesn't cause issues"
	wobulator description.
	customer2 _proxiedObject orders first.
	self assertAllSwapped: {wobulator. customer2 _proxiedObject orders}.

	reStore swapAll.

	self assertAllSwapped: allCustomers.
	
	self 
		assertAllSwapped: allOrderCollections;
		assertAllSwapped: allOrders;
		assertAllSwapped: allProducts.

	"Validate swapped objects have been tracked by abandoing the dumb transaction"
	self shouldnt: [reStore abandonTransaction] raise: Error.

	self assertAllUnswapped: allCustomers.
	allOrderCollections := allCustomers collect: [ :each | each _proxiedObject orders].
	self 
		assertAllUnswapped: allOrderCollections;
		assertAllUnswapped: allOrders;
		assertAllUnswapped: allProducts
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testSwapCollectionsOnly [

	"Test the requested swapping of collections"

	| orders sampleOrder |

	self assertIsUnswapped: customer1.
	orders := customer1 _proxiedObject orders.
	self assertIsUnswapped: orders.
	sampleOrder := orders _proxiedObject anyOne.
	self assertIsUnswapped: sampleOrder.

	reStore swapAll: {orders}.
	self assertIsSwapped: orders.

	self assertAllUnswapped: {customer1. sampleOrder}
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testSwapObjectsAndCollections [

	"Test objects' collections are swapped even when not explicitly requested"

	| orders sampleOrder product array ordered baseDictionary identityDictionary |

	self assertIsUnswapped: customer1.
	orders := customer1 _proxiedObject orders.
	self assertIsUnswapped: orders.
	sampleOrder := orders _proxiedObject anyOne.
	self assertIsUnswapped: sampleOrder.
	product := sampleOrder _proxiedObject product.
	self assertIsUnswapped: product.

	self assertIsUnswapped: ownerTest.
	array := ownerTest _proxiedObject arrayOfNames.
	ordered := ownerTest _proxiedObject ordered.
	baseDictionary := ownerTest _proxiedObject keyedBaseDictionary.
	identityDictionary := ownerTest _proxiedObject keyedIdentityDictionary.
	self assertAllUnswapped: {array. ordered. baseDictionary. identityDictionary}.

	reStore swapAll: {customer1. product. ownerTest}.

	self assertAllSwapped: {customer1. orders. product}.
	self assertAllSwapped: {array. ordered. baseDictionary. identityDictionary}.

	self assertIsUnswapped: sampleOrder
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testSwapObjectsAndCollectionsWithSwappedObject [

	"Test the customer's collections are swapped even when not explicitly requested and the customer is already swapped"

	| orders sampleOrder product |

	orders := customer1 orders.
	self assertIsSwapped: customer1.
	self assertIsUnswapped: orders.
	sampleOrder := orders _proxiedObject anyOne.
	self assertIsUnswapped: sampleOrder.
	product := sampleOrder _proxiedObject product.
	self assertIsUnswapped: product.
	
	reStore swapAll: {customer1. product}.
	self assertAllSwapped: {customer1. orders. product}.

	self assertIsUnswapped: sampleOrder
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testSwapObjectsRecoveredDuring [

	"Test the ability to swap persistent objects during evaluation of a Block"

	| allOrders allCustomers allOrderCollections allProducts |

	reStore simulateReconnect.

	"Pre-recover some objects"
	allOrders := (SimpleProductOrder storedInstancesIn: reStore) asOrderedCollection.
	self assertAllUnswapped: allOrders.

	"Fetch others but stub them out so they are re-recovered"
	allProducts := (SimpleProduct storedInstancesIn: reStore) asOrderedCollection.
	self assertAllUnswapped: allProducts.
	allProducts do: [ :each | each _forgetProxiedObject].

	reStore swapObjectsRecoveredDuring:
		[allCustomers := 
			(SimplePerson storedInstancesIn: reStore) 
				include: #orders;
				asOrderedCollection.
		allProducts := (SimpleProduct storedInstancesIn: reStore) asOrderedCollection].

	self assertAllSwapped: allCustomers.
	allOrderCollections := allCustomers collect: [ :each | each orders].
	self assertAllSwapped: allOrderCollections.
	self assertAllSwapped: allProducts.

	"Orders were not recovered during aBlock so should not be swapped"
	self assertAllUnswapped: allOrders
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testSwapObjectsRecursively [

	| orders sampleOrder product array ordered baseDictionary identityDictionary any1 any2 any3 any4 |

	self assertIsUnswapped: customer1.
	orders := customer1 _proxiedObject orders.
	self assertIsUnswapped: orders.
	sampleOrder := orders _proxiedObject anyOne.
	self assertIsUnswapped: sampleOrder.
	product := sampleOrder _proxiedObject product.
	self assertIsUnswapped: product.
	self assertAllUnswapped: {customer2. gadget}.

	self assertIsUnswapped: ownerTest.
	array := ownerTest _proxiedObject arrayOfNames.
	ordered := ownerTest _proxiedObject ordered.
	baseDictionary := ownerTest _proxiedObject keyedBaseDictionary.
	identityDictionary := ownerTest _proxiedObject keyedIdentityDictionary.
	any1 := ordered _proxiedObject anyOne.
	any2 := baseDictionary _proxiedObject anyOne.
	any3 := identityDictionary _proxiedObject anyOne.
	any4 := identityDictionary _proxiedObject keys anyOne.
	self assertAllUnswapped: {array. ordered. baseDictionary. identityDictionary. any1. any2. any3. any4}.

	reStore swapAllRecursively: {customer1. ownerTest}.
	self 
		assertAllSwapped: {customer1. orders. sampleOrder. product};
		assertAllSwapped: orders;
		assertAllSwapped: {array. ordered. baseDictionary. identityDictionary};
		assertAllSwapped: ordered;
		assertAllSwapped: baseDictionary;
		assertAllSwapped: identityDictionary;
		assertAllSwapped: identityDictionary keys.

	self assertAllUnswapped: {customer2. gadget}
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testSwapObjectsRecursivelyWithIntermerdiateSwappedCollection [

	| orders sampleOrder product |

	self assertIsUnswapped: customer1.
	orders := customer1 _proxiedObject orders.
	sampleOrder := orders anyOne.
	self assertIsSwapped: orders.
	reStore unswapAll: orders.
	self assertIsUnswapped: sampleOrder.
	self assertAllUnswapped: orders.
	product := sampleOrder _proxiedObject product.
	self assertIsUnswapped: product.
	self assertAllUnswapped: {customer2. gadget}.

	reStore swapAllRecursively: {customer1}.
	self 
		assertAllSwapped: {customer1. orders. sampleOrder. product};
		assertAllSwapped: orders.

	self assertAllUnswapped: {customer2. gadget}
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testSwapObjectsRecursivelyWithIntermerdiateSwappedObject [

	| orders sampleOrder product |

	self assertIsUnswapped: customer1.
	orders := customer1 _proxiedObject orders.
	self assertIsUnswapped: orders.
	sampleOrder := orders _proxiedObject anyOne.
	product := sampleOrder product.
	self assertIsSwapped: sampleOrder.
	self assertIsUnswapped: product.
	self assertAllUnswapped: {customer2. gadget}.

	reStore swapAllRecursively: {customer1}.
	self 
		assertAllSwapped: {customer1. orders. sampleOrder. product};
		assertAllSwapped: orders.

	self assertAllUnswapped: {customer2. gadget}
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testUnswapCollectionsOnly [

	"Test the requested unswapping of collections"

	| orders sampleOrder product |

	orders := customer1 orders.
	sampleOrder := orders first.
	product := sampleOrder product.
	product description.

	self assertAllSwapped: {customer1. orders. sampleOrder. product}.

	reStore unswapAll: {orders}.
	self assertIsUnswapped: orders.

	self assertAllSwapped: {customer1. sampleOrder. product}
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testUnswapObjectsAndCollections [

	"Test the customer's collections are unswapped even when not explicitly requested"

	| orders sampleOrder product array ordered baseDictionary identityDictionary |

	orders := customer1 orders.
	sampleOrder := orders first.
	product := sampleOrder product.
	product description.
	self assertAllSwapped: {customer1. orders. sampleOrder. product}.

	array := ownerTest arrayOfNames.
	ordered := ownerTest ordered.
	baseDictionary := ownerTest keyedBaseDictionary.
	identityDictionary := ownerTest keyedIdentityDictionary.
	array anyOne.
	ordered anyOne.
	baseDictionary anyOne.
	identityDictionary anyOne.
	self assertAllSwapped: {array. ordered. baseDictionary. identityDictionary}.
	
	reStore unswapAll: {customer1. product. ownerTest}.

	self assertAllUnswapped: {customer1. orders. product}.
	self assertAllUnswapped: {array. ordered. baseDictionary. identityDictionary}.

	self assertIsSwapped: sampleOrder
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testUnswapObjectsRecursively [


	| orders sampleOrder product array ordered baseDictionary identityDictionary any1 any2 any3 any4 |

	orders := customer1 orders.
	sampleOrder := orders first.
	product := sampleOrder product.
	product description.
	self assertAllSwapped: {customer1. orders. sampleOrder. product}.

	array := ownerTest arrayOfNames.
	ordered := ownerTest ordered.
	baseDictionary := ownerTest keyedBaseDictionary.
	identityDictionary := ownerTest keyedIdentityDictionary.
	array anyOne.
	any1 := ordered anyOne name; yourself.
	any2 := baseDictionary anyOne name; yourself.
	any3 := identityDictionary anyOne name; yourself.
	any4 := identityDictionary keys anyOne name; yourself.
	self assertAllSwapped: {array. ordered. baseDictionary. identityDictionary. any1. any2. any3. any4}.

	reStore unswapAllRecursively: {customer1. ownerTest}.

	self assertAllUnswapped: {customer1. orders. product. sampleOrder}.
	self assertAllUnswapped: {array. ordered. baseDictionary. identityDictionary. any1. any2. any3. any4}
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testUnswapObjectsRecursivelyWithIntermediateSwappedCollection [

	| orders sampleOrder product |

	orders := customer1 orders.
	self assertIsUnswapped: orders.
	sampleOrder := orders _proxiedObject first.
	product := sampleOrder product.
	product description.

	self assertAllSwapped: {customer1. sampleOrder. product}.
	self assertIsUnswapped: orders.

	reStore unswapAllRecursively: {customer1}.
	self assertAllUnswapped: {customer1. orders. product. sampleOrder}
]

{ #category : 'unit tests' }
SSWReStoreProxySwapperTest >> testUnswapObjectsRecursivelyWithIntermediateSwappedObject [

	| orders sampleOrder product |

	orders := customer1 orders.
	sampleOrder := orders first.
	reStore unswapAll: {sampleOrder}.
	self assertIsUnswapped: sampleOrder.
	product := sampleOrder _proxiedObject product.
	product description.

	self assertAllSwapped: {customer1. orders. product}.
	self assertIsUnswapped: sampleOrder.

	reStore unswapAllRecursively: {customer1}.
	self assertAllUnswapped: {customer1. orders. product. sampleOrder}
]
