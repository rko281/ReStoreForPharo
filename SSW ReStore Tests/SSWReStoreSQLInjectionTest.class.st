"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreSQLInjectionTest,
	#superclass : #SSWReStoreAbstractQueryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreSQLInjectionTest >> testNumberQueryCriteriaInjection [

	| instances injectedAge matches |

	instances := SimplePerson storedInstancesIn: reStore.

	injectedAge := '999 OR 1 = 1'.

	"Since we should be using parameters this will fail to return any results, or may cause an error depending on the database type.
	With simple SQL concatentation it would pass due to automatic coercion"
	matches := [instances select: [ :each | each age = injectedAge]] on: Error do: [ :exc | exc return: #()].

	self assert: matches isEmpty
]

{ #category : #public }
SSWReStoreSQLInjectionTest >> testStringQueryCriteriaInjection1 [

	| instances injectedName results |

	instances := SimplePerson storedInstancesIn: reStore.

	injectedName := 'Smith'' OR 1=1'.
	results := instances select: [ :each | each surname = injectedName].

	self assert: results isEmpty
]

{ #category : #public }
SSWReStoreSQLInjectionTest >> testStringQueryCriteriaInjection2 [

	| instances injectedName results |

	instances := SimplePerson storedInstancesIn: reStore.

	injectedName := 'John'' OR ''Dave''=''Dave'.
	results := instances select: [ :each | each firstName = injectedName].

	self assert: results isEmpty
]

{ #category : #public }
SSWReStoreSQLInjectionTest >> testStringUpdateInjection [

	| instances injectedName person |

	instances := SimplePerson storedInstancesIn: reStore.
	person := instances detect: [ :each | each firstName = 'John'].

	"Use SQL injection to have the statement affect a different object"
	injectedName := 'Nathanial'' WHERE FIRST_NAME = ''David'.
	person firstName: injectedName; store.

	"If the injection failed, John should no longer exist (is now Nathanial+injection text), and David should still exist"
	self assert: (instances satisfying: [ :each | each firstName = 'John']) isEmpty.
	self assert: (instances satisfying: [ :each | each firstName = injectedName]) size = 1.
	self assert: (instances satisfying: [ :each | each firstName = 'David']) size = 1.
]
