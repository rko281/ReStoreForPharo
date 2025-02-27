"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWReStoreBlockIfNilQueryTest',
	#superclass : 'SSWReStoreQueryTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
SSWReStoreBlockIfNilQueryTest class >> shouldInheritSelectors [

	^false
]

{ #category : 'unit tests' }
SSWReStoreBlockIfNilQueryTest >> testCollectPersistentObjectIfNil [

	| results |

	results := (SimplePerson storedInstancesIn: reStore) collect: [ :each | each || (each friend ifNil: [each])].

	self assert: 
		(results allSatisfy: 
			[ :each || person personOrFriend |
			person := each first.
			personOrFriend := each last.
			person friend isNil 
				ifTrue: [personOrFriend == person]
				ifFalse: [personOrFriend == person friend]])
		
]

{ #category : 'unit tests' }
SSWReStoreBlockIfNilQueryTest >> testCollectSimpleObjectIfNil [

	| persons john results |

	persons := SimplePerson storedInstancesIn: reStore.
	john := persons detect: [ :each | each fullName = 'John Smith'].
	self assert: (john age: nil; store).

	results := persons collect: [ :each | each || (each age ifNil: [-1])].

	self assert: (results allSatisfy: [ :each | (each first age isNil and: [each last = -1]) or: [each first age notNil and: [each last = each first age]]])
]

{ #category : 'unit tests' }
SSWReStoreBlockIfNilQueryTest >> testCollectSimpleObjectWithFunctionIfNil [

	| persons results |

	persons := SimplePerson storedInstancesIn: reStore.

	results := persons collect: [ :each | each || (each emailAddress ifNil: [each firstName, '@unknown.com'])].

	self assert: (results allSatisfy: [ :each | (each first emailAddress isNil and: [each last = (each first firstName, '@unknown.com')]) or: [each first emailAddress notNil and: [each last = each first emailAddress]]])
]

{ #category : 'unit tests' }
SSWReStoreBlockIfNilQueryTest >> testSelectPersistentObjectIfNil [

	| persons john results |

	persons := SimplePerson storedInstancesIn: reStore.
	john := persons detect: [ :each | each fullName = 'John Smith'].
	self assert: (john friend: nil; store).

	results := persons select: [ :each | (each friend ifNil: [each]) = john].

	self assert: results size = 2.
	self assert: (results allSatisfy: [ :each | each == john or: [each friend == john]])
]

{ #category : 'unit tests' }
SSWReStoreBlockIfNilQueryTest >> testSelectSimpleObjectIfNil [

	| persons john results |

	persons := SimplePerson storedInstancesIn: reStore.
	john := persons detect: [ :each | each fullName = 'John Smith'].
	self assert: (john age: nil; store).

	results := persons select: [ :each | (each age ifNil: [20]) = 20].

	self assert: results size = 2.
	self assert: (results allSatisfy: [ :each | each = john or: [each age = 20]])
]

{ #category : 'unit tests' }
SSWReStoreBlockIfNilQueryTest >> testSelectSimpleObjectWithFunctionIfNil [

	| persons results |

	persons := SimplePerson storedInstancesIn: reStore.

	results := persons select: [ :each | '*@something' match: (each emailAddress ifNil: [each firstName, '@something'])].

	self assert: results size = 2.
	self assert: (results allSatisfy: [ :each | each emailAddress isNil or: [each emailAddress endsWith: '@something']])
]
