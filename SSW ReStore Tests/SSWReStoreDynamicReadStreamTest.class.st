Class {
	#name : 'SSWReStoreDynamicReadStreamTest',
	#superclass : 'SSWReStoreReadStreamTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'unit tests' }
SSWReStoreDynamicReadStreamTest >> _testNonScrollableConnection [

	"Private - Sent in case of this class not being relevent, i.e. connection does not support scrollable cursors.
	Just verify this is the case"

	self deny: reStore connection supportsScrollableCursors
]

{ #category : 'running' }
SSWReStoreDynamicReadStreamTest >> createTestData [

	"Shortcut this if we're not relevant"
	reStore connection supportsScrollableCursors ifFalse: [^readStream := ReadStream on: #()].

	self sampleSet storeAllIn: reStore.

	reStore simulateReconnect.

	readStream := ((SimplePerson storedInstancesIn: reStore) beOrdered; include: #address; yourself) readStream: (reStore connection supportsScrollableDynamicCursorType ifTrue: [#dynamic] ifFalse: [#static])
]

{ #category : 'running' }
SSWReStoreDynamicReadStreamTest >> setUp [

	"This class is only relevant to connections which support scrollable cursors"

	super setUp.

	reStore connection supportsScrollableCursors ifFalse: [testSelector := #_testNonScrollableConnection]
]

{ #category : 'unit tests' }
SSWReStoreDynamicReadStreamTest >> testPositionBackwardsSpeed [
	"For a dynamic cursor reversing position should ~ as fast as going forward"

	| speedFwd speedReverse |
	"Need a larger working set for this test to be meaningful"
	((self sampleSize + 1 to: 10000) collect: [ :e |
		 SimplePerson new
			 surname: 'Smith';
			 firstName: 'John' , e displayString;
			 emailAddress: 'john@something';
			 address: SimpleAddress new;
			 yourself ]) storeAllIn: reStore.

	reStore simulateReconnect.

	readStream := ((SimplePerson storedInstancesIn: reStore)
		               beOrdered;
		               yourself) readStream: #dynamic.

	"Warm things up"
	readStream position: 8900.
	self assert: readStream next firstName equals: 'John8901'.

	speedFwd := [
	            readStream position: 9900.
	            self assert: readStream next firstName equals: 'John9901' ]
		            timeToRun.

	speedReverse := [
	                readStream position: 8900.
	                self
		                assert: readStream peek firstName
		                equals: 'John8901' ] timeToRun.

	self assert: speedReverse <= (speedFwd * 2)
]

{ #category : 'unit tests' }
SSWReStoreDynamicReadStreamTest >> testReadStreamClass [

	"For a dynamic cursor we should have an SSWDBReadStream, not SSWDBForwardOnlyReadStream"

	self assert: readStream class equals: SSWDBReadStream
]
