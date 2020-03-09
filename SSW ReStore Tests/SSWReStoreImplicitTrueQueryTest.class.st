"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreImplicitTrueQueryTest,
	#superclass : #SSWReStoreTest,
	#instVars : [
		'instances'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreImplicitTrueQueryTest >> addClassesTo: aReStore [

	super addClassesTo: aReStore.
	aReStore
		addClass: TypeTest
]

{ #category : #public }
SSWReStoreImplicitTrueQueryTest >> setUp [

	super setUp.

	reStore beginTransaction.

	TypeTest new
		varchar: '1true';
		integer: 1;
		char: 'a';
		trueBoolean: true;
		storeIn: reStore.

	TypeTest new
		varchar: '1false';
		integer: 1;
		char: 'a';
		trueBoolean: false;
		storeIn: reStore.

	TypeTest new
		varchar: '2true';
		integer: 2;
		char: 'b';
		trueBoolean: true;
		storeIn: reStore.

	TypeTest new
		varchar: '2false';
		integer: 2;
		char: 'b';
		trueBoolean: false;
		storeIn: reStore.

	reStore commitTransaction.

	instances := reStore instancesOf: TypeTest
]

{ #category : #public }
SSWReStoreImplicitTrueQueryTest >> testImplicitTrueNotSoleCondition [

	| results |

	results := instances select: [ :each | each trueBoolean not].

	self assert: results size = 2.
	self assert: (results collect: [ :each | each varchar]) asSortedCollection asArray = #('1false' '2false')
]

{ #category : #public }
SSWReStoreImplicitTrueQueryTest >> testImplicitTrueSoleCondition [

	| results |

	results := instances select: [ :each | each trueBoolean].

	self assert: results size = 2.
	self assert: (results collect: [ :each | each varchar]) asSortedCollection asArray = #('1true' '2true')
]

{ #category : #public }
SSWReStoreImplicitTrueQueryTest >> testInlinedAndFirst [

	| results |

	results := instances select: [ :each | each trueBoolean and: [each integer = 1]].

	self assert: results size = 1.
	self assert: results first varchar = '1true'
]

{ #category : #public }
SSWReStoreImplicitTrueQueryTest >> testInlinedAndLast [

	| results |

	results := instances select: [ :each | each integer = 1 and: [each trueBoolean]].

	self assert: results size = 1.
	self assert: results first varchar = '1true'
]

{ #category : #public }
SSWReStoreImplicitTrueQueryTest >> testInlinedAndMid [

	| results |

	results := instances select: [ :each | each integer = 1 and: [each trueBoolean and: [each char = 'a']]].
	self assert: results size = 1.
	self assert: results first varchar = '1true'.

	results := instances select: [ :each | each integer = 2 and: [each trueBoolean and: [each char = 'b']]].
	self assert: results size = 1.
	self assert: results first varchar = '2true'.

	results := instances select: [ :each | each integer = 2 and: [each trueBoolean and: [each char = 'a']]].
	self assert: results isEmpty.

	results := instances select: [ :each | each integer = 1 and: [each trueBoolean and: [each char = 'b']]].
	self assert: results isEmpty
]

{ #category : #public }
SSWReStoreImplicitTrueQueryTest >> testInlinedOrFirst [

	| results |

	results := instances select: [ :each | each trueBoolean or: [each integer = 1]].

	self assert: results size = 3.
	self assert: (results collect: [ :each | each varchar]) asSortedCollection asArray = #('1false' '1true' '2true')
]

{ #category : #public }
SSWReStoreImplicitTrueQueryTest >> testInlinedOrLast [

	| results |

	results := instances select: [ :each | each integer = 1 or: [each trueBoolean]].

	self assert: results size = 3.
	self assert: (results collect: [ :each | each varchar]) asSortedCollection asArray = #('1false' '1true' '2true')
]

{ #category : #public }
SSWReStoreImplicitTrueQueryTest >> testInlinedOrMid [

	| results |

	results := instances select: [ :each | each integer = 1 or: [each trueBoolean or: [each char = 'b']]].
	self assert: results size = 4.
	self assert: (results collect: [ :each | each varchar]) asSortedCollection asArray = #('1false' '1true' '2false' '2true').

	results := instances select: [ :each | each integer = 2 or: [each trueBoolean or: [each char = 'a']]].
	self assert: results size = 4.
	self assert: (results collect: [ :each | each varchar]) asSortedCollection asArray = #('1false' '1true' '2false' '2true').

	results := instances select: [ :each | each integer = 1 or: [each trueBoolean or: [each char = 'a']]].
	self assert: results size = 3.
	self assert: (results collect: [ :each | each varchar]) asSortedCollection asArray = #('1false' '1true' '2true').

	results := instances select: [ :each | each integer = 2 or: [each trueBoolean or: [each char = 'b']]].
	self assert: results size = 3.
	self assert: (results collect: [ :each | each varchar]) asSortedCollection asArray = #('1true' '2false' '2true')
]

{ #category : #public }
SSWReStoreImplicitTrueQueryTest >> testNonInlinedAndFirst [

	| results |

	results := instances select: [ :each | each trueBoolean & (each integer = 1)].

	self assert: results size = 1.
	self assert: results first varchar = '1true'
]

{ #category : #public }
SSWReStoreImplicitTrueQueryTest >> testNonInlinedAndLast [

	| results |

	results := instances select: [ :each | (each integer = 1) & each trueBoolean].

	self assert: results size = 1.
	self assert: results first varchar = '1true'
]

{ #category : #public }
SSWReStoreImplicitTrueQueryTest >> testNonInlinedAndMid [

	| results |

	results := instances select: [ :each | (each integer = 1) & each trueBoolean & (each char = 'a')].
	self assert: results size = 1.
	self assert: results first varchar = '1true'.

	results := instances select: [ :each | (each integer = 2) & each trueBoolean & (each char = 'b')].
	self assert: results size = 1.
	self assert: results first varchar = '2true'.

	results := instances select: [ :each | (each integer = 2) & each trueBoolean & (each char = 'a')].
	self assert: results isEmpty.

	results := instances select: [ :each | (each integer = 1) & each trueBoolean & (each char = 'b')].
	self assert: results isEmpty
]

{ #category : #public }
SSWReStoreImplicitTrueQueryTest >> testNonInlinedOrFirst [

	| results |

	results := instances select: [ :each | each trueBoolean | (each integer = 1)].

	self assert: results size = 3.
	self assert: (results collect: [ :each | each varchar]) asSortedCollection asArray = #('1false' '1true' '2true')
]

{ #category : #public }
SSWReStoreImplicitTrueQueryTest >> testNonInlinedOrLast [

	| results |

	results := instances select: [ :each | (each integer = 1) | each trueBoolean].

	self assert: results size = 3.
	self assert: (results collect: [ :each | each varchar]) asSortedCollection asArray = #('1false' '1true' '2true')
]

{ #category : #public }
SSWReStoreImplicitTrueQueryTest >> testNonInlinedOrMid [

	| results |

	results := instances select: [ :each | (each integer = 1) | each trueBoolean | (each char = 'b')].
	self assert: results size = 4.
	self assert: (results collect: [ :each | each varchar]) asSortedCollection asArray = #('1false' '1true' '2false' '2true').

	results := instances select: [ :each | (each integer = 2) | each trueBoolean | (each char = 'a')].
	self assert: results size = 4.
	self assert: (results collect: [ :each | each varchar]) asSortedCollection asArray = #('1false' '1true' '2false' '2true').

	results := instances select: [ :each | (each integer = 1) | each trueBoolean | (each char = 'a')].
	self assert: results size = 3.
	self assert: (results collect: [ :each | each varchar]) asSortedCollection asArray = #('1false' '1true' '2true').

	results := instances select: [ :each | (each integer = 2) | each trueBoolean | (each char = 'b')].
	self assert: results size = 3.
	self assert: (results collect: [ :each | each varchar]) asSortedCollection asArray = #('1true' '2false' '2true')
]
