"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreSortTest,
	#superclass : #SSWReStoreAbstractQueryTest,
	#instVars : [
		'simplePersonCompareMethod'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #inverse }
SSWReStoreSortTest >> _testClassSortImplementationInverted [

	| instances |

	SimplePerson methodDictionary at: #<= put: (SimplePerson>>#<=>).
	instances := (reStore instancesOf: SimplePerson) asSortedCollection.

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' ))
]

{ #category : #inverse }
SSWReStoreSortTest >> _testClassSortImplementationWithBlocksInverted [

	| instances |

	SimplePerson methodDictionary at: #<= put: (SimplePerson>>#<==>).
	instances := (reStore instancesOf: SimplePerson) asSortedCollection.

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' ))
]

{ #category : #inverse }
SSWReStoreSortTest >> _testSortInverted [

	| instances |

	self changeDavidToJohn.

	instances := (reStore instancesOf: SimplePerson) asSortedCollection: [ :a :b | (b firstName > a firstName) | (b firstName = a firstName & (b surname >= a surname))].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'John Smith' 'John Smythe' 'Zoe Brown'))
]

{ #category : #inverse }
SSWReStoreSortTest >> _testSortWithBlocksInverted [

	| instances |

	self changeDavidToJohn.

	instances := (reStore instancesOf: SimplePerson) asSortedCollection: [ :a :b | b firstName > a firstName or: [b firstName = a firstName and: [b surname >= a surname]]].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'John Smith' 'John Smythe' 'Zoe Brown'))
]

{ #category : #running }
SSWReStoreSortTest >> changeDavidToJohn [

	| davidToJohn |

	davidToJohn := (reStore instancesOf: SimplePerson) detect: [ :each | each firstName = 'David'].
	davidToJohn firstName: 'John'.
	reStore commit: davidToJohn
]

{ #category : #running }
SSWReStoreSortTest >> setUp [

	super setUp.

	"Cache this since some tests swap it with another method"
	simplePersonCompareMethod := (SimplePerson>>#<=)
]

{ #category : #running }
SSWReStoreSortTest >> tearDown [

	super tearDown.

	SimplePerson methodDictionary at: #<= put: simplePersonCompareMethod
]

{ #category : #'unit tests' }
SSWReStoreSortTest >> testClassSortImplementation [

	| instances |

	instances := (reStore instancesOf: SimplePerson) asSortedCollection.

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' ))
]

{ #category : #'unit tests' }
SSWReStoreSortTest >> testClassSortImplementationOnPersistentObject [

	| instances |

	instances := (reStore instancesOf: SimplePerson) asSortedCollection.
	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' )).
	instances with: instances reverse do: [ :person :friend | person friend: friend].
	"Jim Brown	David Smythe	Jim Brown
	Zoe Brown		John Smith	Zoe Brown
	John Smith	Zoe Brown		John Smith
	David Smythe	Jim Brown		David Smythe"

	reStore commitAll: instances.

	SimplePerson methodDictionary at: #<= put: (SimplePerson>>#friendCompare:). "a friend <= b friend"

	instances := (reStore instancesOf: SimplePerson) asSortedCollection.

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('David Smythe' 'John Smith' 'Zoe Brown' 'Jim Brown' ))
]

{ #category : #'unit tests' }
SSWReStoreSortTest >> testClassSortImplementationWithBlocks [

	| instances |

	SimplePerson methodDictionary at: #<= put: (SimplePerson>>#<==).
	instances := (reStore instancesOf: SimplePerson) asSortedCollection.

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' ))
]

{ #category : #'unit tests' }
SSWReStoreSortTest >> testClassSortImplementationWithBlocksOnPersistentObject [

	| instances |

	instances := (reStore instancesOf: SimplePerson) asSortedCollection.
	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' )).
	instances with: instances reverse do: [ :person :friend | person friend: friend].
	reStore commitAll: instances.

	SimplePerson methodDictionary at: #<= put: (SimplePerson>>#friendCompareWithBlocks:).
	instances := (reStore instancesOf: SimplePerson) asSortedCollection.

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('David Smythe' 'John Smith' 'Zoe Brown' 'Jim Brown' ))
]

{ #category : #'unit tests' }
SSWReStoreSortTest >> testDeepSort [

	| instances |

	instances := (reStore instancesOf: SimplePerson) asSortedCollection.
	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' )).
	instances with: instances reverse do: [ :person :friend | person friend: friend].
	reStore commitAll: instances.

	instances := (reStore instancesOf: SimplePerson) asSortedCollection: [ :a :b | (a friend firstName < b friend firstName) | (a friend firstName = b friend firstName & (a friend surname <= b friend surname))].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'David Smythe' 'Zoe Brown' 'John Smith' ))
]

{ #category : #'unit tests' }
SSWReStoreSortTest >> testDeepSortWithBlocks [

	| instances |

	instances := (reStore instancesOf: SimplePerson) asSortedCollection.
	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' )).
	instances with: instances reverse do: [ :person :friend | person friend: friend].
	reStore commitAll: instances.

	instances := (reStore instancesOf: SimplePerson) asSortedCollection: [ :a :b | a friend firstName < b friend firstName or: [a friend firstName = b friend firstName and: [a friend surname <= b friend surname]]].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'David Smythe' 'Zoe Brown' 'John Smith' ))
]

{ #category : #'unit tests' }
SSWReStoreSortTest >> testSortImplementation [

	| instances |

	instances := (reStore instancesOf: SimplePerson) asSortedCollection: [ :a :b | a <= b].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' ))
]

{ #category : #'unit tests' }
SSWReStoreSortTest >> testSortImplementationOnPersistentObject [

	| instances |

	instances := (reStore instancesOf: SimplePerson) asSortedCollection.
	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' )).
	instances with: instances reverse do: [ :person :friend | person friend: friend].
	reStore commitAll: instances.

	instances := (reStore instancesOf: SimplePerson) asSortedCollection: [ :a :b | a friendCompare: b].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('David Smythe' 'John Smith' 'Zoe Brown' 'Jim Brown' ))
]

{ #category : #'unit tests' }
SSWReStoreSortTest >> testSortImplementationOnPersistentObjectWithBlocks [

	| instances |

	instances := (reStore instancesOf: SimplePerson) asSortedCollection.
	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' )).
	instances with: instances reverse do: [ :person :friend | person friend: friend].
	reStore commitAll: instances.

	instances := (reStore instancesOf: SimplePerson) asSortedCollection: [ :a :b | a friendCompareWithBlocks: b].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('David Smythe' 'John Smith' 'Zoe Brown' 'Jim Brown' ))
]

{ #category : #'unit tests' }
SSWReStoreSortTest >> testSortImplementationWithBlocks [

	| instances |

	instances := (reStore instancesOf: SimplePerson) asSortedCollection: [ :a :b | a <== b].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' ))
]

{ #category : #'unit tests' }
SSWReStoreSortTest >> testStandardSort [

	| instances |

	self changeDavidToJohn.

	instances := (reStore instancesOf: SimplePerson) asSortedCollection: [ :a :b | (a firstName < b firstName) | (a firstName = b firstName & (a surname <= b surname))].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'John Smith' 'John Smythe' 'Zoe Brown'))
]

{ #category : #'unit tests' }
SSWReStoreSortTest >> testStandardSortOnPersistentObject [

	| instances |

	instances := (reStore instancesOf: SimplePerson) asSortedCollection.
	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' )).
	instances with: instances reverse do: [ :person :friend | person friend: friend].
	reStore commitAll: instances.

	instances := (reStore instancesOf: SimplePerson) asSortedCollection: [ :a :b | a friend <= b friend].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('David Smythe' 'John Smith' 'Zoe Brown' 'Jim Brown' ))
]

{ #category : #'unit tests' }
SSWReStoreSortTest >> testStandardSortOnPersistentObjectWithBlocks [

	| instances |

	instances := (reStore instancesOf: SimplePerson) asSortedCollection.
	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'Zoe Brown' 'John Smith' 'David Smythe' )).
	instances with: instances reverse do: [ :person :friend | person friend: friend].
	reStore commitAll: instances.

	SimplePerson methodDictionary at: #<= put: (SimplePerson>>#<==).
	instances := (reStore instancesOf: SimplePerson) asSortedCollection: [ :a :b | a friend <= b friend].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('David Smythe' 'John Smith' 'Zoe Brown' 'Jim Brown' ))
]

{ #category : #'unit tests' }
SSWReStoreSortTest >> testStandardSortWithBlocks [

	| instances |

	self changeDavidToJohn.

	instances := (reStore instancesOf: SimplePerson) asSortedCollection: [ :a :b | a firstName < b firstName or: [a firstName = b firstName and: [a surname <= b surname]]].

	self assert: ((instances collect: [ :each | each fullName]) asArray = #('Jim Brown' 'John Smith' 'John Smythe' 'Zoe Brown'))
]
