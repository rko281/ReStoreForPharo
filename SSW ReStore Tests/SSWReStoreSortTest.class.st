"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWReStoreSortTest',
	#superclass : 'SSWReStoreAbstractQueryTest',
	#instVars : [
		'simplePersonCompareMethod'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'inverse' }
SSWReStoreSortTest >> _testClassSortImplementationInverted [

	| instances |

	self addMethod: SimplePerson>>#<=> withSelector: #<= fromClass: SimplePerson.
	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection.

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' ))
]

{ #category : 'inverse' }
SSWReStoreSortTest >> _testClassSortImplementationWithBlocksInverted [

	| instances |

	self addMethod: SimplePerson>>#<==> withSelector: #<= toClass: SimplePerson.
	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection.

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' ))
]

{ #category : 'inverse' }
SSWReStoreSortTest >> _testSortInverted [

	| instances |

	self changeDavidToJohn.

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection: [ :a :b | (b firstName > a firstName) | (b firstName = a firstName & (b surname >= a surname))].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'John Smith' 'John Smythe' 'Zoe Brown'))
]

{ #category : 'inverse' }
SSWReStoreSortTest >> _testSortWithBlocksInverted [

	| instances |

	self changeDavidToJohn.

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection: [ :a :b | b firstName > a firstName or: [b firstName = a firstName and: [b surname >= a surname]]].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'John Smith' 'John Smythe' 'Zoe Brown'))
]

{ #category : 'running' }
SSWReStoreSortTest >> changeDavidToJohn [

	| davidToJohn |

	davidToJohn := (SimplePerson storedInstancesIn: reStore) detect: [ :each | each firstName = 'David'].
	davidToJohn firstName: 'John'.
	davidToJohn store
]

{ #category : 'running' }
SSWReStoreSortTest >> setUp [

	super setUp.

	"Cache this since some tests swap it with another method"
	simplePersonCompareMethod := (SimplePerson>>#<=)
]

{ #category : 'running' }
SSWReStoreSortTest >> tearDown [

	super tearDown.

	self addMethod: simplePersonCompareMethod withSelector: #<= toClass: SimplePerson
]

{ #category : 'unit tests' }
SSWReStoreSortTest >> testClassSortImplementation [

	| instances |

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection.

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' ))
]

{ #category : 'unit tests' }
SSWReStoreSortTest >> testClassSortImplementationOnPersistentObject [

	| instances |

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection.
	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' )).
	instances with: instances reverse do: [ :person :friend | person friend: friend].
	"Jim Brown	David Smythe	Jim Brown
	Zoe Brown		John Smith	Zoe Brown
	John Smith	Zoe Brown		John Smith
	David Smythe	Jim Brown		David Smythe"

	instances storeAll.

	self addMethod: SimplePerson>>#friendCompare: withSelector: #<= toClass: SimplePerson. "a friend <= b friend"

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection.

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('David Smythe' 'John Smith' 'Zoe Brown' 'Jim Brown' ))
]

{ #category : 'unit tests' }
SSWReStoreSortTest >> testClassSortImplementationReversed [

	| instances |

	instances := (SimplePerson storedInstancesIn: reStore) beSorted reverse.

	self assert: (instances collect: [ :each | each fullName]) asArray equals: #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' ) reverse
]

{ #category : 'unit tests' }
SSWReStoreSortTest >> testClassSortImplementationWithBlocks [

	| instances |

	self addMethod: SimplePerson>>#<== withSelector: #<= toClass: SimplePerson.
	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection.

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' ))
]

{ #category : 'unit tests' }
SSWReStoreSortTest >> testClassSortImplementationWithBlocksOnPersistentObject [

	| instances |

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection.
	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' )).
	instances with: instances reverse do: [ :person :friend | person friend: friend].
	instances storeAll.

	self addMethod: SimplePerson>>#friendCompareWithBlocks: withSelector: #<= toClass: SimplePerson.
	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection.

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('David Smythe' 'John Smith' 'Zoe Brown' 'Jim Brown' ))
]

{ #category : 'unit tests' }
SSWReStoreSortTest >> testDeepSort [

	| instances |

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection.
	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' )).
	instances with: instances reverse do: [ :person :friend | person friend: friend].
	instances storeAll.

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection: [ :a :b | (a friend firstName < b friend firstName) | (a friend firstName = b friend firstName & (a friend surname <= b friend surname))].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'David Smythe' 'Zoe Brown' 'John Smith' ))
]

{ #category : 'unit tests' }
SSWReStoreSortTest >> testDeepSortWithBlocks [

	| instances |

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection.
	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' )).
	instances with: instances reverse do: [ :person :friend | person friend: friend].
	instances storeAll.

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection: [ :a :b | a friend firstName < b friend firstName or: [a friend firstName = b friend firstName and: [a friend surname <= b friend surname]]].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'David Smythe' 'Zoe Brown' 'John Smith' ))
]

{ #category : 'unit tests' }
SSWReStoreSortTest >> testSortImplementation [

	| instances |

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection: [ :a :b | a <= b].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' ))
]

{ #category : 'unit tests' }
SSWReStoreSortTest >> testSortImplementationOnPersistentObject [

	| instances |

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection.
	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' )).
	instances with: instances reverse do: [ :person :friend | person friend: friend].
	instances storeAll.

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection: [ :a :b | a friendCompare: b].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('David Smythe' 'John Smith' 'Zoe Brown' 'Jim Brown' ))
]

{ #category : 'unit tests' }
SSWReStoreSortTest >> testSortImplementationOnPersistentObjectWithBlocks [

	| instances |

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection.
	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' )).
	instances with: instances reverse do: [ :person :friend | person friend: friend].
	instances storeAll.

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection: [ :a :b | a friendCompareWithBlocks: b].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('David Smythe' 'John Smith' 'Zoe Brown' 'Jim Brown' ))
]

{ #category : 'unit tests' }
SSWReStoreSortTest >> testSortImplementationReversed [

	| instances |

	instances := (SimplePerson storedInstancesIn: reStore) sortBlock: [ :a :b | a <= b].

	self assert: (instances reverse asOrderedCollection collect: [ :each | each fullName]) asArray equals: #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' ) reverse
]

{ #category : 'unit tests' }
SSWReStoreSortTest >> testSortImplementationWithBlocks [

	| instances |

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection: [ :a :b | a <== b].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' ))
]

{ #category : 'unit tests' }
SSWReStoreSortTest >> testSortImplementationWithPersistentObjectEqualityIdentityCondition [

	"Test a previously-erroring case where a sort block containing an equality test on a persistent class which does not implement a custom equality test 
	(i.e. drops through to the identity test in Object>>#=) gave an error or went unprocessed"

	| instances test1 test2 test3 testEquality |

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection.
	self assert: (instances collect: [ :each | each fullName]) asArray equals: #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' ).
	test1 := Test new name: '1'.
	test2 := Test new name: '2'.
	test3 := Test new name: '3'.
	instances first test: test1.
	instances second test: test2.
	instances third test: test3.
	instances fourth test: test3.
	instances storeAllIn: reStore.

	"Remove the implementation of equality from Test"
	testEquality := Test>>#=.
	self removeSelector: #= fromClass: Test.

	[self 
		shouldnt:
			[instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection: [ :a :b | (a test < b test) | ((a test = b test) & (a firstName <= b firstName))]]
		raise: Error.

	self assert: (instances collect: [ :each | each fullName]) asArray equals: #('Jim Brown' 'Zoe Brown' 'David Smythe' 'John Smith')] ensure: [self addMethod: testEquality withSelector: #= toClass: Test]
]

{ #category : 'unit tests' }
SSWReStoreSortTest >> testSortImplementationWithPersistentObjectEqualityIdentityConditionWithBlocks [

	"Test a previously-erroring case where a sort block containing an equality test on a persistent class which does not implement a custom equality test 
	(i.e. drops through to the identity test in Object>>#=) gave an error or went unprocessed"

	| instances test1 test2 test3 testEquality |

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection.
	self assert: (instances collect: [ :each | each fullName]) asArray equals: #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' ).
	test1 := Test new name: '1'.
	test2 := Test new name: '2'.
	test3 := Test new name: '3'.
	instances first test: test1.
	instances second test: test2.
	instances third test: test3.
	instances fourth test: test3.
	instances storeAllIn: reStore.

	"Remove the implementation of equality from Test"
	testEquality := Test>>#=.
	self removeSelector: #= fromClass: Test.

	[self 
		shouldnt:
			[instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection: [ :a :b | a test < b test or: [a test = b test and: [a firstName <= b firstName]]]]
		raise: Error.

	self assert: (instances collect: [ :each | each fullName]) asArray equals: #('Jim Brown' 'Zoe Brown' 'David Smythe' 'John Smith')] ensure: [self addMethod: testEquality withSelector: #= toClass: Test]
]

{ #category : 'unit tests' }
SSWReStoreSortTest >> testStandardSort [

	| instances |

	self changeDavidToJohn.

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection: [ :a :b | (a firstName < b firstName) | (a firstName = b firstName & (a surname <= b surname))].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'John Smith' 'John Smythe' 'Zoe Brown'))
]

{ #category : 'unit tests' }
SSWReStoreSortTest >> testStandardSortOnPersistentObject [

	| instances |

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection.
	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' )).
	instances with: instances reverse do: [ :person :friend | person friend: friend].
	instances storeAll.

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection: [ :a :b | a friend <= b friend].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('David Smythe' 'John Smith' 'Zoe Brown' 'Jim Brown' ))
]

{ #category : 'unit tests' }
SSWReStoreSortTest >> testStandardSortOnPersistentObjectWithBlocks [

	| instances |

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection.
	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' )).
	instances with: instances reverse do: [ :person :friend | person friend: friend].
	instances storeAll.

	self addMethod: SimplePerson>>#<== withSelector: #<= toClass: SimplePerson.
	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection: [ :a :b | a friend <= b friend].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('David Smythe' 'John Smith' 'Zoe Brown' 'Jim Brown' ))
]

{ #category : 'unit tests' }
SSWReStoreSortTest >> testStandardSortWithBlocks [

	| instances |

	self changeDavidToJohn.

	instances := (SimplePerson storedInstancesIn: reStore) asSortedCollection: [ :a :b | a firstName < b firstName or: [a firstName = b firstName and: [a surname <= b surname]]].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'John Smith' 'John Smythe' 'Zoe Brown'))
]
