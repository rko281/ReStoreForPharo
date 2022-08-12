"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreNotNilQueryTest,
	#superclass : #SSWReStoreQueryTest,
	#instVars : [
		'instances'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreNotNilQueryTest class >> shouldInheritSelectors [

	^false
]

{ #category : #running }
SSWReStoreNotNilQueryTest >> setUp [

	super setUp.

	instances := SimplePerson storedInstancesIn: reStore
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testAndNotNilCondition [

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	results := instances select: [ :each | each firstName = 'John' and: [each test notNil]].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'John'.

	results := instances select: [ :each | each firstName = 'David' and: [each test notNil]].
	self assert: results isEmpty
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testMethodNotNilAndCondition [

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	results := instances select: [ :each | each firstName = 'John' and: [each hasTest]].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'John'.

	results := instances select: [ :each | each firstName = 'David' and: [each hasTest]].
	self assert: results isEmpty
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testMethodNotNilAndJointCondition [

	"Test the combination of notNil followed by a block and: condition (two inlined non-standard message sends, resulting in a single conditional jump bytecode) implemented in a method"

	| results |

	results := instances select: [ :each | each friend notNil].
	self deny: results isEmpty.

	results := instances select: [ :each | each firstName = 'Jim'].
	self deny: results isEmpty.

	results := instances select: [ :each | each friendNotNilAndJim].
	self assert: results isEmpty
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testMethodNotNilCondition [

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	results := instances select: [ :each | each hasTest & (each firstName = 'John')].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'John'.

	results := instances select: [ :each | each hasTest & (each firstName = 'David')].
	self assert: results isEmpty.

	results := instances select: [ :each | each hasTest not & (each firstName = 'John')].
	self assert: results isEmpty.

	results := instances select: [ :each | each hasTest not & (each firstName = 'David')].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'David'
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testMethodNotNilOrCondition [

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	results := instances select: [ :each | each firstName = 'John' or: [each hasTest]].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'John'.

	results := instances select: [ :each | each firstName = 'David' or: [each hasTest]].
	self assert: results size equals: 2.
	self assert: (results collect: [ :e | e firstName]) asSortedCollection asArray equals: #('David' 'John')
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testMethodNotNilOrJointCondition [

	"Test the combination of notNil followed by a block or: condition (two inlined non-standard message sends, resulting in a single conditional jump bytecode) implemented in a method"

	| results |

	results := instances select: [ :each | each friend notNil].
	self deny: results isEmpty.

	results := instances select: [ :each | each firstName = 'Jim'].
	self deny: results isEmpty.

	results := instances select: [ :each | each friendNotNilOrJim].
	self assert: results size equals: 3
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testMethodNotNilWithJoin [

	"Test previously-failing case where a method invoked from the query block contains notNil in an inlined block"

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	results := instances select: [ :each | each hasTestOrFriendHasTestBlock].
	self assert: results size equals: 2.
	self assert: (results collect: [ :each | each firstName]) asSortedCollection asArray equals: #('John' 'Zoe').

	results := instances select: [ :each | each firstName = 'David' | each hasTestOrFriendHasTestBlock].
	self assert: results size equals: 3.
	self assert: (results collect: [ :each | each firstName]) asSortedCollection asArray equals: #('David' 'John' 'Zoe').

	results := instances select: [ :each | each hasTestOrFriendHasTestBlock | (each firstName = 'David')].
	self assert: results size equals: 3.
	self assert: (results collect: [ :each | each firstName]) asSortedCollection asArray equals: #('David' 'John' 'Zoe').

	results := instances select: [ :each | (each firstName = 'Jim') | each hasTestOrFriendHasTestBlock | (each firstName = 'David')].
	self assert: results size equals: 4.
	self assert: (results collect: [ :each | each firstName]) asSortedCollection asArray equals: #('David' 'Jim' 'John' 'Zoe').
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testNotNilAndCondition [

	| results |

	results := instances select: [ :each | each friend notNil].
	self deny: results isEmpty.

	results := instances select: [ :each | each firstName = 'David'].
	self deny: results isEmpty.

	results := instances select: [ :each | each friend notNil and: [each firstName = 'David']].
	self assert: results isEmpty
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testNotNilAndNonInlinedAndCondition [

	| results |

	results := instances select: [ :each | (each friend notNil and: [each firstName = 'John']) & (each surname = 'Brown')].
	self assert: results isEmpty
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testNotNilAndNonInlinedOrCondition [

	| results |

	results := instances select: [ :each | (each friend notNil and: [each firstName = 'John']) | (each surname = 'Brown')].
	self assert: results size equals: 3.
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testNotNilDeepFieldCondition [

	"Test the use of notNil on a nested field"

	| john results |

	instances asOrderedCollection do: [ :each | each test: (Test new name: nil)]; storeAll.
	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: john fullName).
	john store.

	results := instances select: [ :each | each test name notNil].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'John'.

	results := instances select: [ :each | each test name = each firstName].
	self assert: results isEmpty.

	results := instances select: [ :each | each test name notNil & (each test name = each firstName)].
	self assert: results isEmpty.

	results := instances select: [ :each | each test name notNil & (each test name = each fullName)].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'John'.

	"Test the block or: for completeness, moving the isNil test to the end as is required"
	results := instances select: [ :each | each test name = each fullName or: [each test name notNil]].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'John'
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testNotNilFieldFirstCondition [

	| john results |

	instances asOrderedCollection do: [ :each | each surname: nil]; storeAll.

	john := instances detect: [ :each | each firstName = 'John'].
	john 
		surname: 'Smith';
		test: (Test new name: 'jTest').
	john store.

	results := instances select: [ :each | each surname notNil & (each firstName = 'John')].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'John'.

	results := instances select: [ :each | each surname notNil & (each firstName = 'David')].
	self assert: results isEmpty.

	results := instances select: [ :each | each surname notNil | each test isNil].
	self assert: results size equals: 4.
	self assert: (results collect: [ :each | each firstName]) asSortedCollection asArray equals: #('David' 'Jim' 'John' 'Zoe')
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testNotNilFieldLastCondition [

	| john results |

	instances asOrderedCollection do: [ :each | each surname: nil]; storeAll.

	john := instances detect: [ :each | each firstName = 'John'].
	john 
		surname: 'Smith';
		test: (Test new name: 'jTest').
	john store.

	results := instances select: [ :each | (each firstName = 'John') & each surname notNil].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'John'.

	results := instances select: [ :each | each test notNil & each surname notNil].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'John'.

	results := instances select: [ :each | (each firstName = 'David') & each surname notNil].
	self assert: results isEmpty.

	results := instances select: [ :each | (each firstName = 'David') | each surname notNil].
	self assert: results size equals: 2.
	self assert: (results collect: [ :each | each firstName]) asSortedCollection asArray equals: #('David' 'John')
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testNotNilFieldMidCondition [

	| john results |

	instances asOrderedCollection do: [ :each | each surname: nil]; storeAll.

	john := instances detect: [ :each | each firstName = 'John'].
	john surname: 'Smith'; test: (Test new name: 'jTest').
	john store.

	results := instances select: [ :each | (each firstName = 'John') & each surname notNil & each test notNil].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'John'.

	results := instances select: [ :each | (each firstName = 'David') & each surname notNil & each test notNil].
	self assert: results isEmpty.

	results := instances select: [ :each | (each firstName = 'David') | each surname notNil | (each firstName = 'Zoe')].
	self assert: results size equals: 3.
	self assert: (results collect: [ :each | each firstName]) asSortedCollection asArray equals: #('David' 'John' 'Zoe')
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testNotNilFieldSoleCondition [

	| john results |

	instances asOrderedCollection do: [ :each | each surname: nil]; storeAll.

	john := instances detect: [ :each | each firstName = 'John'].
	john surname: 'Smith'.
	john store.

	results := instances select: [ :each | each surname notNil].
	self assert: results size equals: 1.
	self assert: results first firstName equals: 'John'
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testNotNilFirstCondition [

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	results := instances select: [ :each | each test notNil & (each firstName = 'John')].
	self assert: results size equals: 1.
	self assert: (results includes: john).

	results := instances select: [ :each | each test notNil & (each firstName = 'David')].
	self assert: results isEmpty.

	results := instances select: [ :each | each test notNil | (each firstName = 'David')].
	self assert: results size equals: 2.
	self assert: (results collect: [ :each | each firstName]) asSortedCollection asArray equals: #('David' 'John')
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testNotNilLastCondition [

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	self shouldnt: [results := instances select: [ :each | (each firstName = 'John') & each test notNil]] raise: Error.
	self assert: results size equals: 1.
	self assert: (results includes: john).

	self shouldnt: [results := instances select: [ :each | (each firstName = 'David') & each test notNil]] raise: Error.
	self assert: results isEmpty.

	results := instances select: [ :each | (each firstName = 'David') | each test notNil].
	self assert: results size equals: 2.
	self assert: (results collect: [ :each | each firstName]) asSortedCollection asArray equals: #('David' 'John')
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testNotNilMidCondition [

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	self shouldnt: [results := instances select: [ :each | (each firstName = 'John') & each test notNil & (each surname = 'Smith')]] raise: Error.
	self assert: results size equals: 1.
	self assert: (results includes: john).

	self shouldnt: [results := instances select: [ :each | (each firstName = 'John') & each test notNil & (each surname = 'Smythe')]] raise: Error.
	self assert: results isEmpty.

	self shouldnt: [results := instances select: [ :each | (each firstName = 'David') & each test notNil & (each surname = 'Smythe')]] raise: Error.
	self assert: results isEmpty
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testNotNilMultipleConditions [

	| jim results |

	jim := instances detect: [ :each | each firstName = 'Jim'].
	jim test: (Test new name: 'test').
	jim store.

	results := instances select: [ :each | (each friend notNil or: [each test notNil]) or: [each firstName = 'John']].
	self assert: results size equals: 3.

	results := instances select: [ :each | (each friend notNil and: [each test notNil]) or: [each firstName = 'John']].
	self assert: results size equals: 1.

	results := instances select: [ :each | (each friend notNil or: [each test notNil]) and: [each firstName = 'John']].
	self assert: results size equals: 1.

	results := instances select: [ :each | (each friend notNil and: [each test notNil]) and: [each firstName = 'John']].
	self assert: results size equals: 0

]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testNotNilOrCondition [

	| results |

	results := instances select: [ :each | each friend notNil].
	self assert: results size equals: 2.

	results := instances select: [ :each | each firstName = 'David'].
	self assert: results size equals: 1.

	results := instances select: [ :each | each friend notNil or: [each firstName = 'David']].
	self assert: results size equals: 3
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testNotNilOrNonInlinedAndCondition [

	| results |

	results := instances select: [ :each | (each friend notNil or: [each firstName = 'David']) & (each firstName = 'Zoe')].
	self assert: results size equals: 1.
	self assert: results first fullName equals: 'Zoe Brown'
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testNotNilOrNonInlinedOrCondition [

	| results |

	results := instances select: [ :each | (each friend notNil or: [each firstName = 'David']) | (each firstName = 'Jim')].
	self assert: results size equals: 4
]

{ #category : #'unit tests' }
SSWReStoreNotNilQueryTest >> testNotNilSoleCondition [

	| john results |

	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	self shouldnt: [results := instances select: [ :each | each test notNil]] raise: Error.
	self assert: results size equals: 1.
	self assert: (results includes: john)
]
