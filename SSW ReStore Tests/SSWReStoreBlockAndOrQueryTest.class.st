"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreBlockAndOrQueryTest,
	#superclass : #SSWReStoreQueryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreBlockAndOrQueryTest class >> shouldInheritSelectors [

	^false
]

{ #category : #'unit tests' }
SSWReStoreBlockAndOrQueryTest >> testBlockAnd [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results :=  instances select: [ :each | each firstName = 'Zoe' and: [each surname = 'Brown']].
	self assert: results size = 1.
	self assert: (results first fullName = 'Zoe Brown').

	results :=  instances select: [ :each | each firstName = 'John' and: [each surname = 'Smith' and: [each age = 20]]].
	self assert: results size = 1.
	self assert: (results first fullName = 'John Smith')


]

{ #category : #'unit tests' }
SSWReStoreBlockAndOrQueryTest >> testBlockAndNonBlockOrBlockAndCombination [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results :=  instances select: [ :each | (each firstName = 'John' and: [each age = 20]) | (each surname = 'Brown' and: [each age = 30])].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('Jim' 'John')).

	results :=  instances select: [ :each | (each firstName = 'John' and: [each age = 20]) | (each firstName = 'David' and: [each age = 30])].
	self assert: results size = 1.
	self assert: results first fullName = 'John Smith'.

	"Bigger tests"
	results :=  instances select: [ :each | (each firstName = 'John' and: [each surname = 'Smith' and: [each age = 20]]) | (each firstName = 'David' and: [each surname = 'Smythe' and: [each age = 40]])].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('David' 'John')).

	results :=  instances select: [ :each | (each firstName = 'John' and: [each surname = 'Smith' and: [each age = 20]]) | (each firstName = 'David' and: [(each surname = 'Smythe') & (each age = 40)])].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('David' 'John')).

	results :=  instances select: [ :each | (each firstName = 'John' and: [each surname = 'Smith' and: [each age = 20]]) | ((each firstName = 'David') & ((each surname = 'Smythe') and: [each age = 40]))].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('David' 'John')).

	results :=  instances select: [ :each | (each firstName = 'John' and: [(each surname = 'Smith') & (each age = 20)]) | ((each firstName = 'David') & ((each surname = 'Smythe') and: [each age = 40]))].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('David' 'John')).

	results :=  instances select: [ :each | (each firstName = 'John' & ((each surname = 'Smith') and: [each age = 20])) | ((each firstName = 'David') & ((each surname = 'Smythe') and: [each age = 40]))].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('David' 'John')).

	results :=  instances select: [ :each | (each firstName = 'John' & ((each surname = 'Smith') and: [each age = 20])) |  (each firstName = 'David' and: [(each surname = 'Smythe') & (each age = 40)])].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('David' 'John')).


	results :=  instances select: [ :each | (each firstName = 'Jon' and: [each surname = 'Smith' and: [each age = 20]]) | (each firstName = 'David' and: [each surname = 'Smythe' and: [each age = 40]])].
	self assert: results size = 1.
	self assert: results first fullName = 'David Smythe'.

	results :=  instances select: [ :each | (each firstName = 'John' and: [each surname = 'Smithe' and: [each age = 20]]) | (each firstName = 'David' and: [each surname = 'Smythe' and: [each age = 40]])].
	self assert: results size = 1.
	self assert: results first fullName = 'David Smythe'.

	results :=  instances select: [ :each | (each firstName = 'John' and: [each surname = 'Smith' and: [each age = 21]]) | (each firstName = 'David' and: [each surname = 'Smythe' and: [each age = 40]])].
	self assert: results size = 1.
	self assert: results first fullName = 'David Smythe'
]

{ #category : #'unit tests' }
SSWReStoreBlockAndOrQueryTest >> testBlockAndNonBlockOrCombination [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	"Test different orders with different results"
	results :=  instances select: [ :each | (each firstName = 'John' and: [each age = 20]) | (each firstName = 'David')].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('David' 'John')).

	results :=  instances select: [ :each | ((each firstName = 'John') & (each age = 20)) or: [each firstName = 'David']].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('David' 'John')).


	results :=  instances select: [ :each | each age = 20 and: [(each firstName = 'John') | (each firstName = 'David')]].
	self assert: results size = 1.
	self assert: results first firstName = 'John'.

	results :=  instances select: [ :each | (each age = 20) & ((each firstName = 'John') or: [each firstName = 'David'])].
	self assert: results size = 1.
	self assert: results first firstName = 'John'.


	results :=  instances select: [ :each | each age = 20 and: [(each firstName = 'John') | (each firstName = 'Zoe')]].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('John' 'Zoe')).

	results :=  instances select: [ :each | each age = 20 & ((each firstName = 'John') or: [each firstName = 'Zoe'])].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('John' 'Zoe'))
]

{ #category : #'unit tests' }
SSWReStoreBlockAndOrQueryTest >> testBlockAndOrAndCombination [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results :=  instances select: [ :each | (each firstName = 'John' and: [each age = 20]) or: [each firstName = 'David' and: [each age = 40]]].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('David' 'John')).

	results :=  instances select: [ :each | (each firstName = 'John' and: [each age = 20]) or: [each firstName = 'David' and: [each age = 30]]].
	self assert: results size = 1.
	self assert: results first fullName = 'John Smith'.

	"Bigger tests"
	results :=  instances select: [ :each | (each firstName = 'John' and: [each surname = 'Smith' and: [each age = 20]]) or: [each firstName = 'David' and: [each surname = 'Smythe' and: [each age = 40]]]].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('David' 'John')).

	results :=  instances select: [ :each | (each firstName = 'Jon' and: [each surname = 'Smith' and: [each age = 20]]) or: [each firstName = 'David' and: [each surname = 'Smythe' and: [each age = 40]]]].
	self assert: results size = 1.
	self assert: results first fullName = 'David Smythe'.

	results :=  instances select: [ :each | (each firstName = 'John' and: [each surname = 'Smithe' and: [each age = 20]]) or: [each firstName = 'David' and: [each surname = 'Smythe' and: [each age = 40]]]].
	self assert: results size = 1.
	self assert: results first fullName = 'David Smythe'.

	results :=  instances select: [ :each | (each firstName = 'John' and: [each surname = 'Smith' and: [each age = 21]]) or: [each firstName = 'David' and: [each surname = 'Smythe' and: [each age = 40]]]].
	self assert: results size = 1.
	self assert: results first fullName = 'David Smythe'
]

{ #category : #'unit tests' }
SSWReStoreBlockAndOrQueryTest >> testBlockAndOrCombination [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	"Test different orders with different results"
	results :=  instances select: [ :each | (each firstName = 'John' and: [each age = 20]) or: [each firstName = 'David']].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('David' 'John')).

	results :=  instances select: [ :each | each age = 20 and: [each firstName = 'John' or: [each firstName = 'David']]].
	self assert: results size = 1.
	self assert: results first firstName = 'John'.

	results :=  instances select: [ :each | each age = 20 and: [each firstName = 'John' or: [each firstName = 'Zoe']]].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('John' 'Zoe'))
]

{ #category : #'unit tests' }
SSWReStoreBlockAndOrQueryTest >> testBlockOr [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results :=  instances select: [ :each | each firstName = 'Zoe' or: [each firstName = 'John']].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('John' 'Zoe')).

	results :=  instances select: [ :each | each firstName = 'Zoe' or: [each firstName = 'John' or: [each firstName = 'Jim']]].
	self assert: results size = 3.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('Jim' 'John' 'Zoe'))
]

{ #category : #'unit tests' }
SSWReStoreBlockAndOrQueryTest >> testBlockOrAndCombination [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	"Test different bracketing orders with different results"
	results :=  instances select: [ :each | each firstName = 'David' or: [each firstName = 'John' and: [each age = 20]]].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('David' 'John')).

	results :=  instances select: [ :each | (each firstName = 'David' or: [each firstName = 'John']) and: [each age = 20]].
	self assert: results size = 1.
	self assert: results first firstName = 'John'.

	results :=  instances select: [ :each | (each firstName = 'David' or: [each firstName = 'John' or: [each firstName = 'Zoe']]) and: [each age = 20]].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('John' 'Zoe')).

]

{ #category : #'unit tests' }
SSWReStoreBlockAndOrQueryTest >> testBlockOrAndOrCombination [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results :=  instances select: [ :each | (each firstName = 'John' or: [each firstName = 'David']) and: [each age = 40 or: [each age = 20]]].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('David' 'John')).

	results :=  instances select: [ :each | (each firstName = 'John' or: [each firstName = 'David']) and: [each age = 40 or: [each age = 30]]].
	self assert: results size = 1.
	self assert: results first fullName = 'David Smythe'.

	"Bigger test"
	results :=  instances select: [ :each | (each firstName = 'Jim' or: [each firstName = 'John' or: [each firstName = 'David']]) and: [each age = 40 or: [each age = 30 or: [each age = 20]]]].
	self assert: results size = 3.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('David' 'Jim' 'John')).
]

{ #category : #'unit tests' }
SSWReStoreBlockAndOrQueryTest >> testBlockOrNonBlockAndCombination [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	"Test different bracketing orders with different results"
	results :=  instances select: [ :each | each firstName = 'David' or: [(each firstName = 'John') & (each age = 20)]].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('David' 'John')).
	results :=  instances select: [ :each | (each firstName = 'David') | (each firstName = 'John' and: [each age = 20])].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('David' 'John')).


	results :=  instances select: [ :each | (each firstName = 'David' or: [each firstName = 'John']) & (each age = 20)].
	self assert: results size = 1.
	self assert: results first firstName = 'John'.
	results :=  instances select: [ :each | ((each firstName = 'David') | (each firstName = 'John')) and: [each age = 20]].
	self assert: results size = 1.
	self assert: results first firstName = 'John'.


	results :=  instances select: [ :each | (each firstName = 'David' or: [each firstName = 'John' or: [each firstName = 'Zoe']]) & (each age = 20)].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('John' 'Zoe')).
	results :=  instances select: [ :each | ((each firstName = 'David') | (each firstName = 'John') | (each firstName = 'Zoe')) and: [each age = 20]].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('John' 'Zoe')).

]

{ #category : #'unit tests' }
SSWReStoreBlockAndOrQueryTest >> testMixBlockNonBlockAndOrCombinations [

	| instances results |

	instances := SimplePerson storedInstancesIn: reStore.

	results :=  instances select: [ :each | (each firstName = 'John' and: [each age = 20]) | ((each surname = 'Brown') & (each age = 30))].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('Jim' 'John')).

	results :=  instances select: [ :each | ((each firstName = 'John') & (each age = 20)) | (each firstName = 'David' and: [each age = 30])].
	self assert: results size = 1.
	self assert: results first fullName = 'John Smith'.

	"Bigger tests"
	results :=  instances select: [ :each | (each firstName = 'John' and: [(each surname = 'Smith') & (each age = 20)]) | (each firstName = 'David' and: [each surname = 'Smythe' and: [each age = 40]])].
	self assert: results size = 2.
	self assert: ((results collect: [ :each | each firstName]) asSortedCollection asArray = #('David' 'John')).

	results :=  instances select: [ :each | (each firstName = 'Jon' and: [each surname = 'Smith' and: [each age = 20]]) | (each firstName = 'David' & (each surname = 'Smythe' and: [each age = 40]))].
	self assert: results size = 1.
	self assert: results first fullName = 'David Smythe'.

	results :=  instances select: [ :each | (each firstName = 'John' and: [each surname = 'Smithe' and: [each age = 20]]) | ((each firstName = 'David') & (each surname = 'Smythe') & (each age = 40))].
	self assert: results size = 1.
	self assert: results first fullName = 'David Smythe'.

	results :=  instances select: [ :each | (each firstName = 'John' and: [each surname = 'Smithe' and: [each age = 20]]) or: [(each firstName = 'David') & (each surname = 'Smythe') & (each age = 40)]].
	self assert: results size = 1.
	self assert: results first fullName = 'David Smythe'.

	results :=  instances select: [ :each | ((each firstName = 'John') & (each surname = 'Smith') & (each age = 21)) | (each firstName = 'David' and: [each surname = 'Smythe' and: [each age = 40]])].
	self assert: results size = 1.
	self assert: results first fullName = 'David Smythe'.

	results :=  instances select: [ :each | ((each firstName = 'John') & (each surname = 'Smith') & (each age = 21)) or: [each firstName = 'David' and: [each surname = 'Smythe' and: [each age = 40]]]].
	self assert: results size = 1.
	self assert: results first fullName = 'David Smythe'.

	results :=  instances select: [ :each | ((each firstName = 'John') & (each surname = 'Smith') & (each age = 21)) or: [(each firstName = 'David') & (each surname = 'Smythe') & (each age = 40)]].
	self assert: results size = 1.
	self assert: results first fullName = 'David Smythe'
]
