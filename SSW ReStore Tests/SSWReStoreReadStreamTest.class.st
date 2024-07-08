"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWReStoreReadStreamTest',
	#superclass : 'SSWReStorePersonTest',
	#instVars : [
		'readStream'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'unit tests' }
SSWReStoreReadStreamTest >> _testIncludeDuring: aBlock [

	| results |

	"We include: #address in the instances collection (1 query), therefore requesting address should not take any additional queries"
	self assert: (self countQueriesDuring: [results := aBlock value]) equals: 1.
	self assert: (self countQueriesDuring: [results do: [ :each | each address]]) equals: 0
]

{ #category : 'unit tests' }
SSWReStoreReadStreamTest >> _testRead: anInteger during: aBlock [

	"Private - Verify no more than anInteger number of SimplePersons are read during aBlock"

	| before |

	before := SimplePerson allInstances size.
	aBlock value.

	self assert: SimplePerson allInstances size <= (before + (anInteger * 2)) "* 2 since a copy is created for each instance read"
]

{ #category : 'running' }
SSWReStoreReadStreamTest >> createTestData [

	self sampleSet storeAllIn: reStore.

	reStore simulateReconnect.

	readStream := ((SimplePerson storedInstancesIn: reStore) beOrdered; include: #address; yourself) readStream
]

{ #category : 'running' }
SSWReStoreReadStreamTest >> sampleSet [

	^(1 to: self sampleSize) collect: 
		[ :e | 
		SimplePerson new 
			surname: 'Smith'; 
			firstName: 'John', e displayString; 
			emailAddress: 'john@something'; 
			address: SimpleAddress new;
			yourself]
]

{ #category : 'running' }
SSWReStoreReadStreamTest >> sampleSize [

	^50
]

{ #category : 'running' }
SSWReStoreReadStreamTest >> tearDown [

	readStream close.
	super tearDown
]

{ #category : 'unit tests' }
SSWReStoreReadStreamTest >> testAtEnd [

	self _testRead: (self sampleSize - 1) during: 
		[(readStream next: (self sampleSize - 1)) keysAndValuesDo: 
			[ :index :each | 
			self assert: each firstName equals: 'John', index displayString.
			self deny: readStream atEnd]].

	self assert: readStream next firstName equals: 'John', self sampleSize displayString.
	self assert: readStream atEnd
]

{ #category : 'unit tests' }
SSWReStoreReadStreamTest >> testNext [

	self _testRead: 2 during: 
		[self assert: readStream next firstName equals: 'John1'.
		self assert: readStream next firstName equals: 'John2']
]

{ #category : 'unit tests' }
SSWReStoreReadStreamTest >> testNextAvailable [

	self _testRead: (self sampleSize - 1) during: 
		[(readStream next: (self sampleSize - 1)) keysAndValuesDo: 
			[ :index :each | 
			self assert: each firstName equals: 'John', index displayString]].

	self assert: readStream nextAvailable firstName equals: 'John', self sampleSize displayString.
	self assert: readStream nextAvailable isNil
]

{ #category : 'unit tests' }
SSWReStoreReadStreamTest >> testNextAvailableInclude [

	self _testIncludeDuring: [{readStream nextAvailable}]
]

{ #category : 'unit tests' }
SSWReStoreReadStreamTest >> testNextAvailableN [

	self _testRead: (self sampleSize - 5) during: 
		[| available |
		available := readStream nextAvailable: (self sampleSize - 5).
		self assert: available size equals: (self sampleSize - 5).
		available keysAndValuesDo: 
			[ :index :each | 
			self assert: each firstName equals: 'John', index displayString]].

	self _testRead: 5 during: 
		[| available |
		available := readStream nextAvailable: 10.
		self assert: available size equals: 5.
		available keysAndValuesDo: 
			[ :index :each | 
			self assert: each firstName equals: 'John', ((self sampleSize - 5) + index) displayString]]
]

{ #category : 'unit tests' }
SSWReStoreReadStreamTest >> testNextAvailableNInclude [

	self _testIncludeDuring: [readStream nextAvailable: 10]
]

{ #category : 'unit tests' }
SSWReStoreReadStreamTest >> testNextInclude [

	self _testIncludeDuring: [{readStream next}]
]

{ #category : 'unit tests' }
SSWReStoreReadStreamTest >> testNextN [

	self _testRead: 30 during: 
		[(readStream next: 10) keysAndValuesDo: 
			[ :index :each | 
			self assert: each firstName equals: 'John', index displayString].

		(readStream next: 20) keysAndValuesDo: 
			[ :index :each | 
			self assert: each firstName equals: 'John', (10 + index) displayString]]
]

{ #category : 'unit tests' }
SSWReStoreReadStreamTest >> testNextNInclude [

	self _testIncludeDuring: [readStream next: 10]
]

{ #category : 'unit tests' }
SSWReStoreReadStreamTest >> testPeek [

	self _testRead: 3 during: 
		[self assert: readStream peek firstName equals: 'John1'.
		self assert: readStream next firstName equals: 'John1'.

		self assert: readStream peek firstName equals: 'John2'.
		self assert: readStream next firstName equals: 'John2'.

		self assert: readStream peek firstName equals: 'John3']
]

{ #category : 'unit tests' }
SSWReStoreReadStreamTest >> testPositionBackwards [

	readStream position: 19.
	self assert: readStream next firstName equals: 'John20'.

	readStream position: 9.
	self assert: readStream peek firstName equals: 'John10'.
	self assert: readStream next firstName equals: 'John10'.
	self assert: readStream next firstName equals: 'John11'
]

{ #category : 'unit tests' }
SSWReStoreReadStreamTest >> testPositionForwards [

	readStream position: 9.
	self assert: readStream next firstName equals: 'John10'.

	readStream position: 19.
	self assert: readStream peek firstName equals: 'John20'.
	self assert: readStream next firstName equals: 'John20'.
	self assert: readStream next firstName equals: 'John21'
]

{ #category : 'unit tests' }
SSWReStoreReadStreamTest >> testReset [

	10 timesRepeat: [readStream next].
	self assert: readStream next firstName equals: 'John11'.

	self _testRead: 1 during: 
		[readStream reset.
		self assert: readStream peek firstName equals: 'John1'.
		self assert: readStream next firstName equals: 'John1'].

	self _testRead: 1 during: 
		[readStream reset.
		self assert: readStream next firstName equals: 'John1'].

	self assert: readStream next firstName equals: 'John2'
]

{ #category : 'unit tests' }
SSWReStoreReadStreamTest >> testSize [

	self _testRead: 0 during: [self assert: readStream size equals: self sampleSize]
]

{ #category : 'unit tests' }
SSWReStoreReadStreamTest >> testUpTo [

	| j25 jN |

	j25 := (SimplePerson storedInstancesIn: reStore) detect: [ :each | each firstName = 'John25'].
	self _testRead: 25 during: 
		[| upTo |
		upTo := readStream upTo: j25.
		self assert: upTo size equals: 24.
		upTo keysAndValuesDo: 
			[ :index :each | 
			self assert: each firstName equals: 'John', index displayString]].
	self assert: readStream next firstName = 'John26'.

	jN := SimplePerson new.
	self _testRead: (self sampleSize - 26) during: 
		[| upTo |
		upTo := readStream upTo: jN.
		self assert: upTo size equals: (self sampleSize - 26).
		upTo keysAndValuesDo: 
			[ :index :each | 
			self assert: each firstName equals: 'John', (26 + index) displayString]].
	self assert: readStream atEnd

]

{ #category : 'unit tests' }
SSWReStoreReadStreamTest >> testUpToEnd [

	self _testRead: (self sampleSize - 25) during: 
		[| available |
		available := readStream next: (self sampleSize - 25).
		self assert: available size equals: (self sampleSize - 25).
		available keysAndValuesDo: 
			[ :index :each | 
			self assert: each firstName equals: 'John', index displayString]].

	self _testRead: 25 during: 
		[| available |
		available := readStream upToEnd.
		self assert: available size equals: 25.
		available keysAndValuesDo: 
			[ :index :each | 
			self assert: each firstName equals: 'John', ((self sampleSize - 25) + index) displayString]]
]

{ #category : 'unit tests' }
SSWReStoreReadStreamTest >> testUpToEndInclude [

	self _testIncludeDuring: [readStream upToEnd]
]

{ #category : 'unit tests' }
SSWReStoreReadStreamTest >> testUpToInclude [

	| j25 |

	j25 := (SimplePerson storedInstancesIn: reStore) detect: [ :each | each firstName = 'John25'].

	self _testIncludeDuring: [readStream upTo: j25]
]
