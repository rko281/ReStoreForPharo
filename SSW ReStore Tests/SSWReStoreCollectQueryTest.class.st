"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreCollectQueryTest,
	#superclass : #SSWReStoreQueryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreCollectQueryTest class >> shouldInheritSelectors [

	^false
]

{ #category : #testing }
SSWReStoreCollectQueryTest >> expectedFailures [

	"fail in Pharo due to incomplete handling of un-inlining of and: / or:"
	
	^super expectedFailures, #(#testMethodNotNilWithJoinCollectQuery)
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testComplexMathFunctionCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each firstName || (each age + each firstName size)].

	self assert: (results size = 4).
	results := results asSortedCollection: [ :a :b | a first <= b first].

	self assert: (results first = #('David' 45)).
	self assert: (results second = #('Jim' 33)).
	self assert: (results third = #('John' 24)).
	self assert: (results last = #('Zoe' 23)).
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testFunctionCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each fullName || each fullName size ].

	self assert: (results detect: [ :each | each first = 'John Smith']) last = ('John Smith' size).
	self assert: (results detect: [ :each | each first = 'Zoe Brown']) last = ('Zoe Brown' size).
	self assert: (results detect: [ :each | each first = 'Jim Brown']) last = ('Jim Brown' size).
	self assert: (results detect: [ :each | each first = 'David Smythe']) last = ('David Smythe' size)
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testIsNilFirstCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each friend isNil || each fullName].

	self deny: (results detect: [ :each | each last = 'John Smith']) first.
	self deny: (results detect: [ :each | each last = 'Zoe Brown']) first.

	self assert: (results detect: [ :each | each last = 'Jim Brown']) first.
	self assert: (results detect: [ :each | each last = 'David Smythe']) first
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testIsNilInlinedOrCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | (each friend isNil or: [each firstName = 'John']) || each fullName].

	self assert: (results detect: [ :each | each last = 'John Smith']) first.
	self assert: (results detect: [ :each | each last = 'Jim Brown']) first.
	self assert: (results detect: [ :each | each last = 'David Smythe']) first.

	self deny: (results detect: [ :each | each last = 'Zoe Brown']) first
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testIsNilLastCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each fullName || each friend isNil].

	self deny: (results detect: [ :each | each first = 'John Smith']) last.
	self deny: (results detect: [ :each | each first = 'Zoe Brown']) last.

	self assert: (results detect: [ :each | each first = 'Jim Brown']) last.
	self assert: (results detect: [ :each | each first = 'David Smythe']) last
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testIsNilMultipleCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each friend isNil || each emailAddress isNil || each fullName].

	self deny: (results detect: [ :each | each last = 'John Smith']) first.
	self deny: (results detect: [ :each | each last = 'Zoe Brown']) first.

	self deny: (results detect: [ :each | each last = 'John Smith']) second.
	self assert: (results detect: [ :each | each last = 'Zoe Brown']) second.

	self assert: (results detect: [ :each | each last = 'Jim Brown']) first.
	self assert: (results detect: [ :each | each last = 'David Smythe']) first.

	self deny: (results detect: [ :each | each last = 'Jim Brown']) second.
	self deny: (results detect: [ :each | each last = 'David Smythe']) second
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testIsNilOrCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | (each friend isNil | (each firstName = 'John')) || each fullName].

	self assert: (results detect: [ :each | each last = 'John Smith']) first.
	self assert: (results detect: [ :each | each last = 'Jim Brown']) first.
	self assert: (results detect: [ :each | each last = 'David Smythe']) first.

	self deny: (results detect: [ :each | each last = 'Zoe Brown']) first
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testJoinedFieldCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each firstName || each friend firstName || each surname || each friend surname].

	self assert: (results size = 4).
	results := results asSortedCollection: [ :a :b | a first <= b first].

	self assert: (results first = (Array with: 'David' with: nil with: 'Smythe' with: nil)).
	self assert: (results second = (Array with: 'Jim' with: nil with: 'Brown' with: nil)).

	self assert: (results third first = 'John').
	self assert: (results third second = 'David').
	self assert: (results third third = 'Smith').
	self assert: (results third last = 'Smythe').

	self assert: (results last first = 'Zoe').
	self assert: (results last second = 'John').
	self assert: (results last third = 'Brown').
	self assert: (results last last = 'Smith')
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testJoinedFieldFirstCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each friend firstName || each friend surname || each firstName|| each surname].

	self assert: (results size = 4).
	results := results asSortedCollection: [ :a :b | a third <= b third].

	self assert: (results first = (Array with: nil with: nil with: 'David' with: 'Smythe')).
	self assert: (results second = (Array with: nil with: nil with: 'Jim' with: 'Brown')).

	self assert: (results third first = 'David').
	self assert: (results third second = 'Smythe').
	self assert: (results third third = 'John').
	self assert: (results third last = 'Smith').

	self assert: (results last first = 'John').
	self assert: (results last second = 'Smith').
	self assert: (results last third = 'Zoe').
	self assert: (results last last = 'Brown')
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testJoinedFieldOnlyCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each friend firstName || each friend surname].

	self assert: (results size = 4).

	self assert: (results occurrencesOf: #(nil nil)) = 2.
	self assert: (results anySatisfy: [ :each | each first = 'David' and: [each last = 'Smythe']]).
	self assert: (results anySatisfy: [ :each | each first = 'John' and: [each last = 'Smith']])
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testMathFunctionCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each firstName || (each age + 5)].

	self assert: (results size = 4).
	results := results asSortedCollection: [ :a :b | a first <= b first].

	self assert: (results first = #('David' 45)).
	self assert: (results second = #('Jim' 35)).
	self assert: (results third = #('John' 25)).
	self assert: (results last = #('Zoe' 25)).
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testMethodNotNilWithJoinCollectQuery [

	"Test previously-failing case where a method invoked from the collect block contains notNil in an inlined block"

	| instances john results |

	instances := SimplePerson storedInstancesIn: reStore.
	john := instances detect: [ :each | each firstName = 'John'].
	john test: (Test new name: 'jTest').
	john store.

	results := instances collect: [ :each | each firstName || each hasTestOrFriendHasTestBlock].
	self assert: results size equals: 4.
	self assert: (results asSortedCollection: [ :r1 :r2 | r1 first <= r2 first]) asArray = #(#('David' false) #('Jim' false) #('John' true) #('Zoe' true)).

	results := (instances satisfying: [ :each | each hasTestOrFriendHasTestBlock]) collect: [ :each | each firstName || each hasTestOrFriendHasTestBlock].
	self assert: results size equals: 2.
	self assert: (results asSortedCollection: [ :r1 :r2 | r1 first <= r2 first]) asArray = #(#('John' true) #('Zoe' true))
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testMultipleConditionalFirstCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each friend isNil || (each surname = 'Brown') || each fullName].

	self deny: (results detect: [ :each | each last = 'John Smith']) first.
	self deny: (results detect: [ :each | each last = 'Zoe Brown']) first.

	self assert: (results detect: [ :each | each last = 'Jim Brown']) first.
	self assert: (results detect: [ :each | each last = 'David Smythe']) first.

	self assert: (results detect: [ :each | each last = 'Jim Brown']) second.
	self assert: (results detect: [ :each | each last = 'Zoe Brown']) second.

	self deny: (results detect: [ :each | each last = 'John Smith']) second.
	self deny: (results detect: [ :each | each last = 'David Smythe']) second


]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testMultipleConditionalLastCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each fullName || each friend isNil || (each surname = 'Brown')].

	self deny: (results detect: [ :each | each first = 'John Smith']) second.
	self deny: (results detect: [ :each | each first = 'Zoe Brown']) second.

	self assert: (results detect: [ :each | each first = 'Jim Brown']) second.
	self assert: (results detect: [ :each | each first = 'David Smythe']) second.

	self assert: (results detect: [ :each | each first = 'Jim Brown']) last.
	self assert: (results detect: [ :each | each first = 'Zoe Brown']) last.

	self deny: (results detect: [ :each | each first = 'John Smith']) last.
	self deny: (results detect: [ :each | each first = 'David Smythe']) last


]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testMultipleConditionalOnSameFieldCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each fullName || each friend isNil || each friend friend isNil].

	self deny: (results detect: [ :each | each first = 'John Smith']) second. "John -> David"
	self deny: (results detect: [ :each | each first = 'Zoe Brown']) second. "Zoe -> John"
	self assert: (results detect: [ :each | each first = 'Jim Brown']) second. "Jim -> nil"
	self assert: (results detect: [ :each | each first = 'David Smythe']) second. "David -> nil"

	self deny: (results detect: [ :each | each first = 'Zoe Brown']) last. "Zoe -> John -> David"
	self assert: (results detect: [ :each | each first = 'John Smith']) last. "John -> David -> nil"
	self assert: (results detect: [ :each | each first = 'Jim Brown']) last. "Jim -> nil -> nil"
	self assert: (results detect: [ :each | each first = 'David Smythe']) last "David -> nil -> nil"
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testMultipleFieldCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each firstName || each surname || each age || each fullName].

	self assert: (results size = 4).
	results := results asSortedCollection: [ :a :b | a first <= b first].

	self assert: (results first = #('David' 'Smythe' 40 'David Smythe')).
	self assert: (results second = #('Jim' 'Brown' 30 'Jim Brown')).
	self assert: (results third = #('John' 'Smith' 20 'John Smith')).
	self assert: (results last = #('Zoe' 'Brown' 20 'Zoe Brown')).
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testMultipleInlinedFunctionCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | (each surname = 'Brown' and: [each age = 20]) || each fullName].

	self assert: (results detect: [ :each | each last = 'Zoe Brown']) first = true.
	self assert: (results detect: [ :each | each last = 'John Smith']) first = false.
	self assert: (results detect: [ :each | each last = 'Jim Brown']) first = false.
	self assert: (results detect: [ :each | each last = 'David Smythe']) first = false
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testMultipleInlinedMethodFunctionCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each isBrown20 || each fullName].

	self assert: (results detect: [ :each | each last = 'Zoe Brown']) first = true.
	self assert: (results detect: [ :each | each last = 'John Smith']) first = false.
	self assert: (results detect: [ :each | each last = 'Jim Brown']) first = false.
	self assert: (results detect: [ :each | each last = 'David Smythe']) first = false
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testNotNilFirstCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each friend notNil || each fullName].

	self assert: (results detect: [ :each | each last = 'John Smith']) first.
	self assert: (results detect: [ :each | each last = 'Zoe Brown']) first.

	self deny: (results detect: [ :each | each last = 'Jim Brown']) first.
	self deny: (results detect: [ :each | each last = 'David Smythe']) first
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testNotNilLastCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each fullName || each friend notNil].

	self assert: (results detect: [ :each | each first = 'John Smith']) last.
	self assert: (results detect: [ :each | each first = 'Zoe Brown']) last.

	self deny: (results detect: [ :each | each first = 'Jim Brown']) last.
	self deny: (results detect: [ :each | each first = 'David Smythe']) last
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testObjectFieldCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each firstName || each friend].

	self assert: (results size = 4).
	results := results asSortedCollection: [ :a :b | a first <= b first].

	self assert: (results first = (Array with: 'David' with: nil)).
	self assert: (results second = (Array with: 'Jim' with: nil)).

	self assert: (results third first = 'John').
	self assert: (results third last fullName = 'David Smythe').

	self assert: (results last first = 'Zoe').
	self assert: (results last last fullName = 'John Smith')
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testObjectFieldOnlyCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each friend].

	self assert: (results size = 4).
	self assert: (results occurrencesOf: nil) = 2.
	self assert: (results anySatisfy: [ :each | each notNil and: [each fullName = 'David Smythe']]).
	self assert: (results anySatisfy: [ :each | each notNil and: [each fullName = 'John Smith']])
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testSingleConditionCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each surname = 'Brown'].

	self assert: (results size = 4).
	self assert: ((results select: [ :each | each]) size = 2).
	self assert: ((results reject: [ :each | each]) size = 2)
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testSingleFieldCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each surname].

	self assert: (results size = 4).
	self assert: (results asSortedCollection asArray = #('Brown' 'Brown' 'Smith' 'Smythe'))
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testSingleInlinedFunctionCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each surname = 'Brown' and: [each age = 20]].

	self assert: (results size = 4).
	self assert: (results select: [ :each | each]) size = 1.
	self assert: (results reject: [ :each | each]) size = 3
]

{ #category : #'unit tests' }
SSWReStoreCollectQueryTest >> testThisObjectFieldOnlyCollectQuery [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results := instances collect: [ :each | each].

	self assert: (results size = 4).
	self assert: (((results asSortedCollection: [ :a :b | a fullName < b fullName]) collect: [ :each | each fullName]) asArray = self sortedPersonFullNames)
]
