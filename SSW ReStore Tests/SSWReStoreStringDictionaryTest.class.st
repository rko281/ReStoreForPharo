Class {
	#name : 'SSWReStoreStringDictionaryTest',
	#superclass : 'SSWReStoreGenericTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'accessing' }
SSWReStoreStringDictionaryTest >> componentDefinition [

	^Dictionary of: (String maxSize: 50) -> (String maxSize: 50)
]

{ #category : 'helpers' }
SSWReStoreStringDictionaryTest >> createCheckObjects [

	{GenericTest new name: 'check'; component: 
		(Dictionary new 
			at: 'checkKey' put: 'checkValue'; 
			at: 'checkValue' put: 'dummyValue';
			at: 'sharedKey' put: 'checkValue';
			at: 'sharedValueKey' put: 'sharedValue';
			at: 'sharedAssocKey' put: 'sharedAssocValue';
			yourself).
	GenericTest new name: 'unCheck'; component: 
		(Dictionary new 
			at: 'unCheckKey' put: 'unCheckValue'; 
			at: 'unCheckValue' put: 'dummyValue';
			at: 'sharedKey' put: 'unCheckValue';
			at: 'sharedValueKey' put: 'sharedValue';
			at: 'sharedAssocKey' put: 'sharedAssocValue';
			yourself)} storeAllIn: reStore
]

{ #category : 'accessing' }
SSWReStoreStringDictionaryTest >> templateTestObject [

	| template |

	template := GenericTest new.
	template component: Dictionary new.

	1 to: 5 do: [ :index | template component at: ('key', index displayString) put: ('value', index displayString)].

	^template
	
]

{ #category : 'unit tests' }
SSWReStoreStringDictionaryTest >> testIncludes [

	| checks unChecks shares |

	self createCheckObjects.

	checks := (GenericTest storedInstancesIn: reStore) select: [ :each | each component includes: 'checkValue'].
	unChecks := (GenericTest storedInstancesIn: reStore) select: [ :each | each component includes: 'unCheckValue'].
	shares := (GenericTest storedInstancesIn: reStore) select: [ :each | each component includes: 'sharedValue'].

	self assert: checks size equals: 1.
	self assert: checks first name equals: 'check'.

	self assert: unChecks size equals: 1.
	self assert: unChecks first name equals: 'unCheck'.

	self assert: shares size equals: 2.
	self assert: (shares collect: [ :each | each name]) asSortedCollection asArray equals: #('check' 'unCheck')
]

{ #category : 'unit tests' }
SSWReStoreStringDictionaryTest >> testIncludesAssociation [

	| checks unChecks shares |

	self createCheckObjects.

	checks := (GenericTest storedInstancesIn: reStore) select: [ :each | each component includesAssociation: 'checkKey' -> 'checkValue'].
	unChecks := (GenericTest storedInstancesIn: reStore) select: [ :each | each component includesAssociation: 'unCheckKey' -> 'unCheckValue'].
	shares := (GenericTest storedInstancesIn: reStore) select: [ :each | each component includesAssociation: 'sharedAssocKey' -> 'sharedAssocValue'].

	self assert: checks size equals: 1.
	self assert: checks first name equals: 'check'.

	self assert: unChecks size equals: 1.
	self assert: unChecks first name equals: 'unCheck'.

	self assert: shares size equals: 2.
	self assert: (shares collect: [ :each | each name]) asSortedCollection asArray equals: #('check' 'unCheck')
]

{ #category : 'unit tests' }
SSWReStoreStringDictionaryTest >> testIncludesKey [

	| checks unChecks shares |

	self createCheckObjects.

	checks := (GenericTest storedInstancesIn: reStore) select: [ :each | each component includesKey: 'checkKey'].
	unChecks := (GenericTest storedInstancesIn: reStore) select: [ :each | each component includesKey: 'unCheckKey'].
	shares := (GenericTest storedInstancesIn: reStore) select: [ :each | each component includesKey: 'sharedKey'].

	self assert: checks size equals: 1.
	self assert: checks first name equals: 'check'.

	self assert: unChecks size equals: 1.
	self assert: unChecks first name equals: 'unCheck'.

	self assert: shares size equals: 2.
	self assert: (shares collect: [ :each | each name]) asSortedCollection asArray equals: #('check' 'unCheck')
]

{ #category : 'unit tests' }
SSWReStoreStringDictionaryTest >> testTemplateObject [

	self assert: testObject component size = 5.

	1 to: 5 do: 
		[ :index |
		self assert: (testObject component at: ('key', index displayString)) equals: ('value', index displayString)]
]
