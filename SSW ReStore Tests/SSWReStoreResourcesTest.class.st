Class {
	#name : #SSWReStoreResourcesTest,
	#superclass : #SSWReStoreAbstractQueryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #tests }
SSWReStoreResourcesTest >> testStatementFreedAfterDetect [

	self _testStatementFreedAfter: [(SimplePerson storedInstancesIn: reStore) detect: [ :each | each firstName = 'John']]
]

{ #category : #tests }
SSWReStoreResourcesTest >> testStatementFreedAfterModify [

	self _testStatementFreedAfter: [(SimplePerson storedInstancesIn: reStore) modify: [ :each | each age: 21]]
]

{ #category : #tests }
SSWReStoreResourcesTest >> testStatementFreedAfterQuery [

	self _testStatementFreedAfter: [(SimplePerson storedInstancesIn: reStore) size]

]

{ #category : #tests }
SSWReStoreResourcesTest >> testStatementFreedAfterStreaming [

	self _testStatementFreedAfter: 
		[| stream |
		stream := (SimplePerson storedInstancesIn: reStore) readStream.
		[stream atEnd] whileFalse: [stream next].

		"Forward-only streams close themselves"
		stream class = SSWDBForwardOnlyReadStream ifFalse: [stream close]]
]

{ #category : #tests }
SSWReStoreResourcesTest >> testStatementFreedAfterUpdate [

	| john table |

	john := self john.

	table := reStore tableForClass: john class.
	self _testStatementFreedAfter: 
		[reStore executeQuery: 
			(SSWSQLUpdateObjectQuery new 
				object: john; 
				table: table;
				fieldUpdates: (SSWSQLFieldAssignment field: (table fieldAccessing: #firstName) value: 'Jack');
				yourself)]
]
