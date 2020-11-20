"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreIsNilQueryTest,
	#superclass : #SSWReStoreQueryTest,
	#instVars : [
		'instances'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreIsNilQueryTest class >> defaultCompilationFlags [

	^0
]

{ #category : #public }
SSWReStoreIsNilQueryTest class >> shouldInheritSelectors [

	^false
]

{ #category : #running }
SSWReStoreIsNilQueryTest >> setUp [

	super setUp.

	instances := SimplePerson storedInstancesIn: reStore
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testAndIsNilCondition [

	"Test the combination of a block and: followed by isNil condition (two inlined non-standard message sends)"

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	results := instances select: [ :each | each firstName = 'John' and: [each test isNil]].
	self assert: results isEmpty.

	results := instances select: [ :each | each firstName = 'David' and: [each test isNil]].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'David'
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testAndMethodIsNilCondition [

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	results := instances select: [ :each | each firstName = 'John' and: [each hasNoTest]].
	self assert: results isEmpty.

	results := instances select: [ :each | each firstName = 'David' and: [each hasNoTest]].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'David'
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testIsNilAndCondition [

	"Test the combination of isNil followed by a block and: condition (two inlined non-standard message sends, resulting in a single conditional jump bytecode)"

	| results |

	results := instances select: [ :each | each friend isNil].
	self deny: results isEmpty.

	results := instances select: [ :each | each firstName = 'John'].
	self deny: results isEmpty.

	results := instances select: [ :each | each friend isNil and: [each firstName = 'John']].
	self assert: results isEmpty
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testIsNilAndNonInlinedAndCondition [

	| results |

	results := instances select: [ :each | each friend isNil and: [each firstName = 'David']].
	self assert: results size equals: 1.

	results := instances select: [ :each | (each friend isNil and: [each firstName = 'David']) & (each surname = 'Smith')].
	self assert: results isEmpty
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testIsNilAndNonInlinedOrCondition [

	| results |

	results := instances select: [ :each | each friend isNil and: [each firstName = 'David']].
	self assert: results size equals: 1.

	results := instances select: [ :each | (each friend isNil and: [each firstName = 'David']) | (each surname = 'Brown')].
	self assert: results size equals: 3
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testIsNilDeepFieldCondition [

	"Test the use of isNil on a nested field"

	| john results |

	instances asOrderedCollection do: [ :each | each test: (Test new name: each fullName)]; storeAll.
	
	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: nil).
	john store.

	results := instances select: [ :each | each test name isNil].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'John'.

	results := instances select: [ :each | each test name = each firstName].
	self assert: results isEmpty.

	results := instances select: [ :each | each test name = each fullName].
	self assert: results size equals: 3.
	self assert: (results collect: [ :each | each firstName]) asSortedCollection asArray equals: #('David' 'Jim' 'Zoe').

	results := instances select: [ :each | each test name isNil | (each test name = each fullName)].
	self assert: results size equals: 4.
	self assert: (results collect: [ :each | each firstName]) asSortedCollection asArray equals: #('David' 'Jim' 'John' 'Zoe').

	"Test the block or: for completeness, moving the isNil test to the end as is required"
	results := instances select: [ :each | each test name = each fullName or: [each test name isNil]].
	self assert: results size equals: 4.
	self assert: (results collect: [ :each | each firstName]) asSortedCollection asArray equals: #('David' 'Jim' 'John' 'Zoe')
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testIsNilFieldFirstCondition [

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john 
		surname: nil;
		test: (Test new name: 'jTest').
	john store.

	results := instances select: [ :each | each surname isNil & (each firstName = 'John')].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'John'.

	results := instances select: [ :each | each surname isNil & (each firstName = 'David')].
	self assert: results isEmpty.

	results := instances select: [ :each | each surname isNil | each test isNil].
	self assert: results size equals: 4.
	self assert: (results collect: [ :each | each firstName]) asSortedCollection asArray equals: #('David' 'Jim' 'John' 'Zoe')
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testIsNilFieldLastCondition [

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john 
		surname: nil;
		test: (Test new name: 'jTest').
	john store.

	results := instances select: [ :each | (each firstName = 'John') & each surname isNil].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'John'.

	results := instances select: [ :each | each test notNil & each surname isNil].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'John'.

	results := instances select: [ :each | (each firstName = 'David') & each surname isNil].
	self assert: results isEmpty.

	results := instances select: [ :each | (each firstName = 'David') | each surname isNil].
	self assert: results size equals: 2.
	self assert: (results collect: [ :each | each firstName]) asSortedCollection asArray equals: #('David' 'John')
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testIsNilFieldMidCondition [

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john 
		surname: nil;
		test: (Test new name: 'jTest').
	john store.

	results := instances select: [ :each | (each firstName = 'John') & each surname isNil & each test notNil].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'John'.

	results := instances select: [ :each | (each firstName = 'David') & each surname isNil & each test notNil].
	self assert: results isEmpty.

	results := instances select: [ :each | (each firstName = 'David') | each surname isNil | (each surname = 'Brown')].
	self assert: results size equals: 4
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testIsNilFieldSoleCondition [

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john surname: nil.
	john store.

	results := instances select: [ :each | each surname isNil].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'John'
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testIsNilFirstCondition [

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	results := instances select: [ :each | each test isNil & (each firstName = 'John')].
	self assert: results isEmpty.

	results := instances select: [ :each | each test isNil & (each firstName = 'David')].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'David'.

	results := instances select: [ :each | each test isNil | (each firstName = 'John')].
	self assert: results size equals: 4.
	self assert: (results collect: [ :each | each firstName]) asSortedCollection asArray equals: #('David' 'Jim' 'John' 'Zoe')
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testIsNilLastCondition [

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	self shouldnt: [results := instances select: [ :each | (each firstName = 'John') & each test isNil]] raise: Error.
	self assert: results isEmpty.

	self shouldnt: [results := instances select: [ :each | (each firstName = 'David') & each test isNil]] raise: Error.
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'David'.

	results := instances select: [ :each | (each firstName = 'John') | each test isNil].
	self assert: results size equals: 4.
	self assert: (results collect: [ :each | each firstName]) asSortedCollection asArray equals: #('David' 'Jim' 'John' 'Zoe')


]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testIsNilMidCondition [

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	self shouldnt: [results := instances select: [ :each | (each firstName = 'John') & each test isNil & (each surname = 'Smith')]] raise: Error.
	self assert: results isEmpty.

	self shouldnt: [results := instances select: [ :each | (each firstName = 'David') & each test isNil & (each surname = 'Smith')]] raise: Error.
	self assert: results isEmpty.

	self shouldnt: [results := instances select: [ :each | (each firstName = 'David') & each test isNil & (each surname = 'Smythe')]] raise: Error.
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'David'


]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testIsNilOrCondition [

	"Test the combination of isNil followed by a block or: condition (two inlined non-standard message sends, resulting in a single conditional jump bytecode)"

	| results |

	results := instances select: [ :each | each firstName = 'John'].
	self assert: results size equals: 1.

	results := instances select: [ :each | each hasNoFriend].
	self assert: results size equals: 2.

	results := instances select: [ :each | each friend isNil or: [each firstName = 'John']].
	self assert: results size equals: 3.

	results := instances select: [ :each | each friend isNil or: [each firstName = 'John' or: [each firstName = 'Zoe']]].
	self assert: results size equals: 4
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testIsNilOrNonInlinedAndCondition [

	"Test the combination of isNil followed by a block or: condition followed by a non-block | condition"

	| results |

	results := instances select: [ :each | (each friend isNil or: [each firstName = 'John']) & (each surname = 'Smith')].
	self assert: results size equals: 1.
	self assert: results first fullName equals: 'John Smith'
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testIsNilOrNonInlinedOrCondition [

	"Test the combination of isNil followed by a block or: condition followed by a non-block | condition"

	| results |

	results := instances select: [ :each | (each friend isNil or: [each firstName = 'John']) | (each firstName = 'Zoe')].
	self assert: results size equals: 4
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testIsNilSoleCondition [

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	self shouldnt: [results := instances select: [ :each | each test isNil]] raise: Error.
	self assert: results size equals: (instances size - 1).
	self deny: (results includes: john)
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testMethodIsNilAndCondition [

	"Test the combination of isNil implemented in a method followed by a block and: condition (two inlined non-standard message sends, resulting in a single conditional jump bytecode)"

	| results |

	results := instances select: [ :each | each friend isNil].
	self deny: results isEmpty.

	results := instances select: [ :each | each firstName = 'John'].
	self deny: results isEmpty.

	results := instances select: [ :each | each hasNoFriend and: [each firstName = 'John']].
	self assert: results isEmpty
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testMethodIsNilAndJointCondition [

	"Test the combination of isNil followed by a block and: condition (two inlined non-standard message sends, resulting in a single conditional jump bytecode) implemented in a method"

	| results |

	results := instances select: [ :each | each friend isNil].
	self deny: results isEmpty.

	results := instances select: [ :each | each firstName = 'John'].
	self deny: results isEmpty.

	results := instances select: [ :each | each friendIsNilAndJohn].
	self assert: results isEmpty
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testMethodIsNilCondition [

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	results := instances select: [ :each | each hasNoTest & (each firstName = 'John')].
	self assert: results isEmpty.

	results := instances select: [ :each | each hasNoTest & (each firstName = 'David')].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'David'.

	results := instances select: [ :each | each hasNoTest not & (each firstName = 'John')].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'John'.

	results := instances select: [ :each | each hasNoTest not & (each firstName = 'David')].
	self assert: results isEmpty
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testMethodIsNilOrCondition [

	| results |

	results := instances select: [ :each | each firstName = 'John'].
	self assert: results size equals: 1.

	results := instances select: [ :each | each hasNoFriend].
	self assert: results size equals: 2.

	results := instances select: [ :each | each hasNoFriend or: [each firstName = 'John']].
	self assert: results size equals: 3
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testMethodIsNilOrJointCondition [

	"Test the combination of isNil followed by a block or: condition (two inlined non-standard message sends, resulting in a single conditional jump bytecode) implemented in a method"

	| results |

	results := instances select: [ :each | each firstName = 'John'].
	self assert: results size equals: 1.

	results := instances select: [ :each | each hasNoFriend].
	self assert: results size equals: 2.

	results := instances select: [ :each | each friendIsNilOrJohn].
	self assert: results size equals: 3
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testOrIsNilCondition [

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	results := instances select: [ :each | each firstName = 'John' or: [each test isNil]].
	self assert: results size equals: instances size.

	results := instances select: [ :each | each firstName = 'David' or: [each test isNil]].
	self assert: results size equals: (instances size - 1).
	self deny: (results anySatisfy: [ :each | each firstName = 'John'])
]

{ #category : #'unit tests' }
SSWReStoreIsNilQueryTest >> testOrMethodIsNilCondition [

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	results := instances select: [ :each | each firstName = 'John' or: [each hasNoTest]].
	self assert: results size equals: instances size.

	results := instances select: [ :each | each firstName = 'David' or: [each hasNoTest]].
	self assert: results size equals: (instances size - 1).
	self deny: (results anySatisfy: [ :each | each firstName = 'John'])
]
