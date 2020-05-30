"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreQueryTest,
	#superclass : #SSWReStoreAbstractQueryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #Running }
SSWReStoreQueryTest >> addClassesTo: aReStore [

	super addClassesTo: aReStore.
	aReStore
		addClass: SimpleProduct
]

{ #category : #helpers }
SSWReStoreQueryTest >> convertToDictionary: results index: anInteger [

	| dict |

	dict := IdentityDictionary new.
	results do: [ :each | (each at: anInteger) ifNotNil: [ :key | dict at: key put: (each asOrderedCollection removeAtIndex: anInteger; asArray)]].
	^dict
]

{ #category : #Running }
SSWReStoreQueryTest >> createProducts [

	reStore evaluateAsTransaction: 
		[SimpleProduct new
			description: 'widget';
			supplierPrice: 1;
			retailPrice: 1.2;
			storeIn: reStore.
		SimpleProduct new
			description: 'gadget';
			supplierPrice: 5;
			retailPrice: 6;
			storeIn: reStore.
		SimpleProduct new
			description: 'wobulator';
			supplierPrice: 100;
			retailPrice: 200;
			storeIn: reStore]
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> test1Simple [

	| instances |

	instances := SimplePerson storedInstancesIn: reStore.

	self assert: (instances size = 4).

	self assert: (instances allSatisfy: [ :each | (each surname ~= nil) & (each firstName ~= nil)]).
	
	self assert: (instances anySatisfy: [ :each | each surname = 'Smith']).
	self assert: (instances satisfying: [ :each | each surname = 'Smith']) size = 1.
	self assert: (instances satisfying: [ :each | each surname = 'Smith']) first firstName = 'John'.

	instances := instances satisfying: [ :each | each surname = 'Brown'].
	self assert: (instances size = 2).
	self assert: (instances detect: [ :each | each firstName = 'Zoe']) emailAddress isNil.
	self assert: ((instances project: [ :each | each surname]) asArray = #('Brown')).

	instances := instances satisfying: [ :each | each emailAddress ~= nil].
	self assert: (instances size = 1).
	self assert: (instances anySatisfy: [ :each | each emailAddress = 'jim@somewhere'])

]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> test2Wildcards [

	| instances |

	instances := (SimplePerson storedInstancesIn: reStore) satisfying:  [ :each | 'Sm*' match: each surname].

	self assert: (instances isEmpty not).
	self assert: (instances size = 2).
	self assert: ((instances collect: [ :each | each firstName]) asSortedCollection asArray = #('David' 'John'))
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> test3Order [

	| instances |

	instances := (SimplePerson storedInstancesIn: reStore) satisfying: [ :each | each surname = 'Brown'].
	instances sortBlock: [ :a :b | a firstName <= b firstName].

	self assert: (instances first firstName = 'Jim').
	self assert: (instances last firstName = 'Zoe').

	instances sortBlock: [ :a :b | a firstName > b firstName].
	self assert: (instances first firstName = 'Zoe').
	self assert: (instances last firstName = 'Jim').

]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> test3Sort [

	| instances |

	instances := (SimplePerson storedInstancesIn: reStore) satisfying: [ :each | each surname = 'Brown'].
	self assert: ((instances asSortedCollection: [ :a :b | a firstName <= b firstName]) first firstName = 'Jim').

	instances sortBlock: [ :a :b | a firstName > b firstName].
	self assert: ((instances collect: [ :each | each firstName]) asArray = #('Zoe' 'Jim'))
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> test4Modify [

	| instances |

	instances := (SimplePerson storedInstancesIn: reStore) satisfying: [ :each | each surname = 'Brown'].
	self assert: (instances anySatisfy: [ :e | e emailAddress = '<unknown>']) not.

	instances modify: [ :e | e emailAddress: '<unknown>'].
	self assert: (instances allSatisfy: [ :e | e emailAddress = '<unknown>']).

"	instances := instances satisfying: [ :each | each firstName = 'Zoe'].
	self assert: (instances anySatisfy: [ :e | e friend emailAddress = '<friend_unknown>']) not.

	instances modify: [ :e | e friend emailAddress: '<unknown>'].
	self assert: (instances allSatisfy: [ :e | e friend emailAddress = '<unknown>']).
"
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> test5InlineFunctionQuery [

	| instances |

	instances := SimplePerson storedInstancesIn: reStore.
	instances := instances satisfying: [ :each | (each firstName, ' ', each surname) = 'Jim Brown'].
	self assert: (instances size = 1)
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> test6MethodFunctionQuery [

	| instances |

	instances := SimplePerson storedInstancesIn: reStore.
	instances := instances satisfying: [ :each | each fullName = 'Jim Brown'].
	self assert: (instances size = 1)
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> test6MethodFunctionQueryWithDirectInstVars [

	"Unsupported - should fail"

	| instances |

	instances := SimplePerson storedInstancesIn: reStore.
	self should: [instances := instances satisfying: [ :each | each fullNameDirect = 'Jim Brown']] raise: Error
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> test7InlineFunctionQueryComplex [

	| instances |

	self createProducts.

	instances := SimpleProduct storedInstancesIn: reStore.

	instances := instances satisfying: [ :each | (each supplierPrice \\ 5) = 0].
	self assert: (instances size = 2)
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> test7MethodFunctionQueryComplex [

	| instances |

	self createProducts.

	instances := SimpleProduct storedInstancesIn: reStore.
	self assert: ((instances detect: [ :each | each profitMargin > 50]) description = 'wobulator')
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> test8CustomQuery [

	| instances results|

	self createProducts.

	reStore translateMessage: #plusPercent: toFunction: '%1 * (1 + (%2 / 100))' asSQLFunction.

	instances := SimpleProduct storedInstancesIn: reStore.
	results := instances collect: [ :each | each supplierPrice plusPercent: 100].
	self assert: (results asSortedCollection asArray = #(2 10 200))
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> test9MultiArgumentFieldQuery [

	| instances results|

	self createProducts.

	instances := SimpleProduct storedInstancesIn: reStore.

	"Nonsensical query, but tests a previously failing case with functions with > 1 argument, whose arguments are other fields (or functions thereof)"
	results := instances select: [ :each | each retailPrice between: each supplierPrice and: each description size].
	self assert: (results size = 2)
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> testAMultiArgumentMixedQuery [

	| instances results|

	self createProducts.

	instances := SimpleProduct storedInstancesIn: reStore.

	"Nonsensical query, but tests a previously failing case with functions with > 1 argument, whose arguments are a mix of constants and other fields (or functions thereof)"
	results := instances select: [ :each | each retailPrice between: each supplierPrice and: 10].
	self assert: (results size = 2)
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> testBMultiArgumentFunctionCollectFieldQuery [

	| instances results|

	self createProducts.

	instances := (SimpleProduct storedInstancesIn: reStore) satisfying: [ :each | each description = 'gadget'].

	"Nonsensical query, but tests a previously failing case with functions with > 1 argument, whose arguments are other fields (or functions thereof)"
	results := instances collect: [ :each | each description midString: (each retailPrice - each supplierPrice) asInteger + 1 from: each supplierPrice asInteger].
	self assert: (results asArray = #('et'))
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> testCMultiArgumentFunctionCollectMixedQuery [

	| instances results|

	self createProducts.

	instances := (SimpleProduct storedInstancesIn: reStore) satisfying: [ :each | each description = 'gadget'].

	"Nonsensical query, but tests a previously failing case with functions with > 1 argument, whose arguments are a mix of constants and other fields (or functions thereof)"	
	results := instances collect: [ :each | each description midString: (each retailPrice - each supplierPrice) asInteger + 1 from: 5].
	self assert: (results asArray = #('et'))
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> testCollectQuery [

	| instances john results |

	instances := SimplePerson storedInstancesIn: reStore.

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	"Test various combinations and orderings"
	results := ((instances collect: [ :each | each firstName || each surname || each friend firstName || each friend surname]) asSortedCollection: [ :a :b | a first <= b first]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #('David' 'Smythe' nil nil)).
	self assert: ((results at: 2) = #('Jim' 'Brown' nil nil)).
	self assert: ((results at: 3) = #('John' 'Smith' 'David' 'Smythe')).
	self assert: ((results at: 4) = #('Zoe' 'Brown' 'John' 'Smith')).

	results := ((instances collect: [ :each | each friend firstName || each friend surname || each firstName || each surname]) asSortedCollection: [ :a :b | (a at: 3) <= (b at: 3)]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #(nil nil 'David' 'Smythe')).
	self assert: ((results at: 2) = #(nil nil 'Jim' 'Brown')).
	self assert: ((results at: 3) = #('David' 'Smythe' 'John' 'Smith')).
	self assert: ((results at: 4) = #('John' 'Smith' 'Zoe' 'Brown')).

	results := ((instances collect: [ :each | each firstName || each friend surname || each friend firstName || each surname]) asSortedCollection: [ :a :b | a first <= b first]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #('David' nil nil 'Smythe')).
	self assert: ((results at: 2) = #('Jim' nil nil 'Brown')).
	self assert: ((results at: 3) = #('John' 'Smythe' 'David' 'Smith')).
	self assert: ((results at: 4) = #('Zoe' 'Smith' 'John' 'Brown')).
	
	results := ((instances collect: [ :each | each friend firstName || each surname || each firstName || each friend surname]) asSortedCollection: [ :a :b | (a at: 3) <= (b at: 3)]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #(nil 'Smythe' 'David' nil)).
	self assert: ((results at: 2) = #(nil 'Brown' 'Jim' nil)).
	self assert: ((results at: 3) = #('David' 'Smith' 'John' 'Smythe')).
	self assert: ((results at: 4) = #('John' 'Brown' 'Zoe' 'Smith')).

	results := ((instances collect: [ :each | each firstName || each friend firstName|| each test name || each surname]) asSortedCollection: [ :a :b | a first <= b first]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #('David' nil nil 'Smythe')).
	self assert: ((results at: 2) = #('Jim' nil nil 'Brown')).
	self assert: ((results at: 3) = #('John' 'David' 'jTest' 'Smith')).
	self assert: ((results at: 4) = #('Zoe' 'John' nil 'Brown')).

	results := ((instances collect: [ :each | each test name || each firstName|| each friend firstName || each surname]) asSortedCollection: [ :a :b | (a at: 2) <= (b at: 2)]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #(nil 'David' nil 'Smythe')).
	self assert: ((results at: 2) = #(nil 'Jim' nil 'Brown')).
	self assert: ((results at: 3) = #('jTest' 'John' 'David' 'Smith')).
	self assert: ((results at: 4) = #(nil 'Zoe' 'John' 'Brown')).
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> testCollectQueryWithActualObject [

	| instances john dave zoe jim testBlock testCount |

	instances := SimplePerson storedInstancesIn: reStore.

	john := instances detect: [ :each | each firstName = 'John'].
	dave := instances detect: [ :each | each firstName = 'David'].
	zoe := instances detect: [ :each | each firstName = 'Zoe'].
	jim := instances detect: [ :each | each firstName = 'Jim'].

	testCount := 0.
	testBlock := 
		[ :results :position || dict |
		dict := self convertToDictionary: results index: position.
		self assert: (dict size = 4).
		self assert: ((dict at: john) = #('John' 'Smith' 'David' 'Smythe')).
		self assert: ((dict at: zoe) = #('Zoe' 'Brown' 'John' 'Smith')).
		self assert: ((dict at: dave) = #('David' 'Smythe' nil nil)).
		self assert: ((dict at: jim) = #('Jim' 'Brown' nil nil)).
		testCount := testCount + 1].

	"Test with the actual object at different positions in the query block"
	testBlock value: (instances collect: [ :each | each || each firstName || each surname || each friend firstName || each friend surname]) value: 1.
	"NB: With each at position 2 in the query block we actually get (and expect) the object at position 1 in the results (its appearance at position 2 can't be (easily) detected compared to position 1 due to lack distinguishing message send)"
	testBlock value: (instances collect: [ :each | each firstName || each || each surname || each friend firstName || each friend surname]) value: 1.
	testBlock value: (instances collect: [ :each | each firstName || each surname || each || each friend firstName || each friend surname]) value: 3.
	testBlock value: (instances collect: [ :each | each firstName || each surname || each friend firstName || each || each friend surname]) value: 4.
	testBlock value: (instances collect: [ :each | each firstName || each surname || each friend firstName || each friend surname || each]) value: 5.

	"Ensure we actually did some testing"
	self assert: (testCount = 5)
]

{ #category : #tests }
SSWReStoreQueryTest >> testCollectQueryWithBooleanFunction [

	"Test a condition which previously caused an error - non-first component in collect query having a Boolean function gave error due to incorrect implementation of peekFinalField"

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.
	(instances detect: [ :each | each firstName = 'Jim']) isDeceased: true; store.

	self shouldnt: [results := instances collect: [ :each | each firstName || each isDeceased not]] raise: Error.
	results := (results asSortedCollection: [ :a :b | (a at: 1) <= (b at: 1)]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #('David' true)).
	self assert: ((results at: 2) = #('Jim' false)).
	self assert: ((results at: 3) = #('John' true)).
	self assert: ((results at: 4) = #('Zoe' true)).

	self shouldnt: [results := instances collect: [ :each | each firstName || each surname || each isDeceased not]] raise: Error.
	results := (results asSortedCollection: [ :a :b | (a at: 1) <= (b at: 1)]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #('David' 'Smythe' true)).
	self assert: ((results at: 2) = #('Jim' 'Brown' false)).
	self assert: ((results at: 3) = #('John' 'Smith' true)).
	self assert: ((results at: 4) = #('Zoe' 'Brown' true)).

]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> testCollectQueryWithFunction [

	| instances john results |

	instances := SimplePerson storedInstancesIn: reStore.

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	"Test various combinations and orderings"
	results := ((instances collect: [ :each | each firstName || each surname || (each friend firstName, ' ', each friend surname)]) asSortedCollection: [ :a :b | a first <= b first]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #('David' 'Smythe' nil)).
	self assert: ((results at: 2) = #('Jim' 'Brown' nil)).
	self assert: ((results at: 3) = #('John' 'Smith' 'David Smythe')).
	self assert: ((results at: 4) = #('Zoe' 'Brown' 'John Smith')).
"
	results := ((instances collect: [ :each | each friend firstName || each friend surname || each firstName || each surname]) asSortedCollection: [ :a :b | (a at: 3) <= (b at: 3)]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #(nil nil 'David' 'Smythe')).
	self assert: ((results at: 2) = #(nil nil 'Jim' 'Brown')).
	self assert: ((results at: 3) = #('David' 'Smythe' 'John' 'Smith')).
	self assert: ((results at: 4) = #('John' 'Smith' 'Zoe' 'Brown')).

	results := ((instances collect: [ :each | each firstName || each friend surname || each friend firstName || each surname]) asSortedCollection: [ :a :b | a first <= b first]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #('David' nil nil 'Smythe')).
	self assert: ((results at: 2) = #('Jim' nil nil 'Brown')).
	self assert: ((results at: 3) = #('John' 'Smythe' 'David' 'Smith')).
	self assert: ((results at: 4) = #('Zoe' 'Smith' 'John' 'Brown')).
	
	results := ((instances collect: [ :each | each friend firstName || each surname || each firstName || each friend surname]) asSortedCollection: [ :a :b | (a at: 3) <= (b at: 3)]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #(nil 'Smythe' 'David' nil)).
	self assert: ((results at: 2) = #(nil 'Brown' 'Jim' nil)).
	self assert: ((results at: 3) = #('David' 'Smith' 'John' 'Smythe')).
	self assert: ((results at: 4) = #('John' 'Brown' 'Zoe' 'Smith')).

	results := ((instances collect: [ :each | each firstName || each friend firstName|| each test name || each surname]) asSortedCollection: [ :a :b | a first <= b first]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #('David' nil nil 'Smythe')).
	self assert: ((results at: 2) = #('Jim' nil nil 'Brown')).
	self assert: ((results at: 3) = #('John' 'David' 'jTest' 'Smith')).
	self assert: ((results at: 4) = #('Zoe' 'John' nil 'Brown')).

	results := ((instances collect: [ :each | each test name || each firstName|| each friend firstName || each surname]) asSortedCollection: [ :a :b | (a at: 2) <= (b at: 2)]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #(nil 'David' nil 'Smythe')).
	self assert: ((results at: 2) = #(nil 'Jim' nil 'Brown')).
	self assert: ((results at: 3) = #('jTest' 'John' 'David' 'Smith')).
	self assert: ((results at: 4) = #(nil 'Zoe' 'John' 'Brown'))."
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> testCollectQueryWithInlineFunction [

	| instances john results |

	instances := SimplePerson storedInstancesIn: reStore.

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	"Test various combinations and orderings"
	results := ((instances collect: [ :each | each firstName || each surname || each fullName]) asSortedCollection: [ :a :b | a first <= b first]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #('David' 'Smythe' 'David Smythe')).
	self assert: ((results at: 2) = #('Jim' 'Brown' 'Jim Brown')).
	self assert: ((results at: 3) = #('John' 'Smith' 'John Smith')).
	self assert: ((results at: 4) = #('Zoe' 'Brown' 'Zoe Brown')).
"
	results := ((instances collect: [ :each | each friend firstName || each friend surname || each firstName || each surname]) asSortedCollection: [ :a :b | (a at: 3) <= (b at: 3)]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #(nil nil 'David' 'Smythe')).
	self assert: ((results at: 2) = #(nil nil 'Jim' 'Brown')).
	self assert: ((results at: 3) = #('David' 'Smythe' 'John' 'Smith')).
	self assert: ((results at: 4) = #('John' 'Smith' 'Zoe' 'Brown')).

	results := ((instances collect: [ :each | each firstName || each friend surname || each friend firstName || each surname]) asSortedCollection: [ :a :b | a first <= b first]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #('David' nil nil 'Smythe')).
	self assert: ((results at: 2) = #('Jim' nil nil 'Brown')).
	self assert: ((results at: 3) = #('John' 'Smythe' 'David' 'Smith')).
	self assert: ((results at: 4) = #('Zoe' 'Smith' 'John' 'Brown')).
	
	results := ((instances collect: [ :each | each friend firstName || each surname || each firstName || each friend surname]) asSortedCollection: [ :a :b | (a at: 3) <= (b at: 3)]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #(nil 'Smythe' 'David' nil)).
	self assert: ((results at: 2) = #(nil 'Brown' 'Jim' nil)).
	self assert: ((results at: 3) = #('David' 'Smith' 'John' 'Smythe')).
	self assert: ((results at: 4) = #('John' 'Brown' 'Zoe' 'Smith')).

	results := ((instances collect: [ :each | each firstName || each friend firstName|| each test name || each surname]) asSortedCollection: [ :a :b | a first <= b first]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #('David' nil nil 'Smythe')).
	self assert: ((results at: 2) = #('Jim' nil nil 'Brown')).
	self assert: ((results at: 3) = #('John' 'David' 'jTest' 'Smith')).
	self assert: ((results at: 4) = #('Zoe' 'John' nil 'Brown')).

	results := ((instances collect: [ :each | each test name || each firstName|| each friend firstName || each surname]) asSortedCollection: [ :a :b | (a at: 2) <= (b at: 2)]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #(nil 'David' nil 'Smythe')).
	self assert: ((results at: 2) = #(nil 'Jim' nil 'Brown')).
	self assert: ((results at: 3) = #('jTest' 'John' 'David' 'Smith')).
	self assert: ((results at: 4) = #(nil 'Zoe' 'John' 'Brown'))."
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> testCollectQueryWithMultipleObjects [

	| instances john results |

	instances := SimplePerson storedInstancesIn: reStore.

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	"Test various combinations and orderings"
	results := ((instances collect: [ :each | each firstName || each friend firstName|| each test name || each surname]) asSortedCollection: [ :a :b | a first <= b first]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #('David' nil nil 'Smythe')).
	self assert: ((results at: 2) = #('Jim' nil nil 'Brown')).
	self assert: ((results at: 3) = #('John' 'David' 'jTest' 'Smith')).
	self assert: ((results at: 4) = #('Zoe' 'John' nil 'Brown')).

	results := ((instances collect: [ :each | each test name || each firstName|| each friend firstName || each surname]) asSortedCollection: [ :a :b | (a at: 2) <= (b at: 2)]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #(nil 'David' nil 'Smythe')).
	self assert: ((results at: 2) = #(nil 'Jim' nil 'Brown')).
	self assert: ((results at: 3) = #('jTest' 'John' 'David' 'Smith')).
	self assert: ((results at: 4) = #(nil 'Zoe' 'John' 'Brown')).
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> testCollectQueryWithMultipleObjectsFunction [

	| instances john results |

	instances := SimplePerson storedInstancesIn: reStore.

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	results := ((instances collect: [ :each | each firstName || each friend firstName|| each test name || (each firstName, ' ', each surname)]) asSortedCollection: [ :a :b | a first <= b first]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #('David' nil nil 'David Smythe')).
	self assert: ((results at: 2) = #('Jim' nil nil 'Jim Brown')).
	self assert: ((results at: 3) = #('John' 'David' 'jTest' 'John Smith')).
	self assert: ((results at: 4) = #('Zoe' 'John' nil 'Zoe Brown'))
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> testCollectQueryWithMultipleObjectsInlineFunction [

	| instances john results |

	instances := SimplePerson storedInstancesIn: reStore.

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	results := ((instances collect: [ :each | each firstName || each friend firstName|| each test name || each fullName]) asSortedCollection: [ :a :b | a first <= b first]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #('David' nil nil 'David Smythe')).
	self assert: ((results at: 2) = #('Jim' nil nil 'Jim Brown')).
	self assert: ((results at: 3) = #('John' 'David' 'jTest' 'John Smith')).
	self assert: ((results at: 4) = #('Zoe' 'John' nil 'Zoe Brown'))
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> testCollectQueryWithRelatedObject [

	| instances john dave testBlock testCount |

	instances := SimplePerson storedInstancesIn: reStore.

	john := instances detect: [ :each | each firstName = 'John'].
	dave := instances detect: [ :each | each firstName = 'David'].

	testCount := 0.
	testBlock := 
		[ :results :position || dict |
		dict := self convertToDictionary: results index: position.
		self assert: (dict size = 2).
		self assert: ((dict at: dave) = #('John' 'Smith' 'David' 'Smythe')).
		self assert: ((dict at: john) = #('Zoe' 'Brown' 'John' 'Smith')).
		testCount := testCount + 1].

	"Test with the related object at different positions in the query block"
	testBlock value: (instances collect: [ :each | each friend || each firstName || each surname || each friend firstName || each friend surname]) value: 1.
	testBlock value: (instances collect: [ :each | each firstName || each friend || each surname || each friend firstName || each friend surname]) value: 2.
	testBlock value: (instances collect: [ :each | each firstName || each surname || each friend || each friend firstName || each friend surname]) value: 3.
	testBlock value: (instances collect: [ :each | each firstName || each surname || each friend firstName || each friend || each friend surname]) value: 4.
	testBlock value: (instances collect: [ :each | each firstName || each surname || each friend firstName || each friend surname || each friend]) value: 5.

	"Ensure we actually did some testing"
	self assert: (testCount = 5)
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> testCollectQueryWithRelatedObjectFunction [

	| instances john results |

	instances := SimplePerson storedInstancesIn: reStore.

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	"Test various combinations and orderings"
	results := ((instances collect: [ :each | each firstName || each surname || (each friend firstName, ' ', each friend surname)]) asSortedCollection: [ :a :b | a first <= b first]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #('David' 'Smythe' nil)).
	self assert: ((results at: 2) = #('Jim' 'Brown' nil)).
	self assert: ((results at: 3) = #('John' 'Smith' 'David Smythe')).
	self assert: ((results at: 4) = #('Zoe' 'Brown' 'John Smith')).

	results := ((instances collect: [ :each | each friend firstName || each friend surname || (each firstName, ' ', each surname)]) asSortedCollection: [ :a :b | (a at: 3) <= (b at: 3)]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #(nil nil 'David Smythe')).
	self assert: ((results at: 2) = #(nil nil 'Jim Brown')).
	self assert: ((results at: 3) = #('David' 'Smythe' 'John Smith')).
	self assert: ((results at: 4) = #('John' 'Smith' 'Zoe Brown')).

	results := ((instances collect: [ :each | each firstName || each friend surname || (each firstName, ' ', each surname)]) asSortedCollection: [ :a :b | a first <= b first]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #('David' nil 'David Smythe')).
	self assert: ((results at: 2) = #('Jim' nil 'Jim Brown')).
	self assert: ((results at: 3) = #('John' 'Smythe' 'John Smith')).
	self assert: ((results at: 4) = #('Zoe' 'Smith' 'Zoe Brown')).

	results := ((instances collect: [ :each | each friend firstName || each surname || (each friend firstName, ' ', each friend surname) || each firstName]) asSortedCollection: [ :a :b | (a at: 4) <= (b at: 4)]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #(nil 'Smythe' nil 'David')).
	self assert: ((results at: 2) = #(nil 'Brown' nil 'Jim')).
	self assert: ((results at: 3) = #('David' 'Smith' 'David Smythe' 'John')).
	self assert: ((results at: 4) = #('John' 'Brown' 'John Smith' 'Zoe'))
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> testCollectQueryWithRelatedObjectInlineFunction [

	| instances john results |

	instances := SimplePerson storedInstancesIn: reStore.

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	"Test various combinations and orderings"
	results := ((instances collect: [ :each | each firstName || each surname || each friend fullName]) asSortedCollection: [ :a :b | a first <= b first]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #('David' 'Smythe' nil)).
	self assert: ((results at: 2) = #('Jim' 'Brown' nil)).
	self assert: ((results at: 3) = #('John' 'Smith' 'David Smythe')).
	self assert: ((results at: 4) = #('Zoe' 'Brown' 'John Smith')).

	results := ((instances collect: [ :each | each friend firstName || each friend surname || each fullName]) asSortedCollection: [ :a :b | (a at: 3) <= (b at: 3)]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #(nil nil 'David Smythe')).
	self assert: ((results at: 2) = #(nil nil 'Jim Brown')).
	self assert: ((results at: 3) = #('David' 'Smythe' 'John Smith')).
	self assert: ((results at: 4) = #('John' 'Smith' 'Zoe Brown')).

	results := ((instances collect: [ :each | each firstName || each friend surname || each fullName]) asSortedCollection: [ :a :b | a first <= b first]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #('David' nil 'David Smythe')).
	self assert: ((results at: 2) = #('Jim' nil 'Jim Brown')).
	self assert: ((results at: 3) = #('John' 'Smythe' 'John Smith')).
	self assert: ((results at: 4) = #('Zoe' 'Smith' 'Zoe Brown')).

	results := ((instances collect: [ :each | each friend firstName || each surname || each friend fullName || each firstName]) asSortedCollection: [ :a :b | (a at: 4) <= (b at: 4)]) asArray.
	self assert: (results size = 4).
	self assert: ((results at: 1) = #(nil 'Smythe' nil 'David')).
	self assert: ((results at: 2) = #(nil 'Brown' nil 'Jim')).
	self assert: ((results at: 3) = #('David' 'Smith' 'David Smythe' 'John')).
	self assert: ((results at: 4) = #('John' 'Brown' 'John Smith' 'Zoe'))
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> testConcatenateQueryWithJoins [

	| instances john results |

	instances := SimplePerson storedInstancesIn: reStore.

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	"Test various combinations and orderings which previously gave problems"
	results := instances collect: [ :each | each firstName, each surname, each friend firstName, each friend surname].
	self assert: ((results reject: [ :each | each isNil]) asSortedCollection asArray = #('JohnSmithDavidSmythe'  'ZoeBrownJohnSmith')).

	results := instances collect: [ :each | each friend firstName, each surname, each firstName, each friend surname].
	self assert: ((results reject: [ :each | each isNil]) asSortedCollection asArray = #('DavidSmithJohnSmythe'  'JohnBrownZoeSmith')).

	results := instances collect: [ :each | each friend firstName, each friend surname, each firstName, each surname].
	self assert: ((results reject: [ :each | each isNil]) asSortedCollection asArray = #('DavidSmytheJohnSmith'  'JohnSmithZoeBrown')).

	results := instances collect: [ :each | each firstName, each surname, each test name].
	self assert: ((results reject: [ :each | each isNil]) asArray = #('JohnSmithjTest')).

	results := instances collect: [ :each | each firstName, each test name, each surname].
	self assert: ((results reject: [ :each | each isNil]) asArray = #('JohnjTestSmith')).

	results := instances collect: [ :each | each firstName, each friend firstName, each test name, each friend surname, each surname].
	self assert: ((results reject: [ :each | each isNil]) asArray = #('JohnDavidjTestSmytheSmith'))
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> testIncludesInQueryBlockEmptyCriteria [

	| instances |

	instances := SimplePerson storedInstancesIn: reStore.

	{Array. OrderedCollection. Set} do:
		[ :collectionClass || criteria matches |
		criteria := collectionClass new.

		self shouldnt: [matches := instances select: [ :each | criteria includes: each firstName]] raise: Error.
		self assert: matches isEmpty.

		self shouldnt: [matches := instances select: [ :each | each firstName = 'John' and: [criteria includes: each firstName]]] raise: Error.
		self assert: matches isEmpty.

		self shouldnt: [matches := instances reject: [ :each | criteria includes: each firstName]] raise: Error.
		self assert: matches size = instances size.

		self shouldnt: [matches := instances reject: [ :each | each firstName = 'John' and: [criteria includes: each firstName]]] raise: Error.
		self assert: matches size = instances size]
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> testIncludesInQueryBlockPersistentObject [

	| instances john david |

	instances := SimplePerson storedInstancesIn: reStore.

	john := instances detect: [ :each | each firstName = 'John'].
	david := instances detect: [ :each | each firstName = 'David'].

	"Test common collection classes (previously only Array worked"
	{Array. Set. OrderedCollection} do: 
		[ :collectionClass || criteria matches |
		criteria := collectionClass with: john with: david.

		matches := instances select: [ :each | criteria includes: each friend].

		self assert: (matches size = 2).
		self assert: ((matches collect: [ :e | e fullName]) asSortedCollection asArray = #('John Smith' 'Zoe Brown'))]
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> testIncludesInQueryBlockSimple [

	| instances |

	instances := SimplePerson storedInstancesIn: reStore.

	"Test common collection classes (previously only Array worked"
	{Array. Set. OrderedCollection} do: 
		[ :collectionClass || criteria matches |
		criteria := collectionClass withAll: #('Zoe' 'John').

		matches := instances select: [ :each | criteria includes: each firstName].

		self assert: (matches size = 2).
		self assert: ((matches collect: [ :e | e fullName]) asSortedCollection asArray = #('John Smith' 'Zoe Brown'))]
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> testInstancesCollectionIncludes [

	| instances zoe |

	instances := SimplePerson storedInstancesIn: reStore.
	zoe := instances detect: [ :each | each firstName = 'Zoe'].

	self assert: (instances includes: zoe).
	self assert: ((instances satisfying: [ :each | each surname = 'Brown']) includes: zoe).
	self deny: ((instances satisfying: [ :each | each surname = 'Smith']) includes: zoe).
	self deny: (instances includes: SimplePerson new)
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> testQueryEvaluationLocationDatabase [

	"Test database side of imageDo:databaseDo:"

	| instances names|

	instances := SimplePerson storedInstancesIn: reStore.

	names := instances collect: [ :each | each firstName || each surname || each fullNameWithEvaluationLocation].

	names do: 
		[ :array |
		self assert: array last equals: ('<1s> <2s> (DATABASE)' expandMacrosWith: array first with: array second)].
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> testQueryEvaluationLocationImage [

	"Test image side of imageDo:databaseDo:"

	| instances names|

	instances := SimplePerson storedInstancesIn: reStore.

	names := instances asOrderedCollection collect: [ :each | each firstName || each surname || each fullNameWithEvaluationLocation].

	names do: 
		[ :array |
		self assert: array last equals: ('<1s> <2s> (IMAGE)' expandMacrosWith: array first with: array second)].
]

{ #category : #'unit tests' }
SSWReStoreQueryTest >> testReverse [

	| forward reverse |

	forward := SimplePerson storedInstancesIn: reStore.
	reverse := forward reverse.

	"Ensure reverse hasn't modified the original collection (previous error)"
	self assert: forward isSorted not.

	"Without any explicit ordering on forward we can't guarantee the ordering of reverse will be different, so just check membership"
	self assert: (forward asSet = reverse asSet).

	forward beOrdered.
	reverse := forward reverse.
	self assert: (forward asOrderedCollection asArray reverse = reverse asOrderedCollection asArray).

	forward sortBlock: SortedCollection.
	reverse := forward reverse.
	self assert: (forward asOrderedCollection asArray reverse = reverse asOrderedCollection asArray)
]
